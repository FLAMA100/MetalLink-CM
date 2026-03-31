import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Camera / photo picker service.
/// On web: opens OS file picker (image_picker_for_web).
/// On mobile (when using pubspec_mobile.yaml): opens native camera or gallery.
class CameraService {
  final ImagePicker _picker = ImagePicker();

  /// Takes a photo. On web this opens the file picker.
  /// On mobile it opens the camera.
  Future<XFile?> takePhoto() async {
    try {
      return await _picker.pickImage(
        source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
    } catch (e) {
      debugPrint('takePhoto error: $e');
      return null;
    }
  }

  /// Opens the photo gallery / file picker.
  Future<XFile?> pickFromGallery() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
    } catch (e) {
      debugPrint('pickFromGallery error: $e');
      return null;
    }
  }

  /// Picks multiple images at once.
  Future<List<XFile>> pickMultipleImages() async {
    try {
      return await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );
    } catch (e) {
      debugPrint('pickMultipleImages error: $e');
      return [];
    }
  }
}
