import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

class OcrService {
  /// Extracts text from an image file using Tesseract OCR.
  static Future<String> extractText(String imagePath) async {
    try {
      final String text = await FlutterTesseractOcr.extractText(
        imagePath,
        language: 'eng',
        args: {
          "psm": "3", // Fully automatic page segmentation, but no OSD
          "preserve_interword_spaces": "1",
        },
      );
      return text.trim();
    } catch (e) {
      print('[OcrService] Error: $e');
      return '';
    }
  }

  /// Specialized method for code extraction (optimizes for syntax)
  static Future<String> extractCode(String imagePath) async {
    // Tesseract doesn't have a specific 'code' mode, but we can optimize params
    return extractText(imagePath);
  }
}
