import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wattwise_app/feature/auth/providers/auth_provider.dart';
import 'package:wattwise_app/feature/auth/screen/sign_up_page.dart';
import 'package:wattwise_app/feature/auth/widgets/cta_button.dart';
import 'package:wattwise_app/feature/auth/widgets/sign_in_with_google.dart';
import 'package:wattwise_app/utils/svg_assets.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref
        .read(authNotifierProvider.notifier)
        .signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!success && mounted) {
      final errorMsg =
          ref.read(authNotifierProvider).errorMessage ?? 'An error occurred.';
      _showSnackBar(errorMsg, isError: true);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    FocusScope.of(context).unfocus();
    final success = await ref
        .read(authNotifierProvider.notifier)
        .signInWithGoogle();

    if (!success && mounted) {
      final authState = ref.read(authNotifierProvider);
      if (authState.status == AuthStatus.error) {
        _showSnackBar(
          authState.errorMessage ?? 'Google sign-in failed.',
          isError: true,
        );
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar('Enter your email above first.', isError: false);
      return;
    }
    await ref
        .read(authNotifierProvider.notifier)
        .sendPasswordReset(email: email);

    if (mounted) {
      _showSnackBar(
        'Password reset email sent! Check your inbox.',
        isError: false,
      );
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final fontSize = screenWidth * 0.05;

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(fontSize * 0.75),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ── Header ──────────────────────────────────────
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back!',
                              style: GoogleFonts.poppins(
                                fontSize: fontSize * 1.45,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: fontSize * 0.4),
                            Text(
                              'Sign in to continue',
                              style: GoogleFonts.poppins(
                                fontSize: fontSize * 0.8,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // ── Hero Image ────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: fontSize * 1.2),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/svg/sign_in_overlay.png',
                          width: screenWidth * 0.5,
                          height: screenWidth * 0.5,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // ── Email Field ───────────────────────────────────
                    TextFormField(
                      controller: _emailController,
                      style: GoogleFonts.nunito(color: Colors.black),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!val.contains('@') || !val.contains('.')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 15, right: 5),
                          child: Icon(Icons.email_outlined, color: Colors.grey),
                        ),
                        hintText: 'Enter email address',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF2563EB),
                            width: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFFEF4444),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFFEF4444),
                            width: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    SizedBox(height: fontSize * 0.7),

                    // ── Password Field ────────────────────────────────
                    TextFormField(
                      controller: _passwordController,
                      style: GoogleFonts.nunito(color: Colors.black),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleSignIn(),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Password is required';
                        }
                        if (val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 15, right: 5),
                          child: Icon(Icons.lock_outline, color: Colors.grey),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF2563EB),
                            width: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFFEF4444),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFFEF4444),
                            width: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    // ── Forgot Password ────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isLoading ? null : _handleForgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.poppins(
                              fontSize: fontSize * 0.75,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── OR Divider ────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: fontSize * 0.5,
                          ),
                          child: Text(
                            'OR',
                            style: GoogleFonts.poppins(
                              fontSize: fontSize * 0.8,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),
                      ],
                    ),

                    SizedBox(height: fontSize * 0.8),

                    // ── Google Sign-In ────────────────────────────────
                    SignInWithGoogle(
                      svgAssets: SvgAssets.google_svg,
                      onPressed: isLoading ? null : _handleGoogleSignIn,
                    ),

                    SizedBox(height: fontSize * 1.5),

                    // ── CTA: Sign In ──────────────────────────────────
                    isLoading
                        ? const SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          )
                        : CtaButton(text: 'Sign In', onPressed: _handleSignIn),

                    SizedBox(height: fontSize),

                    // ── Sign Up link ──────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: GoogleFonts.poppins(
                            fontSize: fontSize * 0.75,
                            color: Colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignUpPage(),
                                  ),
                                ),
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.poppins(
                              fontSize: fontSize * 0.75,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
