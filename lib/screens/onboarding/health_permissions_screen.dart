import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/health_provider.dart';

class HealthPermissionsScreen extends ConsumerStatefulWidget {
  const HealthPermissionsScreen({super.key});

  @override
  ConsumerState<HealthPermissionsScreen> createState() =>
      _HealthPermissionsScreenState();
}

class _HealthPermissionsScreenState
    extends ConsumerState<HealthPermissionsScreen> {
  bool _isRequesting = false;

  Future<void> _requestPermissions() async {
    setState(() => _isRequesting = true);
    HapticFeedback.mediumImpact();

    await ref.read(healthProvider.notifier).requestPermissions();

    if (mounted) {
      setState(() => _isRequesting = false);
      context.go('/onboarding/notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WelletTheme.background,
      appBar: AppBar(
        backgroundColor: WelletTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/onboarding/invite'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Step indicator
              Text(
                'Step 2 of 4',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  color: WelletTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Share your\nhealth data',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 32,
                  color: WelletTheme.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'This helps your family stay informed about '
                'your health between visits. Only the data you '
                'approve will be shared.',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  color: WelletTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Health data checklist
              _buildHealthItem(
                icon: Icons.favorite_outline,
                title: 'Heart rate',
                subtitle: 'Resting and active heart rate readings',
              ),
              _buildHealthItem(
                icon: Icons.directions_walk,
                title: 'Steps',
                subtitle: 'Daily step count and activity',
              ),
              _buildHealthItem(
                icon: Icons.bedtime_outlined,
                title: 'Sleep',
                subtitle: 'Hours of sleep each night',
              ),
              _buildHealthItem(
                icon: Icons.monitor_heart_outlined,
                title: 'Blood pressure',
                subtitle: 'Systolic and diastolic readings',
              ),

              const Spacer(),

              // Allow button
              Semantics(
                button: true,
                label: 'Allow health data access',
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isRequesting ? null : _requestPermissions,
                    child: _isRequesting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Allow Health Access',
                            style: GoogleFonts.dmSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Skip option
              Center(
                child: TextButton(
                  onPressed: () => context.go('/onboarding/notifications'),
                  child: Text(
                    'Set up later',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      color: WelletTheme.textSecondary,
                    ),
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

  Widget _buildHealthItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WelletTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: WelletTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: WelletTheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: WelletTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: WelletTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.check_circle,
              color: WelletTheme.primary.withOpacity(0.4),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
