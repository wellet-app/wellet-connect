import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/checkin_response.dart';
import '../providers/checkin_provider.dart';
import '../widgets/checkin_button.dart';

class CheckinScreen extends ConsumerWidget {
  const CheckinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkinState = ref.watch(checkinProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Check-in',
          style: GoogleFonts.dmSerifDisplay(fontSize: 28),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: checkinState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : checkinState.hasCheckedInToday
                  ? _buildAlreadyCheckedIn(checkinState.todayCheckin!)
                  : _buildCheckinPrompt(context, ref, checkinState),
        ),
      ),
    );
  }

  Widget _buildAlreadyCheckedIn(CheckinResponse response) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: WelletTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                response.moodEmoji,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "You've checked in today",
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 28,
              color: WelletTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You said: "${response.moodLabel}"',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              color: WelletTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thanks for checking in \u{1F49A} Your caregiver will see this.',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              color: WelletTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinPrompt(
    BuildContext context,
    WidgetRef ref,
    CheckinState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text(
          "How's your day\ngoing?",
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 36,
            color: WelletTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your family would love to know how you are feeling today.',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            color: WelletTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 40),
        CheckinButton(
          label: 'Good day',
          emoji: '\u{1F60A}',
          color: WelletTheme.success,
          isLoading: state.isSubmitting,
          onPressed: () => _submitCheckin(ref, CheckinMood.good),
        ),
        const SizedBox(height: 16),
        CheckinButton(
          label: 'Not great',
          emoji: '\u{1F614}',
          color: WelletTheme.primary,
          isLoading: state.isSubmitting,
          onPressed: () => _submitCheckin(ref, CheckinMood.notGreat),
        ),
        const SizedBox(height: 16),
        CheckinButton(
          label: 'Bad',
          emoji: '\u{1F198}',
          color: WelletTheme.error,
          isLoading: state.isSubmitting,
          onPressed: () => _submitCheckin(ref, CheckinMood.bad),
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  Future<void> _submitCheckin(WidgetRef ref, CheckinMood mood) async {
    HapticFeedback.heavyImpact();
    await ref.read(checkinProvider.notifier).submitCheckin(mood);
  }
}
