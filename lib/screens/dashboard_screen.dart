import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/health_provider.dart';
import '../providers/medication_provider.dart';
import '../providers/checkin_provider.dart';
import '../widgets/vital_card.dart';
import '../widgets/sync_status_indicator.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthProvider.notifier).checkPermissions();
      ref.read(healthProvider.notifier).refreshSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final health = ref.watch(healthProvider);
    final medState = ref.watch(medicationProvider);
    final checkin = ref.watch(checkinProvider);

    final firstName = auth.person?.firstName ?? 'there';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wellet',
          style: GoogleFonts.dmSerifDisplay(fontSize: 28),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(healthProvider.notifier).refreshSummary();
          await ref.read(medicationProvider.notifier).loadMedications();
          await ref.read(checkinProvider.notifier).loadTodayCheckin();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'Good ${_getTimeOfDay()}, $firstName',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 28,
                  color: WelletTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Sync status
              const SyncStatusIndicator(),
              const SizedBox(height: 24),

              // Health summary
              Text(
                "Today's Health",
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 24,
                  color: WelletTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              if (!health.permissionsGranted) ...[
                _buildPermissionCard(),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: VitalCard(
                        label: 'Steps',
                        value: '${health.steps}',
                        icon: Icons.directions_walk,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: VitalCard(
                        label: 'Heart Rate',
                        value: health.heartRate != null
                            ? '${health.heartRate} bpm'
                            : '--',
                        icon: Icons.favorite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                VitalCard(
                  label: 'Sleep',
                  value: health.sleepHours != null
                      ? '${health.sleepHours} hours'
                      : 'No data yet',
                  icon: Icons.bedtime,
                  fullWidth: true,
                ),
              ],
              const SizedBox(height: 28),

              // Check-in prompt
              if (!checkin.hasCheckedInToday) ...[
                _buildCheckinPrompt(),
                const SizedBox(height: 28),
              ],

              // Recent medications
              if (medState.recentLogs.isNotEmpty) ...[
                Text(
                  'Recent Medications',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 24,
                    color: WelletTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...medState.recentLogs.map((log) {
                  final med = medState.medications.where(
                    (m) => m.id == log.medicationId,
                  );
                  final name = med.isNotEmpty ? med.first.name : 'Medication';
                  final action = log.action == MedicationAction.took
                      ? 'Taken'
                      : 'Skipped';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: WelletTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            log.action == MedicationAction.took
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: log.action == MedicationAction.took
                                ? WelletTheme.success
                                : WelletTheme.error,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  action,
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
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WelletTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WelletTheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Data Access',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: WelletTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Wellet needs to read your health data so your family '
            "can see how you're doing. We never share this data with anyone else.",
            style: GoogleFonts.dmSans(
              fontSize: 18,
              color: WelletTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                ref.read(healthProvider.notifier).requestPermissions();
              },
              child: const Text('Allow Health Access'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinPrompt() {
    return GestureDetector(
      onTap: () => context.go('/checkin'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: WelletTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: WelletTheme.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "How are you today?",
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 22,
                      color: WelletTheme.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to share how you are feeling',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      color: WelletTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: WelletTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}
