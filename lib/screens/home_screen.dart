import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tflite_service.dart';
import '../services/image_service.dart';
import 'result_screen.dart';
import 'photo_tips_dialog.dart';
import 'chat_screen.dart';
import 'history_screen.dart';
import 'dart:io';

/// Home screen with camera and gallery options
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageService _imageService = ImageService();
  bool _isProcessing = false;
  
  Future<void> _pickImage(bool useCamera) async {
    try {
      setState(() => _isProcessing = true);
      
      // Pick image
      final File? imageFile = useCamera 
          ? await _imageService.pickFromCamera()
          : await _imageService.pickFromGallery();
      
      if (imageFile == null) {
        setState(() => _isProcessing = false);
        return;
      }
      
      // Validate image
      if (!_imageService.validateImage(imageFile)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gambar tidak valid atau terlalu besar'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isProcessing = false);
        return;
      }
      
      // Get TFLite service
      final tfliteService = Provider.of<TFLiteService>(context, listen: false);
      
      // Run prediction
      final prediction = await tfliteService.predict(imageFile);
      
      // Navigate to result screen
      if (!mounted) return;
      
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            imageFile: imageFile,
            prediction: prediction,
          ),
        ),
      );
      
      setState(() => _isProcessing = false);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isProcessing = false);
    }
  }
  
  Offset _fabPos = const Offset(300, 500); // Initial position

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade400,
              Colors.green.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                        // Top Bar with History Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.history, color: Colors.white),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const HistoryScreen()),
                                  );
                                },
                                tooltip: 'Riwayat Deteksi',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        // App Logo and Title
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.eco,
                            size: 80, // Slightly reduced size
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        Text(
                          'Deteksi Penyakit\nPadi',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        
                        // Description Text (Cleaned up, no more embedded button)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Deteksi Penyakit Padi\nMenggunakan AI',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Tips Button
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const PhotoTipsDialog(),
                            );
                          },
                          icon: const Icon(Icons.tips_and_updates, color: Colors.yellow),
                          label: const Text(
                            'Lihat Panduan Foto',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        
                        // ... Rest of the content ...
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _buildFeature(Icons.camera_alt, 'Ambil foto daun padi'),
                              const Divider(height: 24),
                              _buildFeature(Icons.psychology, 'AI menganalisis penyakit'),
                              const Divider(height: 24),
                              _buildFeature(Icons.health_and_safety, 'Dapatkan rekomendasi penanganan'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildActionButton(
                          icon: Icons.camera_alt,
                          label: 'Ambil Foto',
                          color: Colors.white,
                          textColor: Colors.green.shade700,
                          onPressed: _isProcessing ? null : () => _pickImage(true),
                        ),
                        const SizedBox(height: 16),
                        _buildActionButton(
                          icon: Icons.photo_library,
                          label: 'Pilih dari Galeri',
                          color: Colors.green.shade900,
                          textColor: Colors.white,
                          onPressed: _isProcessing ? null : () => _pickImage(false),
                        ),
                        if (_isProcessing) ...[
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: const [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text(
                                  'Menganalisis gambar...',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Draggable Chat Button
              Positioned(
                left: _fabPos.dx,
                top: _fabPos.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _fabPos += details.delta;
                    });
                  },
                  onTap: () {
                     Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatScreen()),
                      );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.chat_bubble, 
                      color: Colors.green.shade800,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
