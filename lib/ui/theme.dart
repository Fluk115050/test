import 'package:flutter/material.dart';

/// ธีมหลัก: ตัวอักษรใหญ่ ปุ่มใหญ่ อ่านง่าย
ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF1B8A5A),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(fontSizeFactor: 1.15),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
