import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/pairing_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final pairing = ref.watch(pairingProvider);

    return Scaffold(
      backgroundColor: WelletTheme.background,
      appBar: AppBar(
        backgroundColor: WelletTheme.background,
        title: Text(
          'Settings',
          style: GoogleFonts.dmSerifDisplay(fontSize: 28),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile section
            Text(
              'Your Account',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: WelletTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: WelletTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: WelletTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            (auth.person?.firstName?.isNotEmpty == true
                                    ? auth.person!.firstName![0]
                                    : 'U')
                                .toUpperCase(),
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 24,
                              color: WelletTheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.person?.displayName ?? 'Your Account',
                              style: GoogleFonts.dmSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: WelletTheme.textPrimary,
                              ),
                            ),
                            if (auth.user?.email != null)
                              Text(
                                auth.user!.email!,
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
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Care Circle section
            Text(
              'Care Circle',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: WelletTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: WelletTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  if (pairing.isPaired) ...[
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: WelletTheme.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.people,
                            color: WelletTheme.success,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Connected',
                                style: GoogleFonts.dmSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: WelletTheme.success,
                                ),
                              ),
                              if (pairing.caregiverName != null)
                                Text(
                                  "${pairing.caregiverName}'s care circle",
                                  style: GoogleFonts.dmSans(
                                    fontSize: 18,
                                    color: WelletTheme.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _buildSettingsButton(
                      icon: Icons.link_off,
                      label: 'Unpair from care circle',
                      color: WelletTheme.error,
                      onTap: () => _showUnpairDialog(context, ref),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: WelletTheme.textSecondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.people_outline,
                            color: WelletTheme.textSecondary.withOpacity(0.5),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Not connected to a care circle',
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              color: WelletTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Preferences section
            Text(
              'Preferences',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: WelletTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: WelletTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSettingsRow(
                    icon: Icons.sync,
                    label: 'Sync frequency',
                    value: 'Every 4 hours',
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildSettingsRow(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    value: 'Enabled',
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildSettingsRow(
                    icon: Icons.wb_sunny_outlined,
                    label: 'Check-in reminder',
                    value: '10:00 AM',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sign out
            Text(
              'Account',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: WelletTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: WelletTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildSettingsButton(
                icon: Icons.logout,
                label: 'Sign out',
                color: WelletTheme.error,
                onTap: () => _showSignOutDialog(context, ref),
              ),
            ),
            const SizedBox(height: 32),

            // App version
            Center(
              child: Text(
                'Wellet Connect v1.0.0',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: WelletTheme.textSecondary.withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: WelletTheme.primary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 20,
                color: WelletTheme.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              color: WelletTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnpairDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: WelletTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Unpair from care circle?',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 24,
            color: WelletTheme.textPrimary,
          ),
        ),
        content: Text(
          'Your family will no longer be able to see your health data '
          'or check-ins. You can reconnect later with a new invite code.',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            color: WelletTheme.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                color: WelletTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(pairingProvider.notifier).unpair();
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Unpair',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: WelletTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: WelletTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Sign out?',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 24,
            color: WelletTheme.textPrimary,
          ),
        ),
        content: Text(
          'You can sign back in anytime using your email address.',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            color: WelletTheme.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                color: WelletTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(authProvider.notifier).signOut();
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: WelletTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
