import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:resumebuilder/core/errors/exceptions.dart';

/// Singleton service that generates, stores, and verifies OTP codes.
/// Sends OTP emails directly via Gmail SMTP — no backend required.
class OtpService {
  OtpService._();
  static final OtpService instance = OtpService._();

  // In-memory store: email → { code, expiresAt }
  final Map<String, _OtpEntry> _store = {};

  static const int _expiryMinutes = 10;

  // ── Generate + Send OTP ────────────────────────────────────────────────────

  /// Generates a 6-digit OTP, stores it in memory, and sends it to [email]
  /// via Gmail SMTP. Throws [AuthException] on any failure.
  Future<void> generateAndSendOtp(String email) async {
    final code = _generateCode();
    final expiresAt = DateTime.now().add(
      const Duration(minutes: _expiryMinutes),
    );

    // Store before sending so even if send fails we can detect it
    _store[email.toLowerCase()] = _OtpEntry(code: code, expiresAt: expiresAt);

    await _sendEmail(email: email, code: code);
  }

  // ── Verify OTP ─────────────────────────────────────────────────────────────

  /// Verifies [inputCode] for [email]. Clears OTP after successful verification.
  /// Throws [AuthException] if code is wrong or expired.
  void verifyOtp(String email, String inputCode) {
    final key = email.toLowerCase();
    final entry = _store[key];

    if (entry == null) {
      throw const AuthException(
        'No OTP found for this email. Please request a new one.',
      );
    }

    if (DateTime.now().isAfter(entry.expiresAt)) {
      _store.remove(key);
      throw const AuthException(
        'OTP has expired. Please request a new code.',
      );
    }

    if (entry.code != inputCode.trim()) {
      throw const AuthException(
        'Invalid OTP code. Please check and try again.',
      );
    }

    // Valid — remove so it can't be reused
    _store.remove(key);
  }

  /// Clears any stored OTP for [email].
  void clearOtp(String email) {
    _store.remove(email.toLowerCase());
  }

  // ── Private Helpers ────────────────────────────────────────────────────────

  String _generateCode() {
    final rng = Random.secure();
    // Ensure exactly 6 digits
    final number = 100000 + rng.nextInt(900000);
    return number.toString();
  }

  Future<void> _sendEmail({
    required String email,
    required String code,
  }) async {
    final senderEmail = dotenv.env['MAILER_EMAIL'] ?? '';
    final appPassword = dotenv.env['MAILER_APP_PASSWORD'] ?? '';

    if (senderEmail.isEmpty || appPassword.isEmpty) {
      throw const AuthException(
        'Email service is not configured. Please contact support.',
      );
    }

    final smtpServer = gmail(senderEmail, appPassword);

    final message = Message()
      ..from = Address(senderEmail, 'ResumeIQ')
      ..recipients.add(email)
      ..subject = 'ResumeIQ Password Reset Verification Code'
      ..text =
          'Your ResumeIQ password reset code is $code. '
          'It will expire in $_expiryMinutes minutes. '
          'If you did not request this, please ignore this email.'
      ..html = _buildEmailHtml(code);

    try {
      await send(message, smtpServer);
    } on MailerException catch (e) {
      throw AuthException(
        'Failed to send OTP email: ${e.message}. '
        'Check your Gmail App Password.',
      );
    } catch (e) {
      throw AuthException('Failed to send email: ${e.toString()}');
    }
  }

  String _buildEmailHtml(String code) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background-color: #f4f6f9;
      margin: 0; padding: 0;
    }
    .container {
      max-width: 600px;
      margin: 40px auto;
      background-color: #ffffff;
      border-radius: 12px;
      box-shadow: 0 4px 15px rgba(0,0,0,0.05);
      overflow: hidden;
    }
    .header {
      background-color: #00b47d;
      padding: 30px;
      text-align: center;
      color: white;
    }
    .header h1 { margin: 0; font-size: 28px; font-weight: 700; letter-spacing: 1px; }
    .header p { margin: 6px 0 0; font-size: 14px; opacity: 0.85; }
    .content { padding: 40px 30px; color: #333333; line-height: 1.6; }
    .content p { font-size: 16px; margin-bottom: 20px; }
    .otp-container { text-align: center; margin: 35px 0; }
    .otp-code {
      font-size: 42px;
      font-weight: bold;
      color: #00b47d;
      letter-spacing: 8px;
      padding: 18px 36px;
      background-color: #e5f7f1;
      border: 2px dashed #00b47d;
      border-radius: 10px;
      display: inline-block;
    }
    .expiry {
      text-align: center;
      font-size: 14px;
      color: #666;
      margin-top: -10px;
      margin-bottom: 20px;
    }
    .alert-text { font-size: 13px; color: #f44336; }
    .footer {
      background-color: #f9fafb;
      padding: 20px 30px;
      text-align: center;
      font-size: 13px;
      color: #888888;
      border-top: 1px solid #eeeeee;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>ResumeIQ</h1>
      <p>Password Reset Request</p>
    </div>
    <div class="content">
      <p>Hello,</p>
      <p>We received a request to reset the password for your ResumeIQ account. 
         Use the 6-digit code below to complete your password reset:</p>
      <div class="otp-container">
        <div class="otp-code">$code</div>
      </div>
      <p class="expiry">⏱ This code expires in <b>$_expiryMinutes minutes</b></p>
      <p class="alert-text">
        If you did not request a password reset, please ignore this email. 
        Your account remains secure.
      </p>
    </div>
    <div class="footer">
      &copy; ${DateTime.now().year} ResumeIQ. All rights reserved.
    </div>
  </div>
</body>
</html>''';
  }
}

class _OtpEntry {
  final String code;
  final DateTime expiresAt;
  _OtpEntry({required this.code, required this.expiresAt});
}
