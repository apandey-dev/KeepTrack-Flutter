import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/custom_snackbar.dart';
import '../auth_controller.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref.read(authControllerProvider.notifier).signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );

    if (!mounted) return;
    if (!success) {
      final error = ref.read(authControllerProvider).errorMessage;
      if (error != null) {
        AppSnackbar.show(context, message: error, isError: true);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    FocusScope.of(context).unfocus();
    final success = await ref.read(authControllerProvider.notifier).signInWithGoogle();

    if (!mounted) return;
    if (!success) {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top App Bar: Centered "Sign in" (no back button)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Text(
                            'Sign in',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.mali(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryTextColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Title: "Welcome back"
                        Text(
                          'Welcome back',
                          style: GoogleFonts.mali(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                            color: primaryTextColor,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Email Field
                        AuthTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: AppValidators.validateEmail,
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        AuthTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          validator: AppValidators.validatePassword,
                          onFieldSubmitted: (_) => _handleEmailLogin(),
                        ),

                        const SizedBox(height: 14),

                        // Forgot password link (aligned left)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: authState.isLoading
                                ? null
                                : () => context.push('/forgot-password'),
                            child: Text(
                              'Forgot your password?',
                              style: GoogleFonts.mali(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline,
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Primary Button: "Sign in" (Bada / prominent)
                        SizedBox(
                          height: 58,
                          child: ElevatedButton(
                            onPressed: authState.isLoading ? null : _handleEmailLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonBg,
                              foregroundColor: buttonFg,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: authState.isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      valueColor: AlwaysStoppedAnimation<Color>(buttonFg),
                                    ),
                                  )
                                : Text(
                                    'Sign in',
                                    style: GoogleFonts.mali(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Divider: "or"
                        Row(
                          children: [
                            Expanded(child: Divider(color: borderColor)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'or',
                                style: GoogleFonts.mali(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: borderColor)),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Google Sign-In Button
                        GoogleSignInButton(
                          isLoading: authState.isLoading,
                          onPressed: _handleGoogleSignIn,
                        ),

                        const Spacer(),
                        const SizedBox(height: 28),

                        // Footer: "First time here? Create an account"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'First time here? ',
                              style: GoogleFonts.mali(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: secondaryTextColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: authState.isLoading
                                  ? null
                                  : () => context.push('/signup'),
                              child: Text(
                                'Create an account',
                                style: GoogleFonts.mali(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  color: primaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
