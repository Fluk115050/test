/// ทำความสะอาดข้อความจาก OCR ก่อนส่งให้ parser
class TextNormalizer {
  static const _thaiDigits = '๐๑๒๓๔๕๖๗๘๙';

  static String normalize(String raw) {
    var s = raw;
    // เลขไทย -> อารบิก
    for (var i = 0; i < _thaiDigits.length; i++) {
      s = s.replaceAll(_thaiDigits[i], '$i');
    }
    s = s
        .replaceAll('\r', '')
        .replaceAll('​', '') // zero-width space
        .replaceAll(RegExp(r'[ \t ]+'), ' ');
    // OCR อ่านเลข 0 เป็นตัว O ระหว่างตัวเลข เช่น 1,5O0.00
    s = s.replaceAllMapped(
      RegExp(r'(?<=\d)[Oo](?=[\d.,])|(?<=[\d,.])[Oo](?=\d|\b)'),
      (_) => '0',
    );
    // "1, 500.00" / "1 ,500.00" / "1,500 .00" -> "1,500.00"
    s = s.replaceAllMapped(
      RegExp(r'(\d) ?, ?(\d{3})'),
      (m) => '${m[1]},${m[2]}',
    );
    s = s.replaceAllMapped(
      RegExp(r'(\d) ?\. ?(\d{2})\b'),
      (m) => '${m[1]}.${m[2]}',
    );
    return s
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .join('\n');
  }

  static List<String> lines(String raw) {
    final n = normalize(raw);
    return n.isEmpty ? const [] : n.split('\n');
  }
}

/// สร้าง regex ที่ยอมให้มีช่องว่างแทรกระหว่างตัวอักษร และจุดเป็น optional
/// (Tesseract ภาษาไทยมักใส่ช่องว่างแปลก ๆ หรือทำจุดหาย)
String loosePattern(String word) {
  final buf = StringBuffer();
  final chars = word.runes.map(String.fromCharCode).toList();
  for (var i = 0; i < chars.length; i++) {
    final c = chars[i];
    if (c == ' ') {
      buf.write(r'\s*');
      continue;
    }
    if (c == '.') {
      buf.write(r'\.?');
    } else {
      buf.write(RegExp.escape(c));
    }
    if (i < chars.length - 1) buf.write(r'\s?');
  }
  return buf.toString();
}
