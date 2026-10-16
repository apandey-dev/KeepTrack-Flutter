import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/custom_snackbar.dart';
import '../auth_controller.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_emailController.text);

    if (!mounted) return;
    if (success) {
      AppSnackbar.show(
        context,
        message: 'Password reset link sent to your email address.',
      );
      context.pop();
    } else {
      final error = ref.read(authControllerProvider).errorMessage;
      if (error != null) {
        AppSnackbar.show(context, message: error, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF111827);
    final secondaryTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final buttonBg = isDark ? Colors.white : const Color(0xFF111827);
    final buttonFg = isDark ? Colors.black : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top App Bar with back circular button
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/login');
                        }
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor, width: 1.2),
                          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 20,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                Text(
                  'Reset password',
                  style: GoogleFonts.mali(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter the email associated with your account and we’ll send an email with instructions to reset your password.',
                  style: GoogleFonts.mali(
                    fontSize: 14,
                    height: 1.5,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 32),

                AuthTextField(
                  controller: _emailController,
                  hintText: 'Email address',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: AppValidators.validateEmail,
                  onFieldSubmitted: (_) => _handleResetPassword(),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBg,
                      foregroundColor: buttonFg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: authState.isLoading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(buttonFg),
                            ),
                          )
                        : Text(
                            'Send Reset Link',
                            style: GoogleFonts.mali(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
