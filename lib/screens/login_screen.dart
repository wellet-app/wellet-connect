import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/wellet_logo.dart';

// Hardcoded test credentials used by the debug-only "Skip auth" button.
// Never shipped in release builds (see kDebugMode guard below).
const _kDevTestEmail = 'betsy.eble@gmail.com';
const _kDevTestPassword = 'WC-6eUfw4VGlRNvpr7H';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  // Snapshot of the email at submission so the confirmation message survives
  // controller clears or widget rebuilds.
  String _submittedEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendMagicLink() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    setState(() {
      _isLoading = true;
      _submittedEmail = email;
    });

    await ref.read(authProvider.notifier).sendMagicLink(email: email);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSkipAuth() async {
    setState(() => _isLoading = true);
    await ref.read(authProvider.notifier).signInWithPassword(
          email: _kDevTestEmail,
          password: _kDevTestPassword,
        );
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Status bar: light icons on moss bg, per spec §5 + §15.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Android
        statusBarBrightness: Brightness.dark, // iOS (dark = light icons)
      ),
      child: Scaffold(
        // Moss-led surface — Connect's default identity.
        backgroundColor: WelletTheme.moss,
        body: SafeArea(
          // Top-only safe area; bottom uses MediaQuery padding so the CTA
          // hovers above the home indicator without floating mid-air (spec §15).
          bottom: false,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              24,
              32, // breathing room below status bar
              24,
              MediaQuery.of(context).padding.bottom + 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Identity ─────────────────────────────────────────
                  const WelletConnectLockup(
                    wordmarkHeight: 32,
                    surface: ConnectSurface.moss,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your side of the care circle',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: WelletTheme.cream.withOpacity(0.85),
                    ),
                  ),

                  const SizedBox(height: 56),

                  // ─── Welcome ──────────────────────────────────────────
                  Text(
                    'Welcome to Wellet Connect',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: WelletTheme.cream,
                      height: 1.18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Text(
                      'Sign in to choose what you share, with whom, and when. '
                      'Your record. Your call.',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: WelletTheme.warmWhite.withOpacity(0.85),
                        height: 1.55,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ─── Error ────────────────────────────────────────────
                  if (authState.error != null) ...[
                    _ErrorBanner(message: authState.error!),
                    const SizedBox(height: 16),
                  ],

                  // ─── Magic-link sent confirmation ─────────────────────
                  if (authState.magicLinkSent) ...[
                    _MagicLinkSentCard(submittedEmail: _submittedEmail),
                    const SizedBox(height: 16),
                  ],

                  // ─── Email input ──────────────────────────────────────
                  Semantics(
                    label: 'Email address',
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: WelletTheme.textPrimary,
                      ),
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

                  const SizedBox(height: 16),

                  // ─── Primary CTA ──────────────────────────────────────
                  Semantics(
                    button: true,
                    label: 'Send sign-in link',
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSendMagicLink,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: WelletTheme.mossDark,
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

                  // ─── DEBUG-ONLY skip-auth ─────────────────────────────
                  if (kDebugMode) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleSkipAuth,
                        icon: const Icon(Icons.bolt_outlined, size: 20),
                        label: const Text('Skip auth (test mode)'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Debug build only · signs in as $_kDevTestEmail',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: WelletTheme.cream.withOpacity(0.65),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ─── Privacy card (mint, on moss) ─────────────────────
                  const _PrivacyCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WelletTheme.warmWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WelletTheme.cardBorderOnMoss),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: WelletTheme.red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: WelletTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MagicLinkSentCard extends StatelessWidget {
  final String submittedEmail;
  const _MagicLinkSentCard({required this.submittedEmail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WelletTheme.warmWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WelletTheme.cardBorderOnMoss),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                color: WelletTheme.moss,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Check your email',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: WelletTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            submittedEmail.isNotEmpty
                ? 'We sent a sign-in link to $submittedEmail. '
                    'Tap the link in the email to sign in.'
                : 'We sent you a sign-in link. Tap the link in the email to '
                    'sign in.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: WelletTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: WelletTheme.mint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline,
            color: WelletTheme.mintDeep,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your health information is encrypted and only seen by people '
              'you invite.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: WelletTheme.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
