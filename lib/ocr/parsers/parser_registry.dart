import 'banks/bay_parser.dart';
import 'banks/bbl_parser.dart';
import 'banks/generic_parser.dart';
import 'banks/gsb_parser.dart';
import 'banks/kbank_parser.dart';
import 'banks/ktb_parser.dart';
import 'banks/scb_parser.dart';
import 'banks/ttb_parser.dart';
import 'common/normalizer.dart';
import 'common/slip_qr.dart';
import 'slip_parser.dart';

/// เลือก parser ให้ตรงธนาคาร — เพิ่มธนาคารใหม่ที่นี่บรรทัดเดียว
class ParserRegistry {
  ParserRegistry([List<SlipParser>? parsers])
    : parsers =
          parsers ??
          const [
            KBankParser(),
            ScbParser(),
            BblParser(),
            KtbParser(),
            BayParser(),
            TtbParser(),
            GsbParser(),
          ];

  final List<SlipParser> parsers;
  static const fallback = GenericParser();

  /// QR ก่อน (แม่นที่สุด) ถ้าไม่มีค่อยดูจากคำในสลิป
  SlipParser detect(String text, {String? qrPayload}) {
    final qr = SlipQr.tryParse(qrPayload);
    if (qr != null && qr.bank != Bank.unknown) {
      return parsers.firstWhere(
        (p) => p.bank == qr.bank,
        orElse: () => fallback,
      );
    }
    final lines = TextNormalizer.lines(text);
    SlipParser best = fallback;
    var bestScore = 0;
    for (final p in parsers) {
      final s = p.detectScore(lines);
      if (s > bestScore) {
        bestScore = s;
        best = p;
      }
    }
    return best;
  }
}
