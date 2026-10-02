import '../slip_parser.dart';

/// สลิป MyMo (ออมสิน): "จาก" / "ไปยัง" และ "จำนวนเงิน ... บาท"
class GsbParser extends SlipParser {
  const GsbParser();

  @override
  Bank get bank => Bank.gsb;

  @override
  List<String> get brandKeywords => const ['MyMo', 'GSB'];

  @override
  List<String> get bankKeywords => const ['ออมสิน', 'Government Savings'];
}
