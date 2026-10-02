import '../slip_parser.dart';

/// สลิป SCB EASY: ใช้ "จาก" / "ไปยัง" นำหน้าชื่อ มี "รหัสอ้างอิง"
class ScbParser extends SlipParser {
  const ScbParser();

  @override
  Bank get bank => Bank.scb;

  @override
  List<String> get brandKeywords => const ['SCB EASY', 'SCBEASY', 'SCB'];

  @override
  List<String> get bankKeywords => const ['ไทยพาณิชย์', 'Siam Commercial'];
}
