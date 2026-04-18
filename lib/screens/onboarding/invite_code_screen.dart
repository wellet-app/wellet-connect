import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pairing_provider.dart';

class InviteCodeScreen extends ConsumerStatefulWidget {
  const InviteCodeScreen({super.key});

  @override
  ConsumerState<InviteCodeScreen> createState() => _InviteCodeScreenState();
}

class _InviteCodeScreenState extends ConsumerState<InviteCodeScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = ref.read(authProvider);
    final userId = auth.user?.id;
    final userEmail = auth.user?.email;

    if (userId == null || userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please sign in first.',
            style: GoogleFonts.dmSans(fontSize: 18),
          ),
          backgroundColor: WelletTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final success =
        await ref.read(pairingProvider.notifier).validateAndAcceptInvite(
              code: _codeController.text.trim(),
              userId: userId,
              userEmail: userEmail,
            );

    if (success && mounted) {
      context.go('/onboarding/health');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pairing = ref.watch(pairingProvider);

    return Scaffold(
      backgroundColor: WelletTheme.background,
      appBar: AppBar(
        backgroundColor: WelletTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/onboarding/welcome'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Step indicator
                Text(
                  'Step 1 of 4',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    color: WelletTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Enter your\ninvite code',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 32,
                    color: WelletTheme.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Your family member sent you a code to connect '
                  'your accounts. You can find it in your email or '
                  'text messages.',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    color: WelletTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Error message
                if (pairing.error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: WelletTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: WelletTheme.error,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            pairing.error!,
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              color: WelletTheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Invite code field
                Semantics(
                  label: 'Invite code',
                  child: TextFormField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9]')),
                    ],
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'ABC123',
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 4,
                        color: WelletTheme.textSecondary.withOpacity(0.4),
                      ),
                      filled: true,
                      fillColor: WelletTheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: WelletTheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your invite code';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Continue button
                Semantics(
                  button: true,
                  label: 'Continue with invite code',
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: pairing.isValidating ? null : _handleSubmit,
                      child: pairing.isValidating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Continue',
                              style: GoogleFonts.dmSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Help text
                Center(
                  child: Text(
                    "Can't find your code? Ask your family member "
                    'to send a new invite from the Wellet dashboard.',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: WelletTheme.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
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
