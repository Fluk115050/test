import '../slip_parser.dart';

/// สลิป Krungthai NEXT: ชื่อผู้โอน/ผู้รับเรียงต่อกันไม่มี label มี "วันที่ทำรายการ"
class KtbParser extends SlipParser {
  const KtbParser();

  @override
  Bank get bank => Bank.ktb;

  @override
  List<String> get brandKeywords => const [
    'Krungthai NEXT',
    'Krungthai',
    'KTB',
  ];

  @override
  List<String> get bankKeywords => const ['กรุงไทย'];
}
