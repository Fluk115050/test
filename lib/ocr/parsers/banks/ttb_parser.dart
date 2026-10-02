import '../slip_parser.dart';

/// สลิป ttb touch: "จาก" / "ไปที่" มีเลขที่รายการ
class TtbParser extends SlipParser {
  const TtbParser();

  @override
  Bank get bank => Bank.ttb;

  @override
  List<String> get brandKeywords => const ['ttb touch', 'ttb'];

  @override
  List<String> get bankKeywords => const [
    'ทหารไทยธนชาต',
    'ทีทีบี',
    'TMBThanachart',
  ];
}
