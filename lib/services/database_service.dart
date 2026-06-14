import 'package:firebase_database/firebase_database.dart';
import '../models/fire_data.dart';
import '../models/control_data.dart';
import '../models/log_event.dart';

class DatabaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  /// References
  DatabaseReference get _monitoringRef => _db.ref('FireMonitoring');
  DatabaseReference get _controlRef => _db.ref('control');
  DatabaseReference get _logsRef => _db.ref('logs');

  /// Stream of real-time fire monitoring sensor data
  Stream<FireData?> get fireDataStream {
    return _monitoringRef.onValue.map((event) {
      final snapshot = event.snapshot.value;
      if (snapshot == null) return null;
      return FireData.fromJson(snapshot as Map<dynamic, dynamic>);
    });
  }

  /// Stream of real-time control data (mode and manual fan)
  Stream<ControlData?> get controlDataStream {
    return _controlRef.onValue.map((event) {
      final snapshot = event.snapshot.value;
      if (snapshot == null) return null;
      return ControlData.fromJson(snapshot as Map<dynamic, dynamic>);
    });
  }

  /// Write new control configurations (e.g. toggle AUTO/MANUAL, or Fan state)
  Future<void> updateControlData(ControlData data) async {
    await _controlRef.set(data.toJson());
  }

  /// Stream of system alert logs, ordered by timestamp descending
  Stream<List<LogEvent>> get logsStream {
    return _logsRef.onValue.map((event) {
      final snapshot = event.snapshot.value;
      if (snapshot == null) return [];

      final Map<dynamic, dynamic> logsMap = snapshot as Map<dynamic, dynamic>;
      final List<LogEvent> events = [];

      logsMap.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          events.add(LogEvent.fromJson(key.toString(), value));
        }
      });

      // Sort logs by timestamp descending (most recent first)
      events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return events;
    });
  }

  /// Write a new event log to the database
  Future<void> writeLogEvent(String eventType, String description) async {
    final newLogRef = _logsRef.push();
    final log = LogEvent(
      id: newLogRef.key ?? '',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      eventType: eventType,
      description: description,
    );
    await newLogRef.set(log.toJson());
  }
}
