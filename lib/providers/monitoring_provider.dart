import 'dart:async';
import 'package:flutter/material.dart';
import '../models/fire_data.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class MonitoringProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  FireData? _fireData;
  bool _isLoading = true;
  StreamSubscription<FireData?>? _subscription;

  // Cache previous state to prevent alert/log duplication
  bool _prevFireRisk = false;
  bool _prevFlameDetected = false;
  String _prevGasStatus = 'SAFE';
  bool? _prevFanStatus;

  FireData? get fireData => _fireData;
  bool get isLoading => _isLoading;

  MonitoringProvider() {
    _initStream();
  }

  void _initStream() {
    _subscription = _dbService.fireDataStream.listen((data) {
      _isLoading = false;
      if (data != null) {
        _checkThresholdsAndAlert(data);
        _fireData = data;
      }
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Evaluates sensor thresholds to dispatch local notifications and update safety logs
  Future<void> _checkThresholdsAndAlert(FireData data) async {
    // 1. Critical Fire Risk
    if (data.fireRisk && !_prevFireRisk) {
      await _notificationService.showNotification(
        id: 1,
        title: 'Fire Alert Detected',
        body: 'Please check your room immediately.',
      );
      await _dbService.writeLogEvent(
        'Fire Risk Detected',
        'Critical combination of heat, humidity, or gas levels triggered a fire risk.',
      );
    }
    _prevFireRisk = data.fireRisk;

    // 2. Optical Flame Detected
    if (data.flameDetected && !_prevFlameDetected) {
      await _notificationService.showNotification(
        id: 2,
        title: 'Fire Alert Detected',
        body: 'Please check your room immediately.',
      );
      await _dbService.writeLogEvent(
        'Flame Detected',
        'Optical infrared flame sensor detected active ignition.',
      );
    }
    _prevFlameDetected = data.flameDetected;

    // 3. Toxic/Smoke Gas Levels
    if (data.gasStatus == 'WARNING' && _prevGasStatus != 'WARNING') {
      await _notificationService.showNotification(
        id: 3,
        title: 'Gas Concentration Warning',
        body: 'Elevated levels of smoke or gases detected by the MQ135 sensor.',
      );
      await _dbService.writeLogEvent(
        'Gas Warning',
        'Gas concentration levels entered WARNING zone (ADC: ${data.gasADC}).',
      );
    } else if (data.gasStatus == 'DANGER' && _prevGasStatus != 'DANGER') {
      await _notificationService.showNotification(
        id: 4,
        title: 'Gas Concentration Warning', // Set to warning as required, or custom danger title
        body: 'Smoke or toxic gas concentrations reached dangerous thresholds.',
      );
      await _dbService.writeLogEvent(
        'Gas Warning',
        'Gas levels entered critical DANGER zone (ADC: ${data.gasADC}).',
      );
    }
    _prevGasStatus = data.gasStatus;

    // 4. Exhaust Fan State Swapped
    if (_prevFanStatus != null && _prevFanStatus != data.fanStatus) {
      if (data.fanStatus) {
        await _dbService.writeLogEvent(
          'Fan Turned On',
          'The ventilation exhaust fan has started.',
        );
      } else {
        await _dbService.writeLogEvent(
          'Fan Turned Off',
          'The ventilation exhaust fan has stopped.',
        );
      }
    }
    _prevFanStatus = data.fanStatus;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
