import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  // Function to process image and extract text
  Future<String> processImage(File imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  // Clean up resources
  void dispose() {
    _textRecognizer.close();
  }
}
