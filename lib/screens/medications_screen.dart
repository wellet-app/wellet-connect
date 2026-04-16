import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/medication_log.dart';
import '../providers/medication_provider.dart';
import '../widgets/medication_card.dart';

class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medState = ref.watch(medicationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Medications',
          style: GoogleFonts.dmSerifDisplay(fontSize: 28),
        ),
      ),
      body: medState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : medState.medications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(medicationProvider.notifier).loadMedications(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: medState.medications.length,
                    itemBuilder: (context, index) {
                      final medication = medState.medications[index];
                      return MedicationCard(
                        medication: medication,
                        onTookIt: () async {
                          HapticFeedback.heavyImpact();
                          await ref
                              .read(medicationProvider.notifier)
                              .logMedication(
                                medicationId: medication.id,
                                action: MedicationAction.took,
                              );
                          if (context.mounted) {
                            _showConfirmation(
                              context,
                              '${medication.name} marked as taken',
                              isPositive: true,
                            );
                          }
                        },
                        onSkipped: () async {
                          HapticFeedback.mediumImpact();
                          await ref
                              .read(medicationProvider.notifier)
                              .logMedication(
                                medicationId: medication.id,
                                action: MedicationAction.skipped,
                              );
                          if (context.mounted) {
                            _showConfirmation(
                              context,
                              '${medication.name} marked as skipped',
                              isPositive: false,
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.medication_outlined,
              size: 64,
              color: WelletTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No medications yet',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 24,
                color: WelletTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your family member can add medications from the Wellet dashboard.',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                color: WelletTheme.textSecondary,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmation(
    BuildContext context,
    String message, {
    required bool isPositive,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isPositive ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.dmSans(fontSize: 18),
              ),
            ),
          ],
        ),
        backgroundColor: isPositive ? WelletTheme.success : WelletTheme.textSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
