import 'dart:async';
import 'package:flutter/material.dart';
import '../models/log_event.dart';
import '../services/database_service.dart';

class HistoryProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<LogEvent> _events = [];
  bool _isLoading = true;
  StreamSubscription<List<LogEvent>>? _subscription;

  List<LogEvent> get events => _events;
  bool get isLoading => _isLoading;

  HistoryProvider() {
    _initStream();
  }

  void _initStream() {
    _subscription = _dbService.logsStream.listen((logsList) {
      _isLoading = false;
      _events = logsList;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Manually write an event to the log (e.g., system test or manual override log)
  Future<void> logCustomEvent(String eventType, String description) async {
    await _dbService.writeLogEvent(eventType, description);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
