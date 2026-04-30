import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pairing_provider.dart';

/// Invite-code entry — moss-led per Wellet Connect Design Spec.
/// All on-moss text uses full opacity, weight ≥ 500 (spec §11).
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
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: WelletTheme.cream,
            ),
          ),
          backgroundColor: WelletTheme.red,
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: WelletTheme.moss,
        appBar: AppBar(
          backgroundColor: WelletTheme.moss,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: WelletTheme.cream,
              size: 20,
            ),
            onPressed: () => context.go('/onboarding/welcome'),
          ),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              0,
              24,
              24 + MediaQuery.of(context).padding.bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Step indicator — uppercase mint label per spec §3.
                  Text(
                    'STEP 1 OF 4',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: WelletTheme.mint,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 12 * 0.12, // 0.12em
                    ),
                  ),
                  const SizedBox(height: 12),

                  // H1 — DM Serif Display 32 cream on moss (spec §11).
                  Text(
                    'Enter your\ninvite code',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 32,
                      color: WelletTheme.cream,
                      fontWeight: FontWeight.w400,
                      height: 1.18,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Body — DM Sans 16 warm-white full opacity, weight 500.
                  Text(
                    'A family member sent you a code to connect '
                    'your accounts. You can find it in your email '
                    'or text messages.',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: WelletTheme.warmWhite,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Error — kept inside a warm-white card (spec §10:
                  // semantic colors never appear directly on moss).
                  if (pairing.error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: WelletTheme.warmWhite,
                        border: Border.all(
                          color: WelletTheme.cardBorderOnMoss,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: WelletTheme.red,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              pairing.error!,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: WelletTheme.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Invite-code input — warm-white fill, no border.
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
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 4,
                        color: WelletTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'ABC123',
                        hintStyle: GoogleFonts.dmSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 4,
                          color: WelletTheme.textMuted,
                        ),
                        filled: true,
                        fillColor: WelletTheme.warmWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: WelletTheme.mint,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
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
                  const SizedBox(height: 16),

                  // Continue — warm-white fill, moss-dark text (spec §7).
                  Semantics(
                    button: true,
                    label: 'Continue with invite code',
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            pairing.isValidating ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WelletTheme.warmWhite,
                          foregroundColor: WelletTheme.mossDark,
                          disabledBackgroundColor:
                              WelletTheme.warmWhite.withOpacity(0.5),
                          disabledForegroundColor:
                              WelletTheme.mossDark.withOpacity(0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: pairing.isValidating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: WelletTheme.mossDark,
                                ),
                              )
                            : Text(
                                'Continue',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: WelletTheme.mossDark,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Help text — mint full opacity, weight 500 on moss (spec §11).
                  Center(
                    child: Text(
                      "Can't find your code? Ask your family member "
                      'to send a new invite from the Wellet dashboard.',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: WelletTheme.mint,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
