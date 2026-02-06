import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling image capture and selection
class ImageService {
  final ImagePicker _picker = ImagePicker();
  
  /// Pick image from camera
  Future<File?> pickFromCamera() async {
    try {
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      
      if (!cameraStatus.isGranted) {
        throw Exception('Camera permission denied');
      }
      
      // Capture image
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image == null) return null;
      
      return File(image.path);
    } catch (e) {
      print('Error picking image from camera: $e');
      rethrow;
    }
  }
  
  /// Pick image from gallery
  Future<File?> pickFromGallery() async {
    try {
      // Request storage permission
      // On Android 13+ use photos, otherwise use storage
      PermissionStatus status;
      
      if (Platform.isAndroid) {
        // Try photos first (new Android)
        status = await Permission.photos.request();
        
        // If that doesn't work or isn't applicable, try storage (old Android)
        if (status.isDenied || status.isRestricted) {
           status = await Permission.storage.request();
        }
      } else {
        // iOS
        status = await Permission.photos.request();
      }
      
      if (!status.isGranted && !status.isLimited) {
        // One last check: sometimes image_picker works without explicit permission on some versions
        // but we should warn
        print('Warning: Storage permission not fully granted: $status');
        // We don't throw immediately, let image_picker try, it handles some internal permission logic
      }
      
      // Select image
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image == null) return null;
      
      return File(image.path);
    } catch (e) {
      print('Error picking image from gallery: $e');
      // Don't rethrow immediately to allow UI to handle it gracefully or ignore if it's just a permission warning but picker opened
      if (e.toString().contains('permission')) {
          rethrow;
      }
      return null;
    }
  }
  
  /// Validate image file
  bool validateImage(File imageFile) {
    // Check if file exists
    if (!imageFile.existsSync()) {
      return false;
    }
    
    // Check file size (should be < 10MB)
    final fileSize = imageFile.lengthSync();
    if (fileSize > 10 * 1024 * 1024) {
      return false;
    }
    
    return true;
  }
}
