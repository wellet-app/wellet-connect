import 'package:health/health.dart';
import '../models/vital.dart';
import 'supabase_service.dart';

class HealthSyncService {
  final Health _health = Health();
  DateTime? _lastSyncTime;

  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.WEIGHT,
  ];

  static final List<HealthDataAccess> _permissions =
      List<HealthDataAccess>.filled(_types.length, HealthDataAccess.READ);

  Future<bool> requestPermissions() async {
    final hasPermissions = await _health.hasPermissions(_types,
        permissions: _permissions);
    if (hasPermissions == true) return true;

    return await _health.requestAuthorization(_types,
        permissions: _permissions);
  }

  Future<bool> hasPermissions() async {
    final result = await _health.hasPermissions(_types,
        permissions: _permissions);
    return result == true;
  }

  Future<List<Vital>> fetchHealthData(String personId) async {
    final now = DateTime.now();
    final start =
        _lastSyncTime ?? now.subtract(const Duration(hours: 24));

    final healthData = await _health.getHealthDataFromTypes(
      types: _types,
      startTime: start,
      endTime: now,
    );

    _lastSyncTime = now;

    final uniqueData = _dedupeHealthData(healthData);

    return uniqueData.map((point) {
      final numValue = _extractNumericValue(point.value);
      return Vital(
        personId: personId,
        vitalType: _healthTypeToVitalType(point.type),
        value: numValue.toString(),
        unit: _healthTypeToUnit(point.type),
        effectiveDate: point.dateFrom,
        source: 'apple_health',
      );
    }).toList();
  }

  Future<void> syncToSupabase(
      SupabaseService supabaseService, String personId) async {
    final vitals = await fetchHealthData(personId);
    if (vitals.isEmpty) return;

    // Write to vitals table
    await supabaseService.upsertVitals(vitals);

    // Also write to health_events table for timeline visibility
    final healthEvents = _buildHealthEvents(vitals, personId);
    await supabaseService.insertHealthEvents(healthEvents);
  }

  List<Map<String, dynamic>> _buildHealthEvents(
      List<Vital> vitals, String personId) {
    final events = <Map<String, dynamic>>[];

    // Aggregate steps
    double totalSteps = 0;
    DateTime? latestStepDate;
    for (final v in vitals) {
      if (v.vitalType == 'Steps') {
        totalSteps += v.numericValue;
        final d = v.effectiveDate;
        if (d != null && (latestStepDate == null || d.isAfter(latestStepDate))) {
          latestStepDate = d;
        }
      }
    }
    if (totalSteps > 0) {
      events.add({
        'person_id': personId,
        'event_type': 'activity',
        'event_date': (latestStepDate ?? DateTime.now()).toIso8601String(),
        'title': '${totalSteps.toInt()} steps',
        'value': totalSteps,
        'unit': 'steps',
        'source': 'apple_health',
        'accepted': true,
      });
    }

    // Aggregate sleep
    double totalSleepMin = 0;
    DateTime? latestSleepDate;
    for (final v in vitals) {
      if (v.vitalType == 'Sleep') {
        totalSleepMin += v.numericValue;
        final d = v.effectiveDate;
        if (d != null &&
            (latestSleepDate == null || d.isAfter(latestSleepDate))) {
          latestSleepDate = d;
        }
      }
    }
    if (totalSleepMin > 0) {
      final hours = (totalSleepMin / 60.0).toStringAsFixed(1);
      events.add({
        'person_id': personId,
        'event_type': 'sleep',
        'event_date': (latestSleepDate ?? DateTime.now()).toIso8601String(),
        'title': '$hours hours of sleep',
        'value': totalSleepMin,
        'unit': 'min',
        'source': 'apple_health',
        'accepted': true,
      });
    }

    // Individual vital events (heart rate, BP, blood oxygen, weight)
    for (final v in vitals) {
      if (v.vitalType == 'Steps' || v.vitalType == 'Sleep') continue;

      events.add({
        'person_id': personId,
        'event_type': 'vital',
        'event_date':
            (v.effectiveDate ?? DateTime.now()).toIso8601String(),
        'title': '${v.vitalType}: ${v.value} ${v.unit ?? ''}',
        'value': v.numericValue,
        'unit': v.unit,
        'source': 'apple_health',
        'accepted': true,
      });
    }

    return events;
  }

  /// Map HealthDataType to the vital_type strings expected by the DB
  static String _healthTypeToVitalType(HealthDataType type) {
    switch (type) {
      case HealthDataType.STEPS:
        return 'Steps';
      case HealthDataType.HEART_RATE:
        return 'Heart Rate';
      case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
        return 'Blood Pressure Systolic';
      case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
        return 'Blood Pressure Diastolic';
      case HealthDataType.BLOOD_OXYGEN:
        return 'Blood Oxygen';
      case HealthDataType.SLEEP_ASLEEP:
        return 'Sleep';
      case HealthDataType.WEIGHT:
        return 'Weight';
      default:
        return type.name;
    }
  }

  /// Map HealthDataType to the unit strings expected by the DB
  static String _healthTypeToUnit(HealthDataType type) {
    switch (type) {
      case HealthDataType.STEPS:
        return 'steps';
      case HealthDataType.HEART_RATE:
        return 'bpm';
      case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
      case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
        return 'mmHg';
      case HealthDataType.BLOOD_OXYGEN:
        return '%';
      case HealthDataType.SLEEP_ASLEEP:
        return 'min';
      case HealthDataType.WEIGHT:
        return 'kg';
      default:
        return '';
    }
  }

  /// Manual dedupe to replace the removed Health.removeDuplicates static.
  /// Two points are considered duplicates if their type, dateFrom, dateTo,
  /// and numeric value all match. Stable order: keeps first occurrence.
  static List<HealthDataPoint> _dedupeHealthData(
      List<HealthDataPoint> points) {
    final seen = <String>{};
    final result = <HealthDataPoint>[];
    for (final p in points) {
      final num = _extractNumericValue(p.value);
      final key =
          '${p.type}|${p.dateFrom.toIso8601String()}|${p.dateTo.toIso8601String()}|$num';
      if (seen.add(key)) result.add(p);
    }
    return result;
  }

  static double _extractNumericValue(HealthValue value) {
    if (value is NumericHealthValue) {
      return value.numericValue.toDouble();
    }
    return 0.0;
  }

  // Summary helpers for dashboard

  Future<Map<String, dynamic>> getTodaySummary() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final data = await _health.getHealthDataFromTypes(
      types: _types,
      startTime: startOfDay,
      endTime: now,
    );

    final unique = _dedupeHealthData(data);

    double steps = 0;
    double? latestHeartRate;
    double? sleepHours;

    for (final point in unique) {
      final value = _extractNumericValue(point.value);
      switch (point.type) {
        case HealthDataType.STEPS:
          steps += value;
          break;
        case HealthDataType.HEART_RATE:
          latestHeartRate = value;
          break;
        case HealthDataType.SLEEP_ASLEEP:
          sleepHours = (sleepHours ?? 0) + (value / 60.0);
          break;
        default:
          break;
      }
    }

    return {
      'steps': steps.toInt(),
      'heart_rate': latestHeartRate?.toInt(),
      'sleep_hours': sleepHours != null
          ? double.parse(sleepHours.toStringAsFixed(1))
          : null,
    };
  }
}
