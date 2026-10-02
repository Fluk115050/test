import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

import 'ocr_engine.dart';

/// Tesseract (tha+eng) — อ่านชื่อ/เดือนภาษาไทยได้ ช้ากว่า ML Kit
/// ไฟล์โมเดลอยู่ใน assets/tessdata (tessdata_fast)
class TesseractEngine extends OcrEngine {
  @override
  String get name => 'Tesseract (ไทย+อังกฤษ)';

  @override
  Future<String> recognize(String imagePath) => FlutterTesseractOcr.extractText(
    imagePath,
    language: 'tha+eng',
    args: {'preserve_interword_spaces': '1', 'psm': '4'},
  );
}
