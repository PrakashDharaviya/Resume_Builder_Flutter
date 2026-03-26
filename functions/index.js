const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const crypto = require("crypto");

admin.initializeApp();

const OTP_COLLECTION = "password_reset_otps";
const OTP_EXPIRY_MINUTES = 10;
const OTP_RESEND_COOLDOWN_SECONDS = 60;
const OTP_MAX_ATTEMPTS = 5;

function getMailerConfig() {
  const cfg = functions.config().mailer || {};
  const email = cfg.email;
  const appPassword = cfg.app_password;

  if (!email || !appPassword) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Mailer is not configured. Set mailer.email and mailer.app_password in Firebase Functions config.",
    );
  }

  return { email, appPassword };
}

function createTransporter() {
  const { email, appPassword } = getMailerConfig();
  return nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: email,
      pass: appPassword,
    },
  });
}

function normalizeEmail(email) {
  return String(email || "")
    .trim()
    .toLowerCase();
}

function generateOtpCode() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

function hashOtp(email, otpCode) {
  return crypto
    .createHash("sha256")
    .update(`${normalizeEmail(email)}:${String(otpCode).trim()}`)
    .digest("hex");
}

exports.requestPasswordResetOtp = functions.https.onCall(async (data) => {
  const email = normalizeEmail(data?.email);

  if (!email) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Email is required.",
    );
  }

  let userRecord;
  try {
    userRecord = await admin.auth().getUserByEmail(email);
  } catch (error) {
    if (error?.code === "auth/user-not-found") {
      throw new functions.https.HttpsError(
        "not-found",
        "No account found with this email address.",
      );
    }
    throw new functions.https.HttpsError(
      "internal",
      "Could not verify account. Please try again.",
    );
  }

  const docRef = admin
    .firestore()
    .collection(OTP_COLLECTION)
    .doc(userRecord.uid);
  const nowMs = Date.now();
  const existingDoc = await docRef.get();

  if (existingDoc.exists) {
    const existingData = existingDoc.data() || {};
    const lastSentAt = existingData.lastSentAt;
    const lastSentMs =
      lastSentAt && typeof lastSentAt.toMillis === "function"
        ? lastSentAt.toMillis()
        : 0;
    const elapsedSeconds = Math.floor((nowMs - lastSentMs) / 1000);

    if (elapsedSeconds < OTP_RESEND_COOLDOWN_SECONDS) {
      throw new functions.https.HttpsError(
        "resource-exhausted",
        `Please wait ${OTP_RESEND_COOLDOWN_SECONDS - elapsedSeconds}s before requesting a new code.`,
      );
    }
  }

  const otpCode = generateOtpCode();
  const otpHash = hashOtp(email, otpCode);
  const expiresAt = admin.firestore.Timestamp.fromMillis(
    nowMs + OTP_EXPIRY_MINUTES * 60 * 1000,
  );

  await docRef.set(
    {
      email,
      otpHash,
      attempts: 0,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      lastSentAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt,
    },
    { merge: true },
  );

  const transporter = createTransporter();
  const { email: fromEmail } = getMailerConfig();

  await transporter.sendMail({
    from: `ResumeIQ <${fromEmail}>`,
    to: email,
    subject: "ResumeIQ Password Reset Verification Code",
    text:
      `Your ResumeIQ password reset code is ${otpCode}. ` +
      `It will expire in ${OTP_EXPIRY_MINUTES} minutes. ` +
      "If you did not request this, please ignore this email.",
    html:
      `<p>Your ResumeIQ password reset code is <b>${otpCode}</b>.</p>` +
      `<p>This code expires in <b>${OTP_EXPIRY_MINUTES} minutes</b>.</p>` +
      "<p>If you did not request this, please ignore this email.</p>",
  });

  return {
    success: true,
    message: "Verification code sent to your email.",
    expiresInMinutes: OTP_EXPIRY_MINUTES,
    resendInSeconds: OTP_RESEND_COOLDOWN_SECONDS,
  };
});

