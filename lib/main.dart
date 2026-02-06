import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/tflite_service.dart';
import 'services/gemini_service.dart';
import 'providers/history_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Warning: .env file not found or not loaded. Service might rely on default behavior. Error: $e");
  }
  
  // Initialize Services
  final tfliteService = TFLiteService();
  await tfliteService.loadModel();
  
  final geminiService = GeminiService();
  await geminiService.initialize();
  
  runApp(MyApp(
    tfliteService: tfliteService,
    geminiService: geminiService,
  ));
}

class MyApp extends StatelessWidget {
  final TFLiteService tfliteService;
  final GeminiService geminiService;
  
  const MyApp({
    Key? key, 
    required this.tfliteService,
    required this.geminiService,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: tfliteService),
        Provider.value(value: geminiService),
        ChangeNotifierProvider(create: (_) => HistoryProvider()..loadHistory()),
      ],
      child: MaterialApp(
        title: 'Deteksi Penyakit Padi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
