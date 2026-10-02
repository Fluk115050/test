import 'common/amount.dart';
import 'common/name_utils.dart';
import 'common/normalizer.dart';
import 'common/thai_date.dart';
import 'slip_data.dart';

export 'slip_data.dart';

/// Parser ของสลิป 1 ธนาคาร
///
/// การเพิ่มธนาคารใหม่: สร้างคลาสลูกใน banks/ แล้วกำหนด [bank],
/// [brandKeywords], [bankKeywords] และ label ที่ธนาคารนั้นใช้
/// ถ้ารูปแบบพิเศษจริง ๆ ค่อย override [parseLines]
abstract class SlipParser {
  const SlipParser();

  Bank get bank;

  /// คำที่บอกว่าเป็นแอปของธนาคารนี้แน่ ๆ (ชื่อแอป/โลโก้) — น้ำหนักสูง
  List<String> get brandKeywords;

  /// ชื่อธนาคาร — น้ำหนักต่ำ เพราะอาจเป็นธนาคารของผู้รับก็ได้
  List<String> get bankKeywords;

  List<String> get senderLabels => const ['จากบัญชี', 'ผู้โอน', 'จาก', 'From'];
  List<String> get receiverLabels => const [
    'ไปยังบัญชี',
    'ผู้รับเงิน',
    'ผู้รับ',
    'ไปยัง',
    'ไปที่',
    'ถึง',
    'To',
  ];
  List<String> get amountLabels => AmountExtractor.defaultLabels;
  List<String> get referenceLabels => const [
    'เลขที่รายการ',
    'รหัสอ้างอิง',
    'หมายเลขอ้างอิง',
    'เลขอ้างอิง',
    'รหัสรายการ',
    'Ref',
    'Transaction ID',
  ];

  /// คะแนนว่าข้อความนี้น่าจะเป็นสลิปของธนาคารนี้แค่ไหน
  int detectScore(List<String> lines) {
    var score = 0;
    for (var i = 0; i < lines.length; i++) {
      final l = lines[i];
      final top = i < 4 ? 2 : 1; // หัวสลิปมักเป็นธนาคารผู้ออก
      if (_anyMatch(brandKeywords, l)) score += 5 * top;
      if (_anyMatch(bankKeywords, l)) score += 1 * top;
    }
    return score;
  }

  SlipData parse(String rawText, {DateTime? now}) =>
      parseLines(TextNormalizer.lines(rawText), now: now);

  SlipData parseLines(List<String> lines, {DateTime? now}) {
    final names = extractNames(lines);
    return SlipData(
      amount: AmountExtractor(labels: amountLabels).extract(lines),
      dateTime: ThaiDateParser(now: now).parse(lines),
      senderName: names.$1,
      receiverName: names.$2,
      bank: bank,
      reference: extractReference(lines),
    );
  }

  /// คืนค่า (ผู้โอน, ผู้รับ)
  /// 1) ใช้ label เช่น "จาก"/"ไปยัง" ถ้ามี
  /// 2) ไม่มี label: บรรทัดที่มีคำนำหน้าชื่อ ตัวแรก = ผู้โอน ตัวที่สอง = ผู้รับ
  (String?, String?) extractNames(List<String> lines) {
    var sender = _labeledName(lines, senderLabels);
    var receiver = _labeledName(lines, receiverLabels);
    if (sender != null && receiver != null) return (sender, receiver);

    final ordered = <String>[];
    for (final l in lines) {
      if (!NameUtils.looksLikeName(l)) continue;
      final n = NameUtils.clean(l);
      if (!ordered.any(
        (o) => NameUtils.compareKey(o) == NameUtils.compareKey(n),
      )) {
        ordered.add(n);
      }
    }
    final rest = ordered.where((n) => n != sender && n != receiver).toList();
    if (sender == null && rest.isNotEmpty) sender = rest.removeAt(0);
    if (receiver == null && rest.isNotEmpty) receiver = rest.removeAt(0);
    return (sender, receiver);
  }

  String? _labeledName(List<String> lines, List<String> labels) {
    final re = RegExp(
      '^(?:${labels.map(loosePattern).join('|')})(?![ก-๙a-zA-Z])\\s*[:：]?\\s*(.*)\$',
      caseSensitive: false,
    );
    for (var i = 0; i < lines.length; i++) {
      final m = re.firstMatch(lines[i]);
      if (m == null) continue;
      final inline = m[1]!.trim();
      if (inline.length >= 3 && !NameUtils.isNoise(inline)) {
        return NameUtils.clean(inline);
      }
      // label อยู่บรรทัดเดียว ชื่ออยู่บรรทัดถัดไป
      for (var j = i + 1; j < lines.length && j <= i + 2; j++) {
        if (!NameUtils.isNoise(lines[j]) && lines[j].length >= 3) {
          return NameUtils.clean(lines[j]);
        }
      }
    }
    return null;
  }

  String? extractReference(List<String> lines) {
    final label = RegExp(
      referenceLabels.map(loosePattern).join('|'),
      caseSensitive: false,
    );
    final code = RegExp(r'[A-Za-z0-9]{10,}');
    for (var i = 0; i < lines.length; i++) {
      final m = label.firstMatch(lines[i]);
      if (m == null) continue;
      final inline = code.firstMatch(lines[i].substring(m.end));
      if (inline != null) return inline[0];
      if (i + 1 < lines.length) {
        final next = code.firstMatch(lines[i + 1]);
        if (next != null) return next[0];
      }
    }
    return null;
  }

  static bool _anyMatch(List<String> words, String line) => words.any(
    (w) => RegExp(
      '(?<![A-Za-z])${loosePattern(w)}(?![A-Za-z])',
      caseSensitive: false,
    ).hasMatch(line),
  );
}
