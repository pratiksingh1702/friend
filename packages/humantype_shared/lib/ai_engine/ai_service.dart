import '../models/section_model.dart';
import '../models/ai_models.dart';

abstract class AiService {
  String get name;

  Future<List<Section>> parseInstructions(String input);
  
  Future<String> processOcrResult(String ocrText, String userIntent);

  Future<AiResponse> processRequest(AiRequest request);
}
