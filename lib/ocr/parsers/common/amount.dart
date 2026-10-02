import 'normalizer.dart';

/// หาจำนวนเงินจากบรรทัดข้อความ โดยให้คะแนนจากคำกำกับรอบ ๆ
class AmountExtractor {
  AmountExtractor({List<String>? labels})
    : _label = RegExp(
        (labels ?? defaultLabels).map(loosePattern).join('|'),
        caseSensitive: false,
      );

  static const defaultLabels = [
    'จำนวนเงิน',
    'จำนวน',
    'ยอดเงิน',
    'ยอดโอน',
    'Amount',
    'Total',
  ];

  static final _number = RegExp(
    r'(?<![\d,.])(\d{1,3}(?:,\d{3})+|\d+)\.(\d{2})(?![\d])',
  );
  static final _currency = RegExp(r'บาท|THB|฿|Baht', caseSensitive: false);
  static final _fee = RegExp(
    '${loosePattern('ค่าธรรมเนียม')}|Fee|${loosePattern('คงเหลือ')}|Balance',
    caseSensitive: false,
  );

  final RegExp _label;

  double? extract(List<String> lines) {
    double? best;
    var bestScore = -999;
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      for (final m in _number.allMatches(line)) {
        final value = double.parse('${m[1]!.replaceAll(',', '')}.${m[2]}');
        if (value <= 0) continue;
        var score = 0;
        final prev = i > 0 ? lines[i - 1] : '';
        if (_label.hasMatch(line)) score += 5;
        if (_label.hasMatch(prev) && !_fee.hasMatch(prev)) score += 4;
        if (_currency.hasMatch(line)) score += 2;
        if (_fee.hasMatch(line)) score -= 10;
        if (_fee.hasMatch(prev) && !_label.hasMatch(line)) score -= 6;
        if (m[1]!.contains(',')) score += 1;
        // ตัวเลขที่ติดตัวอักษร/ขีด มักเป็นเลขบัญชีหรือเลขอ้างอิง
        final after = line.substring(m.end);
        if (after.startsWith(RegExp(r'[-xX/]'))) score -= 5;
        if (score > bestScore) {
          bestScore = score;
          best = value;
        }
      }
    }
    return best;
  }
}
