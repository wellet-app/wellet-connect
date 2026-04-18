import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../providers/health_provider.dart';

class FirstSyncScreen extends ConsumerStatefulWidget {
  const FirstSyncScreen({super.key});

  @override
  ConsumerState<FirstSyncScreen> createState() => _FirstSyncScreenState();
}

class _FirstSyncScreenState extends ConsumerState<FirstSyncScreen>
    with SingleTickerProviderStateMixin {
  bool _isSyncing = true;
  bool _isComplete = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _performFirstSync();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _performFirstSync() async {
    // Run the first health data sync
    try {
      await ref.read(healthProvider.notifier).syncToCloud();
    } catch (_) {
      // Sync failure is not blocking — we'll retry later
    }

    // Mark onboarding as complete
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _isComplete = true;
      });
      HapticFeedback.heavyImpact();
      _animationController.forward();

      // Auto-navigate after a brief delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        context.go('/');
      }
    }
  }

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

              if (_isSyncing) ...[
                // Syncing state
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: WelletTheme.primary,
                    backgroundColor: WelletTheme.primary.withOpacity(0.15),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Setting things up...',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 28,
                    color: WelletTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Syncing your health data for the first time. '
                  'This will only take a moment.',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    color: WelletTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              if (_isComplete) ...[
                // Complete state
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: WelletTheme.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: WelletTheme.success,
                          size: 56,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'All set!',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 32,
                          color: WelletTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your family can now see how you are doing. '
                        "We'll keep everything in sync automatically.",
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          color: WelletTheme.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(flex: 3),

              // Step indicator
              Text(
                'Step 4 of 4',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  color: WelletTheme.primary,
                  fontWeight: FontWeight.w700,
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
