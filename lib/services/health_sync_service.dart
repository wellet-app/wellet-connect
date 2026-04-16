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

  static const List<HealthDataAccess> _permissions =
      [for (var _ in _types) HealthDataAccess.READ];

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

    final uniqueData = Health.removeDuplicates(healthData);

    return uniqueData.map((point) {
      return Vital(
        personId: personId,
        type: _healthTypeToString(point.type),
        value: _extractNumericValue(point.value),
        unit: point.unitString,
        recordedAt: point.dateFrom,
      );
    }).toList();
  }

  Future<void> syncToSupabase(
      SupabaseService supabaseService, String personId) async {
    final vitals = await fetchHealthData(personId);
    if (vitals.isNotEmpty) {
      await supabaseService.upsertVitals(vitals);
    }
  }

  static String _healthTypeToString(HealthDataType type) {
    switch (type) {
      case HealthDataType.STEPS:
        return 'steps';
      case HealthDataType.HEART_RATE:
        return 'heart_rate';
      case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
        return 'blood_pressure_systolic';
      case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
        return 'blood_pressure_diastolic';
      case HealthDataType.BLOOD_OXYGEN:
        return 'blood_oxygen';
      case HealthDataType.SLEEP_ASLEEP:
        return 'sleep';
      case HealthDataType.WEIGHT:
        return 'weight';
      default:
        return type.name.toLowerCase();
    }
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

    final unique = Health.removeDuplicates(data);

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
