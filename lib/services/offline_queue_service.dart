import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'supabase_service.dart';

part 'offline_queue_service.g.dart';

class QueuedOperations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tableName => text()();
  TextColumn get operation => text()(); // insert, upsert
  TextColumn get payload => text()(); // JSON-encoded row data
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [QueuedOperations])
class OfflineQueueDatabase extends _$OfflineQueueDatabase {
  OfflineQueueDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'wellet_offline_queue.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}

class OfflineQueueService {
  final OfflineQueueDatabase _db;
  final SupabaseService _supabaseService;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  OfflineQueueService(this._db, this._supabaseService);

  Future<void> initialize() async {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection =
          results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        flushQueue();
      }
    });
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
  }

  Future<void> enqueue({
    required String table,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    await _db.into(_db.queuedOperations).insert(
          QueuedOperationsCompanion.insert(
            tableName: table,
            operation: operation,
            payload: jsonEncode(data),
          ),
        );
  }

  Future<void> flushQueue() async {
    final items = await (_db.select(_db.queuedOperations)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();

    for (final item in items) {
      try {
        final data = jsonDecode(item.payload) as Map<String, dynamic>;

        switch (item.operation) {
          case 'insert':
            await _supabaseService.client
                .from(item.tableName)
                .insert(data);
            break;
          case 'upsert':
            await _supabaseService.client
                .from(item.tableName)
                .upsert(data);
            break;
        }

        // Remove from queue on success
        await (_db.delete(_db.queuedOperations)
              ..where((t) => t.id.equals(item.id)))
            .go();
      } catch (e) {
        // Increment retry count; skip for now and try again later
        await (_db.update(_db.queuedOperations)
              ..where((t) => t.id.equals(item.id)))
            .write(QueuedOperationsCompanion(
          retryCount: Value(item.retryCount + 1),
        ));
      }
    }
  }

  Future<int> get pendingCount async {
    final count = _db.queuedOperations.id.count();
    final query = _db.selectOnly(_db.queuedOperations)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<bool> get hasConnectivity async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
