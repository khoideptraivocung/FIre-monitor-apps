import 'package:flutter_test/flutter_test.dart';
import 'package:fire_monitor_app/models/fire_data.dart';
import 'package:fire_monitor_app/models/control_data.dart';
import 'package:fire_monitor_app/models/log_event.dart';

void main() {
  group('FireData Model Tests', () {
    test('Should parse valid JSON correctly', () {
      final json = {
        'temperature': 25.5,
        'humidity': 60.0,
        'gasADC': 320,
        'gasStatus': 'SAFE',
        'flameDetected': false,
        'fireRisk': false,
        'fanStatus': true,
      };

      final data = FireData.fromJson(json);

      expect(data.temperature, 25.5);
      expect(data.humidity, 60.0);
      expect(data.gasADC, 320);
      expect(data.gasStatus, 'SAFE');
      expect(data.flameDetected, false);
      expect(data.fireRisk, false);
      expect(data.fanStatus, true);
    });

    test('Should handle null/missing values and fallback to defaults', () {
      final json = <dynamic, dynamic>{};
      final data = FireData.fromJson(json);

      expect(data.temperature, 0.0);
      expect(data.humidity, 0.0);
      expect(data.gasADC, 0);
      expect(data.gasStatus, 'SAFE');
      expect(data.flameDetected, false);
      expect(data.fireRisk, false);
      expect(data.fanStatus, false);
    });

    test('Should convert int to double for temperature/humidity safely', () {
      final json = {
        'temperature': 25,
        'humidity': 60,
      };
      final data = FireData.fromJson(json);

      expect(data.temperature, 25.0);
      expect(data.humidity, 60.0);
    });
  });

  group('ControlData Model Tests', () {
    test('Should parse control settings correctly', () {
      final json = {
        'mode': 'manual',
        'fan': true,
      };
      final data = ControlData.fromJson(json);

      expect(data.mode, 'MANUAL');
      expect(data.fan, true);
      expect(data.isAuto, false);
    });

    test('Should default to AUTO when missing fields', () {
      final json = <dynamic, dynamic>{};
      final data = ControlData.fromJson(json);

      expect(data.mode, 'AUTO');
      expect(data.fan, false);
      expect(data.isAuto, true);
    });
  });

  group('LogEvent Model Tests', () {
    test('Should parse log event successfully', () {
      final json = {
        'timestamp': 1718175600000,
        'eventType': 'Flame Detected',
        'description': 'Flame sensor detected fire!',
      };
      final data = LogEvent.fromJson('log_123', json);

      expect(data.id, 'log_123');
      expect(data.timestamp, 1718175600000);
      expect(data.eventType, 'Flame Detected');
      expect(data.description, 'Flame sensor detected fire!');
      expect(data.dateTime, DateTime.fromMillisecondsSinceEpoch(1718175600000));
    });
  });
}
