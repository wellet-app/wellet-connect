import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendMagicLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await ref.read(authProvider.notifier).sendMagicLink(
          email: _emailController.text.trim(),
        );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                // Logo / Brand
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: WelletTheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'W',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Welcome heading
                Text(
                  'Welcome to\nWellet Connect',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 32,
                    color: WelletTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sign in to stay connected with your family.',
                  style: GoogleFonts.dmSans(
                    fontSize: AppConstants.minFontSize,
                    color: WelletTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Error message
                if (authState.error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: WelletTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      authState.error!,
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        color: WelletTheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Magic link sent confirmation
                if (authState.magicLinkSent) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: WelletTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: WelletTheme.success.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.mark_email_read,
                              color: WelletTheme.success,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Check your email',
                              style: GoogleFonts.dmSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: WelletTheme.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'We sent a sign-in link to ${_emailController.text.trim()}. '
                          'Tap the link in the email to sign in.',
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            color: WelletTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Email field
                Semantics(
                  label: 'Email address',
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    style:
                        GoogleFonts.dmSans(fontSize: AppConstants.minFontSize),
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      hintText: 'you@example.com',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Send magic link button
                Semantics(
                  button: true,
                  label: 'Send sign-in link',
                  child: SizedBox(
                    width: double.infinity,
                    height: AppConstants.minTouchTarget,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSendMagicLink,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              authState.magicLinkSent
                                  ? 'Resend Link'
                                  : 'Send Sign-in Link',
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Privacy note
                Text(
                  AppConstants.privacyMessage,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    color: WelletTheme.textSecondary,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
