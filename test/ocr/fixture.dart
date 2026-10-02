import 'dart:io';

String fixture(String name) =>
    File('test/ocr/fixtures/$name').readAsStringSync();

/// วันอ้างอิงคงที่ เพื่อให้การเดาปี พ.ศ./ค.ศ. แน่นอน
final testNow = DateTime(2026, 10, 2, 12);
