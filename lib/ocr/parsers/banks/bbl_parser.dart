import '../slip_parser.dart';

/// สลิป Bualuang mBanking: "จาก" / "ไปที่" อยู่คนละบรรทัดกับชื่อ จำนวนเงินมีหน่วย THB
class BblParser extends SlipParser {
  const BblParser();

  @override
  Bank get bank => Bank.bbl;

  @override
  List<String> get brandKeywords => const [
    'Bualuang',
    'บัวหลวง',
    'Bangkok Bank',
  ];

  @override
  List<String> get bankKeywords => const ['กรุงเทพ', 'BBL'];
}
