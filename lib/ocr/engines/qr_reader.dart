import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

/// อ่าน QR บนสลิป (มีรหัสธนาคารผู้โอน + เลขอ้างอิง)
class SlipQrReader {
  final _scanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);

  Future<String?> read(String imagePath) async {
    final codes = await _scanner.processImage(
      InputImage.fromFilePath(imagePath),
    );
    return codes.isEmpty ? null : codes.first.rawValue;
  }

  Future<void> dispose() => _scanner.close();
}
