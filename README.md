# SlipLog

แอปจดรายรับรายจ่ายจากรูปสลิปโอนเงิน สำหรับฟรีแลนซ์/แม่ค้าออนไลน์ (Flutter, Android)
ข้อมูลทั้งหมดอยู่ในเครื่อง ไม่ส่งรูปหรือข้อมูลขึ้นเซิร์ฟเวอร์

## สถานะ: ขั้น 1 — ทดสอบ OCR

OCR ทำงานในเครื่องทั้งหมด ใช้ 3 ตัวพร้อมกัน แล้วรวมผล:

| ตัว | ใช้ทำอะไร |
|---|---|
| ML Kit Text Recognition (Latin) | จำนวนเงิน เวลา เลขอ้างอิง (ML Kit ไม่รองรับอักษรไทย) |
| Tesseract `tha+eng` (tessdata_fast) | ชื่อภาษาไทย เดือนไทย |
| ML Kit Barcode | QR บนสลิป → รหัสธนาคารผู้โอน + เลขอ้างอิง |

ธนาคารที่รองรับ: กสิกร, ไทยพาณิชย์, กรุงเทพ, กรุงไทย, กรุงศรี, ทหารไทยธนชาต, ออมสิน

## โครงสร้าง

```
lib/
  main.dart
  ui/                       หน้าจอ (ui/ocr_test = หน้าทดสอบ OCR)
  ocr/
    engines/                OcrEngine, ML Kit, Tesseract, QR reader
    parsers/
      slip_parser.dart      คลาสแม่ + กฎกลาง (label, ลำดับชื่อ, จำนวนเงิน, วันที่)
      parser_registry.dart  ระบุธนาคาร (QR > คำในสลิป) แล้วเลือก parser
      common/               normalizer, thai_date, amount, name_utils, slip_qr
      banks/                parser รายธนาคาร + generic
    slip_extractor.dart     รวมผล Tesseract + ML Kit + QR (pure Dart)
    slip_scanner.dart       เรียก engine ทั้งหมดกับรูปจริง
test/ocr/                   unit test + fixtures/ (ข้อความตัวอย่างต่อธนาคาร)
```

### เพิ่มธนาคารใหม่
1. สร้าง `lib/ocr/parsers/banks/xxx_parser.dart` ที่ extends `SlipParser` (กำหนด keyword/label)
2. เพิ่มใน `ParserRegistry`
3. ใส่ข้อความตัวอย่างใน `test/ocr/fixtures/` + เคสใน `banks_test.dart`

## รัน

```bash
flutter pub get
flutter test           # unit test parser
flutter run            # ต่อมือถือ Android (minSdk ตาม Flutter)
```

## ความเป็นส่วนตัว
- เลือกรูปผ่าน Android Photo Picker: แอปเห็นเฉพาะรูปที่ผู้ใช้เลือก ไม่ขอสิทธิ์อ่านอัลบั้ม
- release build ไม่มีสิทธิ์ INTERNET
