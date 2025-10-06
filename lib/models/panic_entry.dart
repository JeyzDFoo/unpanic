class PanicEntry {
  final DateTime timestamp;
  final double triggerLevel;
  final int breathingCycles;
  final String notes;

  PanicEntry({
    required this.timestamp,
    required this.triggerLevel,
    required this.breathingCycles,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'triggerLevel': triggerLevel,
      'breathingCycles': breathingCycles,
      'notes': notes,
    };
  }

  factory PanicEntry.fromJson(Map<String, dynamic> json) {
    return PanicEntry(
      timestamp: DateTime.parse(json['timestamp']),
      triggerLevel: json['triggerLevel']?.toDouble() ?? 0.0,
      breathingCycles: json['breathingCycles'] ?? 0,
      notes: json['notes'] ?? '',
    );
  }

  @override
  String toString() {
    return 'PanicEntry(timestamp: $timestamp, triggerLevel: $triggerLevel, breathingCycles: $breathingCycles, notes: $notes)';
  }
}
