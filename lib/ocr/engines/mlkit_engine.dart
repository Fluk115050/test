import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'ocr_engine.dart';

/// ML Kit (Latin) — แม่นเรื่องตัวเลข/อังกฤษ แต่อ่านภาษาไทยไม่ได้
class MlKitLatinEngine extends OcrEngine {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  String get name => 'ML Kit (Latin)';

  @override
  Future<String> recognize(String imagePath) async {
    final result = await _recognizer.processImage(
      InputImage.fromFilePath(imagePath),
    );
    // เรียงตามตำแหน่งบนลงล่าง เพื่อให้ลำดับบรรทัดตรงกับสลิป
    final lines = [for (final b in result.blocks) ...b.lines]
      ..sort((a, b) {
        final dy = a.boundingBox.top - b.boundingBox.top;
        if (dy.abs() > 10) return dy.sign.toInt();
        return (a.boundingBox.left - b.boundingBox.left).sign.toInt();
      });
    return lines.map((l) => l.text).join('\n');
  }

  @override
  Future<void> dispose() => _recognizer.close();
}
