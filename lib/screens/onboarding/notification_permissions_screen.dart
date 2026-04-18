import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/notification_service.dart';
import '../../providers/medication_provider.dart';

class NotificationPermissionsScreen extends ConsumerStatefulWidget {
  const NotificationPermissionsScreen({super.key});

  @override
  ConsumerState<NotificationPermissionsScreen> createState() =>
      _NotificationPermissionsScreenState();
}

class _NotificationPermissionsScreenState
    extends ConsumerState<NotificationPermissionsScreen> {
  bool _isRequesting = false;

  Future<void> _requestNotifications() async {
    setState(() => _isRequesting = true);
    HapticFeedback.mediumImpact();

    final notificationService = ref.read(notificationServiceProvider);
    if (notificationService != null) {
      await notificationService.initialize();
      await notificationService.scheduleDailyCheckinReminder();
    }

    if (mounted) {
      setState(() => _isRequesting = false);
      context.go('/onboarding/sync');
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
          onPressed: () => context.go('/onboarding/health'),
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
                'Step 3 of 4',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  color: WelletTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Stay in the loop',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 32,
                  color: WelletTheme.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                "We'll remind you to check in and let you "
                'know when your family has updates for you.',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  color: WelletTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Notification preview cards
              _buildNotificationPreview(
                icon: Icons.wb_sunny_outlined,
                title: 'Daily check-in reminder',
                body: 'A gentle nudge each morning to share how you are feeling.',
              ),
              const SizedBox(height: 16),
              _buildNotificationPreview(
                icon: Icons.medication_outlined,
                title: 'Medication reminders',
                body: 'Timely reminders so you never miss a dose.',
              ),
              const SizedBox(height: 16),
              _buildNotificationPreview(
                icon: Icons.people_outline,
                title: 'Family updates',
                body: "Know when your family sends you a message or update.",
              ),

              const Spacer(),

              // Allow button
              Semantics(
                button: true,
                label: 'Allow notifications',
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed:
                        _isRequesting ? null : _requestNotifications,
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
                            'Allow Notifications',
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
                  onPressed: () => context.go('/onboarding/sync'),
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

  Widget _buildNotificationPreview({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
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
                  body,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    color: WelletTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
