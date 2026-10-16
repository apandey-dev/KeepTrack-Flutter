import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/custom_snackbar.dart';
import '../auth_controller.dart';
import '../widgets/auth_text_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();

    final success = await ref.read(authControllerProvider.notifier).signUpWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: fullName.isNotEmpty ? fullName : null,
        );

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
                        // Back circle button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
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
                        ),

                        const SizedBox(height: 24),

                        // Title: "Create your account"
                        Text(
                          'Create your account',
                          style: GoogleFonts.mali(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                            color: primaryTextColor,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // First Name
                        AuthTextField(
                          controller: _firstNameController,
                          hintText: 'First name',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // Last Name
                        AuthTextField(
                          controller: _lastNameController,
                          hintText: 'Last name',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your last name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // Email address
                        AuthTextField(
                          controller: _emailController,
                          hintText: 'Email address',
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: AppValidators.validateEmail,
                        ),

                        const SizedBox(height: 14),

                        // Password
                        AuthTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          validator: AppValidators.validatePassword,
                        ),

                        const SizedBox(height: 14),

                        // Confirm Password
                        AuthTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm password',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (val != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _handleSignUp(),
                        ),

                        const SizedBox(height: 28),

                        // "Create Account" Button (Bada / prominent)
                        SizedBox(
                          height: 58,
                          child: ElevatedButton(
                            onPressed: authState.isLoading ? null : _handleSignUp,
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
                                    'Create Account',
                                    style: GoogleFonts.mali(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                          ),
                        ),

                        const Spacer(),
                        const SizedBox(height: 24),

                        // Footer: "Already have an account? Log In"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: GoogleFonts.mali(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: secondaryTextColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: authState.isLoading
                                  ? null
                                  : () {
                                      if (context.canPop()) {
                                        context.pop();
                                      } else {
                                        context.go('/login');
                                      }
                                    },
                              child: Text(
                                'Log In',
                                style: GoogleFonts.mali(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
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
