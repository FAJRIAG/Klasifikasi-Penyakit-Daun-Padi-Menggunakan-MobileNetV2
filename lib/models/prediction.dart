/// Data model for disease prediction results
class Prediction {
  final String className;
  final double confidence;
  final Map<String, double> allProbabilities;
  
  Prediction({
    required this.className,
    required this.confidence,
    required this.allProbabilities,
  });
  
  /// Parse disease name from class name
  /// Example: "Tungro" -> "Tungro"
  /// Example: "Bacterial_leaf_blight" -> "Bacterial Leaf Blight"
  String get diseaseName {
    // If format is still Plant___Disease
    if (className.contains('___')) {
      return className.split('___')[1].replaceAll('_', ' ');
    }
    return className.replaceAll('_', ' ');
  }
  
  /// Parse plant name from class name
  /// Always returns "Padi" for this specific app
  String get plantName {
    if (className.contains('___')) {
      return className.split('___')[0];
    }
    return 'Padi';
  }
  
  /// Check if plant is healthy
  bool get isHealthy {
    return className.toLowerCase().contains('healthy');
  }
  
  /// Format confidence as percentage string
  String get confidenceText {
    return '${confidence.toStringAsFixed(1)}%';
  }
  
  /// Get confidence level description
  String get confidenceLevel {
    if (confidence >= 90) return 'Sangat Tinggi';
    if (confidence >= 75) return 'Tinggi';
    if (confidence >= 60) return 'Sedang';
    return 'Rendah';
  }
}
