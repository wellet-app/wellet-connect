import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/wellet_logo.dart';

/// Welcome / Get Started — moss-led per Wellet Connect Design Spec §5.
/// All text on moss surface uses full opacity, weight ≥ 500 (spec §11).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Light status bar icons over moss (spec §15).
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: WelletTheme.moss,
        body: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              32,
              24,
              24 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand lockup: cream wordmark + cream CONNECT pill on moss.
                const WelletConnectLockup(
                  surface: ConnectSurface.moss,
                  wordmarkHeight: 32,
                ),
                const SizedBox(height: 12),

                // Tagline — agentic per spec §5.
                Text(
                  'Your side of the care circle',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: WelletTheme.cream,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.02 * 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 56),

                // H1 — DM Serif Display 32, cream, line-height 1.18 (spec §5).
                Text(
                  'Welcome to\nWellet Connect',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 32,
                    color: WelletTheme.cream,
                    fontWeight: FontWeight.w400,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 16),

                // Body — DM Sans 16 warm-white full opacity, weight 500 (spec §11).
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Text(
                    'Sign in to choose what you share, with whom, '
                    'and when. Your record. Your call.',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: WelletTheme.warmWhite,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),

                const Spacer(),

                // Primary CTA: warm-white fill, moss-dark text (spec §7).
                Semantics(
                  button: true,
                  label: 'Get started',
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.go('/onboarding/invite'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WelletTheme.warmWhite,
                        foregroundColor: WelletTheme.mossDark,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Get Started',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: WelletTheme.mossDark,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Secondary "Sign in" — outlined cream on moss (spec §7).
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    style: TextButton.styleFrom(
                      foregroundColor: WelletTheme.cream,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Already have an account? ',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              color: WelletTheme.warmWhite,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: 'Sign in',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              color: WelletTheme.cream,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                              decorationColor: WelletTheme.cream,
                            ),
                          ),
                        ],
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
