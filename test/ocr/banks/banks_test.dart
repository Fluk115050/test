import 'package:flutter_test/flutter_test.dart';
import 'package:sliplog/ocr/parsers/banks/kbank_parser.dart';
import 'package:sliplog/ocr/parsers/common/name_utils.dart';
import 'package:sliplog/ocr/parsers/parser_registry.dart';
import 'package:sliplog/ocr/parsers/slip_parser.dart';

import '../fixture.dart';

class _Case {
  const _Case(
    this.file,
    this.bank,
    this.amount,
    this.date,
    this.sender,
    this.receiver, [
    this.ref,
  ]);
  final String file;
  final Bank bank;
  final double amount;
  final DateTime date;
  final String sender;
  final String receiver;
  final String? ref;
}

final _cases = [
  _Case(
    'kbank.txt',
    Bank.kbank,
    1500,
    DateTime(2026, 10, 2, 14, 35),
    'นาย สมชาย ใจดี',
    'น.ส. สมหญิง รักดี',
    '016275143512BPM04321',
  ),
  _Case(
    'scb.txt',
    Bank.scb,
    350,
    DateTime(2026, 10, 2, 9, 12),
    'นาย สมชาย ใจดี',
    'นาง มาลี ขายดี',
    '202610029x1AbCdEf12',
  ),
  _Case(
    'bbl.txt',
    Bank.bbl,
    12000,
    DateTime(2026, 9, 15, 20, 5),
    'MR. SOMCHAI JAIDEE',
    'นางสาว สมหญิง รักดี',
    '2026091520051234',
  ),
  _Case(
    'ktb.txt',
    Bank.ktb,
    2450.5,
    DateTime(2026, 10, 1, 8, 0),
    'นาย สมชาย ใจดี',
    'บจก. ร้านดีดี ช้อป',
    'A0c1b2c3d4e5f6',
  ),
  _Case(
    'bay.txt',
    Bank.bay,
    999,
    DateTime(2026, 10, 2, 18, 45, 10),
    'นาย สมชาย ใจดี',
    'น.ส. สมหญิง รักดี',
    'BAY20261002184510',
  ),
  _Case(
    'ttb.txt',
    Bank.ttb,
    75.25,
    DateTime(2026, 9, 30, 23, 59),
    'นาย สมชาย ใจดี',
    'นาง มาลี ขายดี',
    '2026093023591234',
  ),
  _Case(
    'gsb.txt',
    Bank.gsb,
    100,
    DateTime(2026, 10, 2, 12, 0),
    'นาย สมชาย ใจดี',
    'น.ส. สมหญิง รักดี',
  ),
];

void main() {
  final registry = ParserRegistry();

  for (final c in _cases) {
    group(c.file, () {
      final text = fixture(c.file);
      final parser = registry.detect(text);
      final slip = parser.parse(text, now: testNow);

      test('ระบุธนาคาร', () => expect(parser.bank, c.bank));
      test('จำนวนเงิน', () => expect(slip.amount, c.amount));
      test('วันที่-เวลา', () => expect(slip.dateTime, c.date));
      test('ผู้โอน', () => expect(slip.senderName, c.sender));
      test('ผู้รับ', () => expect(slip.receiverName, c.receiver));
      if (c.ref != null) {
        test('เลขอ้างอิง', () => expect(slip.reference, c.ref));
      }
    });
  }

  // ข้อความ noisy ไม่มีคำบอกธนาคาร จึงเรียก parser กสิกรตรง ๆ
  test('ข้อความ Tesseract มีช่องว่างแปลก ๆ และเลขไทย', () {
    final slip = const KBankParser().parse(
      fixture('kbank_tesseract_noisy.txt'),
      now: testNow,
    );
    expect(slip.amount, 1500);
    expect(slip.dateTime, DateTime(2026, 10, 2, 14, 35));
    expect(NameUtils.compareKey(slip.senderName!), 'สมชายใจดี');
    expect(NameUtils.compareKey(slip.receiverName!), 'สมหญิงรักดี');
  });
}
