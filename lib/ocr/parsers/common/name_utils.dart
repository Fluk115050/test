import 'normalizer.dart';

/// เครื่องมือเกี่ยวกับชื่อบุคคล/ร้านค้าในสลิป
class NameUtils {
  static const titles = [
    'นางสาว', 'นาง', 'นาย', 'น.ส.', 'ด.ช.', 'ด.ญ.', //
    'บจก.', 'บมจ.', 'หจก.', 'บริษัท', 'ร้าน',
  ];
  static const engTitles = ['MRS.', 'MR.', 'MS.', 'MISS', 'MSTR.'];

  static final RegExp titlePrefix = RegExp(
    '^(?:${[...titles.map(loosePattern), ...engTitles.map((t) => '${RegExp.escape(t.replaceAll('.', ''))}\\.?(?=\\s)')].join('|')})',
    caseSensitive: false,
  );

  /// บรรทัดนี้ดูเหมือนชื่อคน/ร้านหรือไม่ (ขึ้นต้นด้วยคำนำหน้า)
  static bool looksLikeName(String line) =>
      titlePrefix.hasMatch(line.trim()) && line.trim().length >= 5;

  /// บรรทัดที่ไม่ใช่ชื่อแน่ ๆ: เลขบัญชี ธนาคาร จำนวนเงิน ฯลฯ
  static bool isNoise(String line) {
    final l = line.trim();
    if (l.isEmpty) return true;
    final digits = RegExp(r'[\dxX\-*]').allMatches(l).length;
    if (digits >= l.replaceAll(' ', '').length * 0.6) return true;
    return RegExp(
      '^(?:${['ธ.', 'ธนาคาร', 'Bank', 'พร้อมเพย์', 'PromptPay', 'เลขที่', 'รหัส'].map(loosePattern).join('|')})',
      caseSensitive: false,
    ).hasMatch(l);
  }

  /// ตัดส่วนท้ายที่ไม่ใช่ชื่อ เช่น เลขบัญชีที่ OCR รวมมาในบรรทัดเดียวกัน
  static String clean(String name) {
    var s = name.trim();
    s = s.replaceAll(RegExp(r'\s+[xX\d][xX\d\-*]{3,}.*$'), '');
    s = s.replaceAll(RegExp(r'[|:>]+$'), '').trim();
    return s.replaceAll(RegExp(r'\s+'), ' ');
  }

  /// ตัดคำนำหน้าออก ใช้เทียบกับ "ชื่อบัญชีของฉัน" ในขั้นถัดไป
  static String stripTitle(String name) =>
      name.trim().replaceFirst(titlePrefix, '').trim();

  /// รูปแบบสำหรับเปรียบเทียบ: ไม่มีคำนำหน้า ไม่มีช่องว่าง ตัวพิมพ์ใหญ่
  static String compareKey(String name) =>
      stripTitle(name).replaceAll(RegExp(r'[\s.]'), '').toUpperCase();
}
