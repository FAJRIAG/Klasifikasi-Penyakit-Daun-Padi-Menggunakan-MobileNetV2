import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/detection_record.dart';

class HistoryService {
  static const String _historyKey = 'detection_history';

  Future<List<DetectionRecord>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_historyKey);

      if (historyJson == null) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(historyJson);
      return jsonList.map((json) => DetectionRecord.fromJson(json)).toList();
    } catch (e) {
      print("Error loading history: $e");
      return [];
    }
  }

  Future<void> saveDetection(DetectionRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<DetectionRecord> currentHistory = await getHistory();

      // Add new record to the beginning of the list
      currentHistory.insert(0, record);

      // Limit history size (optional, e.g., keep last 50)
      if (currentHistory.length > 50) {
        currentHistory.removeLast();
      }

      final String jsonString = json.encode(
        currentHistory.map((r) => r.toJson()).toList(),
      );

      await prefs.setString(_historyKey, jsonString);
    } catch (e) {
      print("Error saving history: $e");
    }
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      print("Error clearing history: $e");
    }
  }
}
