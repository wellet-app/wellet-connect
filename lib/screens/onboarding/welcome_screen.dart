import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WelletTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: WelletTheme.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: WelletTheme.primary.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'W',
                    style: GoogleFonts.dmSerifDisplay(
                      color: Colors.white,
                      fontSize: 48,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Heading
              Text(
                'Your family invited\nyou to Wellet Connect',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 32,
                  color: WelletTheme.textPrimary,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subheading
              Text(
                'This app helps your family stay connected to '
                'your health and well-being — so they can support '
                'you between visits.',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  color: WelletTheme.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // Get Started button
              Semantics(
                button: true,
                label: 'Get started',
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => context.go('/onboarding/invite'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WelletTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Get Started',
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sign in link
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'Already have an account? Sign in',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    color: WelletTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
