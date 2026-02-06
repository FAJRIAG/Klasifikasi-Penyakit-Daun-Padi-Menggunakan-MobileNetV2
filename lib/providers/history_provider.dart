import 'package:flutter/foundation.dart';
import '../models/detection_record.dart';
import '../services/history_service.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryService _historyService = HistoryService();
  List<DetectionRecord> _history = [];
  bool _isLoading = false;

  List<DetectionRecord> get history => _history;
  bool get isLoading => _isLoading;

  // Initialize and load history
  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners(); // Notify loading state

    try {
      _history = await _historyService.getHistory();
    } catch (e) {
      print("Error loading history in provider: $e");
      _history = [];
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify loaded state
    }
  }

  // Save new detection
  Future<void> saveDetection(DetectionRecord record) async {
    await _historyService.saveDetection(record);
    
    // Optimistically update local list or reload
    // Option 1: Insert locally (faster)
    _history.insert(0, record);
    if (_history.length > 50) {
      _history.removeLast();
    }
    notifyListeners();
    
    // Option 2: Reload from source (safer consistency)
    // await loadHistory();
  }

  // Clear all history
  Future<void> clearHistory() async {
    await _historyService.clearHistory();
    _history = [];
    notifyListeners();
  }
}
