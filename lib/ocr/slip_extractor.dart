import 'parsers/common/slip_qr.dart';
import 'parsers/parser_registry.dart';
import 'parsers/slip_parser.dart';

/// รวมผลจาก OCR หลายตัวเป็น [SlipData] เดียว (pure Dart — ทดสอบได้โดยไม่ต้องมีเครื่อง)
///
/// - ML Kit (Latin): แม่นเรื่องตัวเลข -> ใช้จำนวนเงิน/วันที่ก่อน
/// - Tesseract (ไทย): อ่านชื่อและเดือนไทยได้ -> ใช้ชื่อก่อน
class SlipExtractor {
  SlipExtractor({ParserRegistry? registry, this.now})
    : registry = registry ?? ParserRegistry();

  final ParserRegistry registry;
  final DateTime? now;

  SlipData extract({String? thaiText, String? latinText, String? qrPayload}) {
    final combined = [thaiText, latinText].whereType<String>().join('\n');
    final parser = registry.detect(combined, qrPayload: qrPayload);

    final thai = thaiText == null
        ? const SlipData()
        : parser.parse(thaiText, now: now);
    final latin = latinText == null
        ? const SlipData()
        : parser.parse(latinText, now: now);
    final qr = SlipQr.tryParse(qrPayload);

    return SlipData(
      amount: latin.amount ?? thai.amount,
      dateTime: _pickDate(latin.dateTime, thai.dateTime),
      senderName: thai.senderName ?? latin.senderName,
      receiverName: thai.receiverName ?? latin.receiverName,
      bank: parser.bank,
      reference: qr?.reference ?? latin.reference ?? thai.reference,
    );
  }

  /// ML Kit อ่านเดือนไทยไม่ได้ ถ้าได้วันที่แต่ไม่มีเวลา ให้ใช้ของ Tesseract ถ้ามีเวลา
  DateTime? _pickDate(DateTime? latin, DateTime? thai) {
    if (latin == null) return thai;
    if (thai == null) return latin;
    final latinHasTime = latin.hour != 0 || latin.minute != 0;
    final thaiHasTime = thai.hour != 0 || thai.minute != 0;
    return !latinHasTime && thaiHasTime ? thai : latin;
  }
}
