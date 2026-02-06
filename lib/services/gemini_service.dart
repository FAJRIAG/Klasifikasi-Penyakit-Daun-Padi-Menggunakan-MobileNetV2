import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late GenerativeModel _model;
  bool _isInitialized = false;
  
  // List of API Keys for rotation
  List<String> _apiKeys = [];
  int _currentKeyIndex = 0;

  /// Initialize the Gemini model with API keys from .env
  Future<void> initialize() async {
    // Load keys from GEMINI_API_KEYS (comma separated) or fallback to single GEMINI_API_KEY
    final keysString = dotenv.env['GEMINI_API_KEYS'];
    final singleKey = dotenv.env['GEMINI_API_KEY'];

    if (keysString != null && keysString.isNotEmpty) {
      _apiKeys = keysString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else if (singleKey != null && singleKey.isNotEmpty) {
      _apiKeys = [singleKey];
    }
    
    if (_apiKeys.isEmpty || _apiKeys.first == 'YOUR_API_KEY_HERE') {
      print('⚠️ Gemini API Keys not found or not set in .env');
      _isInitialized = false;
      return;
    }

    await _initModelWithCurrentKey();
  }

  Future<void> _initModelWithCurrentKey() async {
    try {
      final apiKey = _apiKeys[_currentKeyIndex];
      print('🔑 Using API Key index: $_currentKeyIndex (${apiKey.substring(0, 4)}...)');
      
      _model = GenerativeModel(
        model: 'gemini-2.5-flash', 
        apiKey: apiKey,
      );
      _isInitialized = true;
      print('✅ Gemini Service initialized with gemini-2.5-flash');
    } catch (e) {
      print('❌ Error initializing Gemini: $e');
      _isInitialized = false;
    }
  }

  Future<void> _rotateKey() async {
    if (_apiKeys.length <= 1) return; // No other keys to rotate to
    
    final nextIndex = (_currentKeyIndex + 1) % _apiKeys.length;
    print('🔄 Rotating API Key from index $_currentKeyIndex to $nextIndex');
    _currentKeyIndex = nextIndex;
    
    await _initModelWithCurrentKey();
    
    // If we have an active chat session, we need to recreate it with the new model
    // But we can't easily transfer state unless we stored history manually. 
    // For now, startChat() will be called lazily if needed.
    _chatSession = null; 
  }

  // Chat Session
  ChatSession? _chatSession;

  /// Starts a new chat session
  void startChat() {
    if (!_isInitialized) return;
    
    _chatSession = _model.startChat(
      history: [
        Content.text("User: Halo, saya butuh bantuan tentang padi."),
        Content.model([TextPart("Halo! Saya adalah asisten pakar penyakit padi. Silakan tanyakan masalah apa yang terjadi pada tanaman padi Anda.")]),
      ],
    );
  }

  /// Sends a message with automatic retry and key rotation
  Future<String> sendMessage(String message) async {
    return _executeWithRetry(() async {
      if (_chatSession == null) {
        startChat();
        if (_chatSession == null) throw Exception("Gagal memulai sesi chat.");
      }

      // Add context instruction
      final prompt = "Context: You are a Rice Disease Expert. If question is unrelated to rice, refuse. Question: $message";
      final response = await _chatSession!.sendMessage(Content.text(prompt));
      return response.text ?? "Maaf, tidak ada jawaban.";
    });
  }

  /// Analyze disease with automatic retry and key rotation
  Future<String?> analyzeDisease(File imageFile, String predictedLabel) async {
    if (!_isInitialized) return "⚠️ API Key belum dikonfigurasi.";

    return _executeWithRetry(() async {
      final imageBytes = await imageFile.readAsBytes();
      final content = [
        Content.multi([
          TextPart('''
Kamu adalah pakar patologi tanaman padi (Rice Expert). 
Saya memiliki foto daun padi yang dideteksi sebagai: "$predictedLabel". 

Tugasmu:
1. Konfirmasi diagnosis "$predictedLabel" benar/salah?
2. Jelaskan gejala visual SPESIFIK di foto.
3. Berikan saran praktis singkat untuk petani.

Jawab Bahasa Indonesia, langsung poin, sapa petani. Max 3 paragraf.
          '''),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      return response.text;
    });
  }

  /// Helper to execute API calls with retry logic
  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    // Try as many times as we have keys (at most one full rotation)
    int maxAttempts = _apiKeys.length > 0 ? _apiKeys.length : 1; 

    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        final errorMsg = e.toString();
        // Check for Rate Limit / Quota errors
        if (errorMsg.contains('Quota exceeded') || errorMsg.contains('429')) {
          print('⚠️ Quota exceeded on key $_currentKeyIndex. Retrying with next key...');
          await _rotateKey();
          attempts++;
        } else {
          // If other error, rethrow immediately
          // But create a user friendly message if possible
          if (attempts == maxAttempts - 1) {
             if (T == String) return "Gagal: ${e.toString().replaceAll('GenerativeAIException: ', '')}" as T;
             rethrow;
          }
           rethrow;
        }
      }
    }
    // If all keys failed
    if (attempts >= maxAttempts) {
       return "⚠️ Semua API Key mengalami limit kuota. Mohon coba lagi nanti." as T;
    }
    throw Exception("All API Keys exhausted");
  }
}
