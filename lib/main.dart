import 'package:flutter/material.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'ui/ocr_test/ocr_test_page.dart';
import 'ui/theme.dart';

void main() {
  // ใช้ Android Photo Picker: แอปเห็นเฉพาะรูปที่ผู้ใช้เลือก ไม่ต้องขอสิทธิ์อ่านอัลบั้ม
  final picker = ImagePickerPlatform.instance;
  if (picker is ImagePickerAndroid) picker.useAndroidPhotoPicker = true;

  runApp(const SlipLogApp());
}

class SlipLogApp extends StatelessWidget {
  const SlipLogApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SlipLog',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    home: const OcrTestPage(),
  );
}
