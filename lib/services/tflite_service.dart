import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/prediction.dart';

/// Service for TensorFlow Lite model inference
class TFLiteService {
  Interpreter? _interpreter;
  bool _modelLoaded = false;
  List<String> _labels = [];
  
  /// Initialize and load the TFLite model
  Future<void> loadModel() async {
    try {
      // Load labels from assets
      final labelsData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelsData.split('\n').map((e) => e.trim()).where((label) => label.isNotEmpty).toList();
      
      // Load actual TFLite model
      final options = InterpreterOptions();
      _interpreter = await Interpreter.fromAsset('assets/models/rice_leaf_model.tflite', options: options);
      
      _modelLoaded = true;
      print('✅ TFLite Service initialized');
      print('📋 Labels loaded: ${_labels.length} classes');
      
      // Warmup run
      // _interpreter?.allocateTensors();
    } catch (e) {
      print('❌ Error loading model: $e');
      print('Make sure rice_leaf_model.tflite and labels.txt are in assets/models/');
      _modelLoaded = false;
    }
  }
  
  /// Preprocess image for model input
  /// Resize to 224x224 and normalize pixel values
  List<List<List<List<double>>>> _preprocessImage(File imageFile) {
    // Decode image
    final imageBytes = imageFile.readAsBytesSync();
    img.Image? image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }
    
    // Calculate crop size (min dimension)
    int cropSize = image.width < image.height ? image.width : image.height;
    
    // Crop center
    img.Image cropped = img.copyCrop(
      image, 
      x: (image.width - cropSize) ~/ 2, 
      y: (image.height - cropSize) ~/ 2, 
      width: cropSize, 
      height: cropSize
    );
    
    // Resize to 224x224
    img.Image resized = img.copyResize(cropped, width: 224, height: 224);
    
    // Normalize pixels [0-255] -> [0-1]
    List<List<List<List<double>>>> input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = resized.getPixel(x, y);
            
            // Normalize pixels [-1, 1] (Common for MobileNet)
            // Formula: (value - 127.5) / 127.5
            double r = (pixel.r - 127.5) / 127.5;
            double g = (pixel.g - 127.5) / 127.5;
            double b = (pixel.b - 127.5) / 127.5;
            
            return [r, g, b];
          },
        ),
      ),
    );
    
    return input;
  }
  
  /// Run inference on the image
  Future<Prediction> predict(File imageFile) async {
    if (!_modelLoaded || _interpreter == null) {
      throw Exception('Model not loaded. Call loadModel() first.');
    }
    
    try {
      // Preprocess image
      final input = _preprocessImage(imageFile);
      
      // Prepare output tensor
      // Output shape: [1, num_classes]
      var output = List.filled(1, List.filled(_labels.length, 0.0)).map((e) => List.filled(_labels.length, 0.0)).toList();
      
      // Run inference
      _interpreter!.run(input, output);
      
      // Get probabilities
      List<double> probabilities = output[0];
      
      // Find class with highest confidence
      int maxIndex = 0;
      double maxConfidence = probabilities[0];
      
      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxConfidence) {
          maxConfidence = probabilities[i];
          maxIndex = i;
        }
      }
      
      // Print all probabilities for debugging
      print('🔍 --- Prediction Debug ---');
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > 0.05) { // Only show > 5%
          print('${_labels[i]}: ${(probabilities[i] * 100).toStringAsFixed(2)}%');
        }
      }
      print('🏆 Winner: ${_labels[maxIndex]}');
      print('---------------------------');

      // Create probability map
      Map<String, double> allProbabilities = {};
      for (int i = 0; i < _labels.length; i++) {
        // Handle case where labels might not match output size perfectly if model changed
        if (i < probabilities.length) {
            allProbabilities[_labels[i]] = probabilities[i];
        }
      }
      
      // Create prediction result
      return Prediction(
        className: _labels[maxIndex],
        confidence: maxConfidence * 100, // Convert to percentage
        allProbabilities: allProbabilities,
      );
    } catch (e) {
      print('❌ Prediction error: $e');
      rethrow;
    }
  }
  
  /// Cleanup resources
  void dispose() {
    _interpreter?.close();
    _modelLoaded = false;
  }
  
  /// Check if model is loaded
  bool get isLoaded => _modelLoaded;
}
