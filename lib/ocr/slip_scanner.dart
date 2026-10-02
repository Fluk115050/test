import 'engines/mlkit_engine.dart';
import 'engines/qr_reader.dart';
import 'engines/tesseract_engine.dart';
import 'parsers/slip_data.dart';
import 'slip_extractor.dart';

/// ผลการสแกนครบชุด: ผลที่ดึงได้ + ข้อความดิบของแต่ละ engine (ไว้ดูความแม่น)
class ScanResult {
  const ScanResult({
    required this.slip,
    required this.thaiText,
    required this.latinText,
    required this.qrPayload,
    required this.timingsMs,
    this.errors = const {},
  });

  final SlipData slip;
  final String? thaiText;
  final String? latinText;
  final String? qrPayload;
  final Map<String, int> timingsMs;
  final Map<String, String> errors;
}

class SlipScanner {
  final _tesseract = TesseractEngine();
  final _mlkit = MlKitLatinEngine();
  final _qr = SlipQrReader();
  final _extractor = SlipExtractor();

  Future<ScanResult> scan(String imagePath) async {
    final timings = <String, int>{};
    final errors = <String, String>{};

    Future<T?> timed<T>(String key, Future<T> Function() f) async {
      final sw = Stopwatch()..start();
      try {
        return await f();
      } catch (e) {
        errors[key] = '$e';
        return null;
      } finally {
        timings[key] = sw.elapsedMilliseconds;
      }
    }

    // รันพร้อมกัน แล้วรอทีละตัว
    final latinF = timed('ML Kit', () => _mlkit.recognize(imagePath));
    final qrF = timed('QR', () => _qr.read(imagePath));
    final thaiF = timed('Tesseract', () => _tesseract.recognize(imagePath));
    final latin = await latinF, qr = await qrF, thai = await thaiF;

    return ScanResult(
      slip: _extractor.extract(thaiText: thai, latinText: latin, qrPayload: qr),
      thaiText: thai,
      latinText: latin,
      qrPayload: qr,
      timingsMs: timings,
      errors: errors,
    );
  }

  Future<void> dispose() async {
    await _mlkit.dispose();
    await _qr.dispose();
  }
}
