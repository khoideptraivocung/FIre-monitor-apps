class LogEvent {
  final String id;
  final int timestamp; // milliseconds since epoch
  final String eventType;
  final String description;

  LogEvent({
    required this.id,
    required this.timestamp,
    required this.eventType,
    required this.description,
  });

  factory LogEvent.fromJson(String id, Map<dynamic, dynamic> json) {
    return LogEvent(
      id: id,
      timestamp: (json['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      eventType: json['eventType']?.toString() ?? 'Unknown Event',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'eventType': eventType,
      'description': description,
    };
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);
}
