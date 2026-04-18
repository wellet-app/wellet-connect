import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/checkin_response.dart';
import '../providers/checkin_provider.dart';

class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({super.key});

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  final _notesController = TextEditingController();
  bool _showNotes = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitCheckin(CheckinMood mood) async {
    HapticFeedback.heavyImpact();
    await ref.read(checkinProvider.notifier).submitCheckin(mood);
  }

  @override
  Widget build(BuildContext context) {
    final checkinState = ref.watch(checkinProvider);

    return Scaffold(
      backgroundColor: WelletTheme.background,
      appBar: AppBar(
        backgroundColor: WelletTheme.background,
        title: Text(
          'Daily Check-in',
          style: GoogleFonts.dmSerifDisplay(fontSize: 28),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: checkinState.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: WelletTheme.primary,
                    backgroundColor: WelletTheme.primary.withOpacity(0.15),
                  ),
                )
              : checkinState.hasCheckedInToday
                  ? _buildAlreadyCheckedIn(checkinState.todayCheckin!)
                  : _buildCheckinPrompt(checkinState),
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: WelletTheme.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: WelletTheme.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your family can see your update',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    color: WelletTheme.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinPrompt(CheckinState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text(
          "How are you\nfeeling today?",
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 36,
            color: WelletTheme.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your family would love to know how you are doing.',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            color: WelletTheme.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 40),

        // Mood buttons with icon-style indicators instead of emojis
        _buildMoodButton(
          icon: Icons.sentiment_very_satisfied,
          label: 'Good day',
          color: WelletTheme.success,
          isLoading: state.isSubmitting,
          onPressed: () => _submitCheckin(CheckinMood.good),
        ),
        const SizedBox(height: 16),
        _buildMoodButton(
          icon: Icons.sentiment_dissatisfied,
          label: 'Not great',
          color: WelletTheme.primary,
          isLoading: state.isSubmitting,
          onPressed: () => _submitCheckin(CheckinMood.notGreat),
        ),
        const SizedBox(height: 16),
        _buildMoodButton(
          icon: Icons.sentiment_very_dissatisfied,
          label: 'Struggling',
          color: WelletTheme.error,
          isLoading: state.isSubmitting,
          onPressed: () => _submitCheckin(CheckinMood.bad),
        ),

        const SizedBox(height: 24),

        // Optional notes toggle
        if (!_showNotes)
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _showNotes = true),
              icon: const Icon(
                Icons.add,
                size: 20,
                color: WelletTheme.primary,
              ),
              label: Text(
                'Add a note (optional)',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  color: WelletTheme.primary,
                ),
              ),
            ),
          ),

        if (_showNotes) ...[
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            style: GoogleFonts.dmSans(fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Anything you want to share...',
              filled: true,
              fillColor: WelletTheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],

        const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildMoodButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Semantics(
      button: true,
      label: '$label check-in',
      child: SizedBox(
        width: double.infinity,
        height: 72,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
