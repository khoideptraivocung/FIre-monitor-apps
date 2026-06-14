import 'dart:async';
import 'package:flutter/material.dart';
import '../models/control_data.dart';
import '../services/database_service.dart';

class ControlProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  ControlData? _controlData;
  bool _isLoading = true;
  StreamSubscription<ControlData?>? _subscription;

  ControlData? get controlData => _controlData;
  bool get isLoading => _isLoading;

  ControlProvider() {
    _initStream();
  }

  void _initStream() {
    _subscription = _dbService.controlDataStream.listen((data) {
      _isLoading = false;
      _controlData = data;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Change the system mode (AUTO / MANUAL)
  Future<void> setMode(String mode) async {
    if (_controlData == null) return;
    final updated = _controlData!.copyWith(mode: mode);
    // Optimistic UI update
    _controlData = updated;
    notifyListeners();

    await _dbService.updateControlData(updated);
  }

  /// Toggle manual fan control state (ON / OFF)
  Future<void> setFan(bool fanState) async {
    if (_controlData == null) return;
    final updated = _controlData!.copyWith(fan: fanState);
    // Optimistic UI update
    _controlData = updated;
    notifyListeners();

    await _dbService.updateControlData(updated);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
