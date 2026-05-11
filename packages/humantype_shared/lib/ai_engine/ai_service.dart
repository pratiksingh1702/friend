import '../models/section_model.dart';

abstract class AiService {
  String get name;

  Future<List<Section>> parseInstructions(String input);
  
  Future<String> processOcrResult(String ocrText, String userIntent);
}
