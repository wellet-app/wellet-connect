import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/health_provider.dart';
import '../providers/medication_provider.dart';
import '../providers/checkin_provider.dart';
import '../providers/pairing_provider.dart';
import '../models/medication_log.dart';
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
    final pairing = ref.watch(pairingProvider);

    final firstName = auth.person?.firstName ?? 'there';

    return Scaffold(
      backgroundColor: WelletTheme.background,
      appBar: AppBar(
        backgroundColor: WelletTheme.background,
        title: Text(
          'Wellet',
          style: GoogleFonts.dmSerifDisplay(fontSize: 28),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: WelletTheme.primary,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await ref.read(healthProvider.notifier).refreshSummary();
          await ref.read(medicationProvider.notifier).loadMedications();
          await ref.read(checkinProvider.notifier).loadTodayCheckin();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
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
              const SizedBox(height: 8),

              // Connected caregiver
              if (pairing.isPaired && pairing.caregiverName != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: WelletTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 18,
                        color: WelletTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Connected to ${pairing.caregiverName}'s care circle",
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: WelletTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Check-in prompt
              if (!checkin.hasCheckedInToday) ...[
                _buildCheckinPrompt(),
                const SizedBox(height: 24),
              ],

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
                  final name =
                      med.isNotEmpty ? med.first.name : 'Medication';
                  final action = log.action == MedicationAction.took
                      ? 'Taken'
                      : 'Skipped';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: WelletTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: log.action == MedicationAction.took
                                  ? WelletTheme.success.withOpacity(0.1)
                                  : WelletTheme.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              log.action == MedicationAction.took
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: log.action == MedicationAction.took
                                  ? WelletTheme.success
                                  : WelletTheme.error,
                              size: 22,
                            ),
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
                                    color: WelletTheme.textPrimary,
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

              if (medState.recentLogs.isEmpty &&
                  medState.medications.isEmpty) ...[
                Text(
                  'Medications',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 24,
                    color: WelletTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: WelletTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.medication_outlined,
                        size: 40,
                        color: WelletTheme.textSecondary.withOpacity(0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No medications yet',
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: WelletTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your family can add medications from the Wellet dashboard.',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: WelletTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
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
        color: WelletTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WelletTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: WelletTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.favorite_outline,
                  color: WelletTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Health Data Access',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: WelletTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Wellet needs to read your health data so your family '
            "can see how you're doing between visits.",
            style: GoogleFonts.dmSans(
              fontSize: 18,
              color: WelletTheme.textSecondary,
              height: 1.4,
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
      onTap: () {
        HapticFeedback.lightImpact();
        context.go('/checkin');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: WelletTheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: WelletTheme.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: WelletTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.wb_sunny_outlined,
                color: WelletTheme.primaryDark,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
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
                  const SizedBox(height: 2),
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
              size: 18,
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
