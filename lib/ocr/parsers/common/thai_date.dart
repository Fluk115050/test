import 'normalizer.dart';

/// แปลงวันที่-เวลาในสลิป รองรับ:
/// - เดือนไทยย่อ/เต็ม (2 ต.ค. 69, 02 ตุลาคม 2569)
/// - เดือนอังกฤษ (02 Oct 26, 2 October 2026)
/// - ตัวเลข (02/10/2569, 02-10-2026)
/// ปี 2 หลักจะเลือกระหว่าง พ.ศ./ค.ศ. ตัวที่ใกล้ [now] ที่สุด
class ThaiDateParser {
  ThaiDateParser({DateTime? now}) : now = now ?? DateTime.now();

  final DateTime now;

  static const _thaiShort = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', //
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
  ];
  static const _thaiFull = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน', //
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];
  static const _engShort = [
    'jan', 'feb', 'mar', 'apr', 'may', 'jun', //
    'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
  ];

  static final List<(RegExp, int)> _monthPatterns = [
    // เต็มก่อนย่อ เพื่อไม่ให้ "มีนาคม" ถูกจับเป็นอย่างอื่น
    for (var i = 0; i < 12; i++) (RegExp(loosePattern(_thaiFull[i])), i + 1),
    for (var i = 0; i < 12; i++) (RegExp(loosePattern(_thaiShort[i])), i + 1),
    for (var i = 0; i < 12; i++)
      (
        RegExp('(?<![a-z])${_engShort[i]}[a-z]*\\.?', caseSensitive: false),
        i + 1,
      ),
  ];

  static final _time = RegExp(
    r'(?<!\d)([01]?\d|2[0-3])\s?[:：]\s?([0-5]\d)(?:\s?[:：]\s?([0-5]\d))?(?!\d)',
  );
  static final _timeDot = RegExp(r'(?<![\d,.])([01]?\d|2[0-3])\.([0-5]\d)\s?น');
  static final _numeric = RegExp(
    r'(?<!\d)(\d{1,2})\s?[/\-.]\s?(\d{1,2})\s?[/\-.]\s?(\d{4}|\d{2})(?!\d)',
  );

  DateTime? parse(List<String> lines) {
    for (var i = 0; i < lines.length; i++) {
      final date = _parseDate(lines[i]);
      if (date == null) continue;
      // หาเวลาในบรรทัดเดียวกัน หรือบรรทัดติดกัน
      final time =
          _parseTime(date.rest) ??
          (i + 1 < lines.length ? _parseTime(lines[i + 1]) : null) ??
          (i > 0 ? _parseTime(lines[i - 1]) : null);
      return DateTime(
        date.y,
        date.m,
        date.d,
        time?.$1 ?? 0,
        time?.$2 ?? 0,
        time?.$3 ?? 0,
      );
    }
    return null;
  }

  ({int y, int m, int d, String rest})? _parseDate(String line) {
    for (final (pattern, month) in _monthPatterns) {
      for (final m in pattern.allMatches(line)) {
        final before = line.substring(0, m.start);
        final after = line.substring(m.end);
        final day = RegExp(r'(\d{1,2})\s*$').firstMatch(before);
        final year = RegExp(r'^\s*,?\s*(\d{4}|\d{2})(?!\d|\s?[:：])')
            .firstMatch(after);
        if (day == null || year == null) continue;
        final d = int.parse(day[1]!);
        if (d < 1 || d > 31) continue;
        final y = _resolveYear(year[1]!, month, d);
        return (y: y, m: month, d: d, rest: after.substring(year.end));
      }
    }
    final n = _numeric.firstMatch(line);
    if (n != null) {
      final d = int.parse(n[1]!), mo = int.parse(n[2]!);
      if (d >= 1 && d <= 31 && mo >= 1 && mo <= 12) {
        return (
          y: _resolveYear(n[3]!, mo, d),
          m: mo,
          d: d,
          rest: line.substring(n.end),
        );
      }
    }
    return null;
  }

  (int, int, int)? _parseTime(String s) {
    final m = _time.firstMatch(s) ?? _timeDot.firstMatch(s);
    if (m == null) return null;
    final sec = m.groupCount >= 3 && m[3] != null ? int.parse(m[3]!) : 0;
    return (int.parse(m[1]!), int.parse(m[2]!), sec);
  }

  int _resolveYear(String raw, int month, int day) {
    final v = int.parse(raw);
    if (raw.length == 4) return v > 2400 ? v - 543 : v;
    // ปี 2 หลัก: เทียบ ค.ศ. (20xx) กับ พ.ศ. (25xx) เลือกตัวที่ใกล้วันนี้
    final candidates = [2000 + v, 2500 + v - 543];
    candidates.sort(
      (a, b) => _distance(a, month, day).compareTo(_distance(b, month, day)),
    );
    return candidates.first;
  }

  int _distance(int y, int m, int d) =>
      DateTime(y, m, d).difference(now).inDays.abs();
}
