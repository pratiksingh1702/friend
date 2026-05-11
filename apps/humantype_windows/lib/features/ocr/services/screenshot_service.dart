import 'dart:io';
import 'package:flutter/services.dart';
import 'package:screen_capturer/screen_capturer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ScreenshotService {
  /// Captures the entire screen and saves it to a temporary file.
  static Future<String?> captureScreen() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String path = p.join(tempDir.path, 'ocr_capture_${DateTime.now().millisecondsSinceEpoch}.png');
      
      final CapturedData? capturedData = await screenCapturer.capture(
        mode: CaptureMode.screen,
        imagePath: path,
        silent: true,
      );

      if (capturedData == null || capturedData.imagePath == null) {
        return null;
      }
      
      return capturedData.imagePath;
    } catch (e) {
      print('[ScreenshotService] Error: $e');
      return null;
    }
  }

  /// Captures a specific area of the screen.
  static Future<String?> captureArea(Rect area) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String path = p.join(tempDir.path, 'ocr_area_${DateTime.now().millisecondsSinceEpoch}.png');

      final CapturedData? capturedData = await screenCapturer.capture(
        mode: CaptureMode.region, // Region mode usually opens a selector, but we might want silent background capture
        imagePath: path,
        silent: true,
      );

      return capturedData?.imagePath;
    } catch (e) {
      print('[ScreenshotService] Error: $e');
      return null;
    }
  }
}
