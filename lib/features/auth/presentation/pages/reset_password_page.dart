import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumebuilder/core/constants/app_colors.dart';
import 'package:resumebuilder/core/constants/app_routes.dart';
import 'package:resumebuilder/core/utils/validators.dart';
import 'package:resumebuilder/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:resumebuilder/features/auth/presentation/bloc/auth_event.dart';
import 'package:resumebuilder/features/auth/presentation/bloc/auth_state.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? initialLinkOrCode;

  const ResetPasswordPage({super.key, this.initialLinkOrCode});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _resetLinkOrCodeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialLinkOrCode?.trim();
    if (initialValue != null && initialValue.isNotEmpty) {
      _resetLinkOrCodeController.text = initialValue;
    }
  }

  @override
  void dispose() {
    _resetLinkOrCodeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _extractOobCode(String input) {
    final value = input.trim();
    if (value.contains('oobCode=')) {
      final uri = Uri.tryParse(value);
      final code = uri?.queryParameters['oobCode'];
      if (code != null && code.isNotEmpty) {
        return code;
      }
    }
    return value;
  }

  void _onResetPassword() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final oobCode = _extractOobCode(_resetLinkOrCodeController.text);
    context.read<AuthBloc>().add(
      ConfirmPasswordResetEvent(
        oobCode: oobCode,
        newPassword: _newPasswordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set New Password')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ConfirmPasswordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );

            Future.delayed(const Duration(milliseconds: 1200), () {
              if (mounted) {
                Navigator.of(
                  this.context,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              }
            });
          } else if (state is ConfirmPasswordResetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ConfirmPasswordResetLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.password,
                        size: 72,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Create New Password',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Paste reset link or code from your email, then set your new password.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _resetLinkOrCodeController,
                        enabled: !isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Reset Link or Code',
                          prefixIcon: Icon(Icons.link_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Reset link or code is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                        ),
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) =>
                            Validators.validateConfirmPassword(
                              value,
                              _newPasswordController.text,
                            ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isLoading ? null : _onResetPassword,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text('Update Password'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
