/// OCR engine ทุกตัวทำงานในเครื่อง (on-device) ไม่ส่งรูปออกไปไหน
abstract class OcrEngine {
  String get name;
  Future<String> recognize(String imagePath);
  Future<void> dispose() async {}
}
