import 'dart:convert';

class DetectionRecord {
  final String imagePath;
  final String label;
  final double confidence;
  final DateTime timestamp;
  final String diagnosis;

  DetectionRecord({
    required this.imagePath,
    required this.label,
    required this.confidence,
    required this.timestamp,
    required this.diagnosis,
  });

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'label': label,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'diagnosis': diagnosis,
    };
  }

  factory DetectionRecord.fromJson(Map<String, dynamic> json) {
    return DetectionRecord(
      imagePath: json['imagePath'],
      label: json['label'],
      confidence: json['confidence'],
      timestamp: DateTime.parse(json['timestamp']),
      diagnosis: json['diagnosis'],
    );
  }
}