exports.confirmPasswordResetWithOtp = functions.https.onCall(async (data) => {
  const email = normalizeEmail(data?.email);
  const otpCode = String(data?.otpCode || "").trim();
  const newPassword = String(data?.newPassword || "").trim();

  if (!email || !otpCode || !newPassword) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Email, OTP code, and new password are required.",
    );
  }

  if (newPassword.length < 6) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Password must be at least 6 characters.",
    );
  }

  let userRecord;
  try {
    userRecord = await admin.auth().getUserByEmail(email);
  } catch (error) {
    if (error?.code === "auth/user-not-found") {
      throw new functions.https.HttpsError(
        "not-found",
        "No account found with this email address.",
      );
    }
    throw new functions.https.HttpsError(
      "internal",
      "Could not verify account. Please try again.",
    );
  }

  const docRef = admin
    .firestore()
    .collection(OTP_COLLECTION)
    .doc(userRecord.uid);
  const doc = await docRef.get();

  if (!doc.exists) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "No verification code request found. Please request a new code.",
    );
  }

  const otpData = doc.data() || {};
  if (normalizeEmail(otpData.email) !== email) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "The verification code does not match this email address.",
    );
  }

  const expiresAt = otpData.expiresAt;
  const expiresMs =
    expiresAt && typeof expiresAt.toMillis === "function"
      ? expiresAt.toMillis()
      : 0;

  if (Date.now() > expiresMs) {
    await docRef.delete();
    throw new functions.https.HttpsError(
      "deadline-exceeded",
      "Verification code has expired. Please request a new code.",
    );
  }

  const attempts = Number(otpData.attempts || 0);
  if (attempts >= OTP_MAX_ATTEMPTS) {
    await docRef.delete();
    throw new functions.https.HttpsError(
      "permission-denied",
      "Too many invalid attempts. Please request a new code.",
    );
  }

  const expectedHash = otpData.otpHash;
  const receivedHash = hashOtp(email, otpCode);
  if (!expectedHash || expectedHash !== receivedHash) {
    await docRef.set({ attempts: attempts + 1 }, { merge: true });
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Invalid verification code.",
    );
  }

  await admin.auth().updateUser(userRecord.uid, { password: newPassword });
  await admin.auth().revokeRefreshTokens(userRecord.uid);
  await docRef.delete();

  return {
    success: true,
    message: "Password updated successfully.",
  };
});

/**
 * HTTP Callable function to broadcast a push notification to all users
 * who have opted in (notificationsEnabled: true).
 */
exports.sendBroadcastNotification = functions.https.onCall(
  async (data, context) => {
    // 1. Verify Authentication (Uncomment in production if needed)
    // if (!context.auth) {
    //   throw new functions.https.HttpsError(
    //     "unauthenticated",
    //     "Only authenticated users can send broadcasts."
    //   );
    // }

    const title = data.title;
    const body = data.body;

    if (!title || !body) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "The functions requires 'title' and 'body' in the payload.",
      );
    }

    try {
      // 2. Fetch all users who have opted-in AND have an FCM token
      const usersSnapshot = await admin
        .firestore()
        .collection("users")
        .where("notificationsEnabled", "==", true)
        .get();

      if (usersSnapshot.empty) {
        console.log("No users opted in for notifications.");
        return { success: true, count: 0, message: "No users found" };
      }

      const tokens = [];
      usersSnapshot.forEach((doc) => {
        const userData = doc.data();
        if (userData.fcmToken) {
          tokens.push(userData.fcmToken);
        }
      });

      if (tokens.length === 0) {
        console.log("Users opted in, but no FCM tokens found.");
        return { success: true, count: 0, message: "No tokens found" };
      }

      // 3. Create the messaging payload
      const message = {
        notification: {
          title: title,
          body: body,
        },
        tokens: tokens,
      };

      // 4. Send the multicast message
      const response = await admin.messaging().sendEachForMulticast(message);

      console.log(
        `Successfully sent message. Success: ${response.successCount}, Failures: ${response.failureCount}`,
      );

      // Optional: Clean up invalid tokens based on responses
      if (response.failureCount > 0) {
        const failedTokens = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            failedTokens.push(tokens[idx]);
            console.error(
              `Failure error for token ${tokens[idx]}: ${resp.error.message}`,
            );
          }
        });
        // Here you could remove the failed tokens from Firestore if desired
      }

      return {
        success: true,
        count: response.successCount,
      };
    } catch (error) {
      console.error("Error broadcasting notification:", error);
      throw new functions.https.HttpsError(
        "internal",
        "An error occurred while broadcasting the notification.",
      );
    }
  },
);
