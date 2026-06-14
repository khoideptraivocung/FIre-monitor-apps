class ControlData {
  final String mode; // 'AUTO' or 'MANUAL'
  final bool fan;

  ControlData({
    required this.mode,
    required this.fan,
  });

  bool get isAuto => mode == 'AUTO';

  factory ControlData.fromJson(Map<dynamic, dynamic> json) {
    return ControlData(
      mode: json['mode']?.toString().toUpperCase() ?? 'AUTO',
      fan: json['fan'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
      'fan': fan,
    };
  }

  ControlData copyWith({
    String? mode,
    bool? fan,
  }) {
    return ControlData(
      mode: mode ?? this.mode,
      fan: fan ?? this.fan,
    );
  }
}
