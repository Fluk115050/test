import '../slip_parser.dart';

/// สลิป K PLUS: ไม่มี label ผู้โอน/ผู้รับ ใช้ลำดับชื่อ (ผู้โอนก่อน) ส่วนวันที่อยู่บนสุด เช่น "2 ต.ค. 69 14:35 น."
class KBankParser extends SlipParser {
  const KBankParser();

  @override
  Bank get bank => Bank.kbank;

  @override
  List<String> get brandKeywords => const [
    'K PLUS',
    'K+',
    'KPLUS',
    'KBank',
    'MAKE by KBank',
  ];

  @override
  List<String> get bankKeywords => const ['กสิกรไทย', 'กสิกร', 'KASIKORN'];
}
