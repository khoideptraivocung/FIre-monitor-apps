class FireData {
  final double temperature;
  final double humidity;
  final int gasADC;
  final String gasStatus;
  final bool flameDetected;
  final bool fireRisk;
  final bool fanStatus;

  FireData({
    required this.temperature,
    required this.humidity,
    required this.gasADC,
    required this.gasStatus,
    required this.flameDetected,
    required this.fireRisk,
    required this.fanStatus,
  });

  /// Factory constructor to safely parse dynamic Firebase JSON response.
  factory FireData.fromJson(Map<dynamic, dynamic> json) {
    return FireData(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
      gasADC: (json['gasADC'] as num?)?.toInt() ?? 0,
      gasStatus: json['gasStatus']?.toString().toUpperCase() ?? 'SAFE',
      flameDetected: json['flameDetected'] as bool? ?? false,
      fireRisk: json['fireRisk'] as bool? ?? false,
      fanStatus: json['fanStatus'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'gasADC': gasADC,
      'gasStatus': gasStatus,
      'flameDetected': flameDetected,
      'fireRisk': fireRisk,
      'fanStatus': fanStatus,
    };
  }

  FireData copyWith({
    double? temperature,
    double? humidity,
    int? gasADC,
    String? gasStatus,
    bool? flameDetected,
    bool? fireRisk,
    bool? fanStatus,
  }) {
    return FireData(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      gasADC: gasADC ?? this.gasADC,
      gasStatus: gasStatus ?? this.gasStatus,
      flameDetected: flameDetected ?? this.flameDetected,
      fireRisk: fireRisk ?? this.fireRisk,
      fanStatus: fanStatus ?? this.fanStatus,
    );
  }
}
