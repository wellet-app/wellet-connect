import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../providers/health_provider.dart';
import '../services/offline_queue_service.dart';
import '../providers/medication_provider.dart';

enum SyncState { synced, syncing, offline }

class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(healthProvider);
    final offlineQueue = ref.watch(offlineQueueProvider);

    final syncState = health.isSyncing
        ? SyncState.syncing
        : SyncState.synced;

    return Semantics(
      label: 'Sync status: ${_stateLabel(syncState)}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _stateColor(syncState).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (syncState == SyncState.syncing)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: WelletTheme.primary,
                ),
              )
            else
              Icon(
                _stateIcon(syncState),
                size: 18,
                color: _stateColor(syncState),
              ),
            const SizedBox(width: 8),
            Text(
              _stateLabel(syncState),
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _stateColor(syncState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stateLabel(SyncState state) {
    switch (state) {
      case SyncState.synced:
        return 'Synced';
      case SyncState.syncing:
        return 'Syncing...';
      case SyncState.offline:
        return 'Offline — will sync later';
    }
  }

  Color _stateColor(SyncState state) {
    switch (state) {
      case SyncState.synced:
        return WelletTheme.success;
      case SyncState.syncing:
        return WelletTheme.primary;
      case SyncState.offline:
        return WelletTheme.textSecondary;
    }
  }

  IconData _stateIcon(SyncState state) {
    switch (state) {
      case SyncState.synced:
        return Icons.cloud_done;
      case SyncState.syncing:
        return Icons.sync;
      case SyncState.offline:
        return Icons.cloud_off;
    }
  }
}
