import '../slip_parser.dart';

/// สลิป KMA (กรุงศรี): ใช้ "จากบัญชี" / "ไปยังบัญชี" และวันที่แบบตัวเลข 02/10/2569
class BayParser extends SlipParser {
  const BayParser();

  @override
  Bank get bank => Bank.bay;

  @override
  List<String> get brandKeywords => const [
    'krungsri',
    'KMA',
    'Krungsri Mobile',
  ];

  @override
  List<String> get bankKeywords => const ['กรุงศรี', 'กรุงศรีอยุธยา'];
}
