import '../slip_parser.dart';

/// ใช้เมื่อระบุธนาคารไม่ได้ — ใช้กฎกลางทั้งหมด
class GenericParser extends SlipParser {
  const GenericParser();

  @override
  Bank get bank => Bank.unknown;

  @override
  List<String> get brandKeywords => const [];

  @override
  List<String> get bankKeywords => const [];
}
