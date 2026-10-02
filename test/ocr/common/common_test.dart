import 'package:flutter_test/flutter_test.dart';
import 'package:sliplog/ocr/parsers/common/amount.dart';
import 'package:sliplog/ocr/parsers/common/name_utils.dart';
import 'package:sliplog/ocr/parsers/common/normalizer.dart';
import 'package:sliplog/ocr/parsers/common/slip_qr.dart';
import 'package:sliplog/ocr/parsers/common/thai_date.dart';
import 'package:sliplog/ocr/parsers/slip_data.dart';
import 'package:sliplog/ocr/slip_extractor.dart';

import '../fixture.dart';

void main() {
  group('ThaiDateParser', () {
    final p = ThaiDateParser(now: testNow);
    DateTime? d(String s) => p.parse(TextNormalizer.lines(s));

    test(
      'เดือนไทยย่อ ปี พ.ศ. 2 หลัก',
      () => expect(d('2 ต.ค. 69 14:35 น.'), DateTime(2026, 10, 2, 14, 35)),
    );
    test(
      'เดือนไทยเต็ม ปี 4 หลัก',
      () => expect(d('5 มีนาคม 2569 เวลา 07:05'), DateTime(2026, 3, 5, 7, 5)),
    );
    test(
      'จุดหาย/มีช่องว่าง',
      () => expect(d('12 ธ ค 68 21:00'), DateTime(2025, 12, 12, 21)),
    );
    test(
      'เดือนอังกฤษ ปี ค.ศ. 2 หลัก',
      () => expect(d('02 Oct 26, 14:35'), DateTime(2026, 10, 2, 14, 35)),
    );
    test(
      'เดือนอังกฤษ ปี พ.ศ. 2 หลัก',
      () => expect(d('02 Oct 69 14:35'), DateTime(2026, 10, 2, 14, 35)),
    );
    test(
      'ตัวเลข พ.ศ.',
      () => expect(d('02/10/2569 18:45:10'), DateTime(2026, 10, 2, 18, 45, 10)),
    );
    test(
      'เวลาอยู่บรรทัดถัดไป',
      () => expect(d('02 ต.ค. 2569\n14:35'), DateTime(2026, 10, 2, 14, 35)),
    );
    test('ไม่สับสนกับเวลา "14:35" ว่าเป็นปี', () => expect(d('14:35'), isNull));
  });

  group('AmountExtractor', () {
    final a = AmountExtractor();
    double? x(String s) => a.extract(TextNormalizer.lines(s));

    test(
      'ไม่หยิบค่าธรรมเนียม',
      () => expect(x('ค่าธรรมเนียม 10.00 บาท\nจำนวนเงิน 250.00 บาท'), 250),
    );
    test(
      'label อยู่บรรทัดก่อน',
      () => expect(x('จำนวน:\n1,234,567.89'), 1234567.89),
    );
    test(
      'แก้ O เป็น 0 และช่องว่างหลังจุลภาค',
      () => expect(x('1, 5O0.00 บาท'), 1500),
    );
    test(
      'ไม่มี label ก็หาได้',
      () => expect(x('โอนเงินสำเร็จ\n42.00 THB'), 42),
    );
  });

  group('NameUtils', () {
    test('compareKey ตัดคำนำหน้า', () {
      expect(NameUtils.compareKey('น.ส. สมหญิง รักดี'), 'สมหญิงรักดี');
      expect(NameUtils.compareKey('MR. Somchai Jaidee'), 'SOMCHAIJAIDEE');
    });
    test(
      'clean ตัดเลขบัญชีท้ายชื่อ',
      () => expect(
        NameUtils.clean('นาย สมชาย ใจดี xxx-x-x1234-x'),
        'นาย สมชาย ใจดี',
      ),
    );
  });

  group('SlipQr', () {
    test('อ่านรหัสธนาคารและเลขอ้างอิง', () {
      // 00(len 41): 00=000001, 01=004, 02=016275143512BPM04321 ; 51=TH ; 91=CRC
      const payload =
          '0041000600000101030040220016275143512BPM0432151 02TH91049C30';
      final qr = SlipQr.tryParse(payload.replaceAll(' ', ''));
      expect(qr?.bank, Bank.kbank);
      expect(qr?.reference, '016275143512BPM04321');
    });
    test(
      'payload ไม่ใช่สลิป',
      () => expect(SlipQr.tryParse('https://x.y'), isNull),
    );
  });

  test('SlipExtractor รวมผล Tesseract + ML Kit', () {
    final slip = SlipExtractor(now: testNow).extract(
      thaiText: fixture('kbank_tesseract_noisy.txt'),
      latinText: fixture('kbank_mlkit_latin.txt'),
    );
    expect(slip.bank, Bank.kbank); // จาก "K+" ใน ML Kit
    expect(slip.amount, 1500);
    expect(slip.dateTime, DateTime(2026, 10, 2, 14, 35));
    expect(NameUtils.compareKey(slip.senderName!), 'สมชายใจดี');
    expect(NameUtils.compareKey(slip.receiverName!), 'สมหญิงรักดี');
  });
}
