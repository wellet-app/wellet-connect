import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/medication.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onTookIt;
  final VoidCallback onSkipped;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.onTookIt,
    required this.onSkipped,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Medication: ${medication.name}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: WelletTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medication name
            Text(
              medication.name,
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 24,
                color: WelletTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // Dose and frequency
            if (medication.dose != null || medication.frequency != null)
              Text(
                [medication.dose, medication.frequency]
                    .where((s) => s != null)
                    .join(' \u2022 '),
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  color: WelletTheme.textSecondary,
                ),
              ),

            // Reminder times
            if (medication.reminderTimes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: WelletTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 18,
                      color: WelletTheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      medication.reminderTimes
                          .map(_formatTime)
                          .join(', '),
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: WelletTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Mark ${medication.name} as taken',
                    child: SizedBox(
                      height: AppConstants.minTouchTarget,
                      child: ElevatedButton.icon(
                        onPressed: onTookIt,
                        icon: const Icon(Icons.check, size: 24),
                        label: Text(
                          'Took it',
                          style: GoogleFonts.dmSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WelletTheme.success,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Mark ${medication.name} as skipped',
                    child: SizedBox(
                      height: AppConstants.minTouchTarget,
                      child: OutlinedButton.icon(
                        onPressed: onSkipped,
                        icon: const Icon(Icons.close, size: 24),
                        label: Text(
                          'Skipped',
                          style: GoogleFonts.dmSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: WelletTheme.textSecondary,
                          side: const BorderSide(
                            color: WelletTheme.textSecondary,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return time;
    var hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $period';
  }
}
