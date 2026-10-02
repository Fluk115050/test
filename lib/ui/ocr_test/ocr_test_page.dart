import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../ocr/slip_scanner.dart';
import '../format.dart';

/// หน้าทดสอบ OCR (ขั้น 1): เลือกสลิป -> ดูผลที่ดึงได้ + ข้อความดิบ
class OcrTestPage extends StatefulWidget {
  const OcrTestPage({super.key});

  @override
  State<OcrTestPage> createState() => _OcrTestPageState();
}

class _OcrTestPageState extends State<OcrTestPage> {
  final _scanner = SlipScanner();
  final _picker = ImagePicker();

  String? _imagePath;
  ScanResult? _result;
  bool _busy = false;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _pickAndScan() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      _imagePath = file.path;
      _result = null;
      _busy = true;
    });
    try {
      final r = await _scanner.scan(file.path);
      if (mounted) setState(() => _result = r);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SlipLog · ทดสอบ OCR')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton.icon(
            onPressed: _busy ? null : _pickAndScan,
            icon: const Icon(Icons.photo_library_outlined, size: 28),
            label: Text(_imagePath == null ? 'เลือกรูปสลิป' : 'เลือกสลิปใหม่'),
          ),
          const SizedBox(height: 8),
          Text(
            'แอปเห็นเฉพาะรูปที่คุณเลือก และอ่านข้อความในเครื่องเท่านั้น',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (_imagePath != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_imagePath!),
                height: 260,
                fit: BoxFit.contain,
              ),
            ),
          ],
          if (_busy)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('กำลังอ่านสลิป…'),
                ],
              ),
            ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            _ResultCard(result: _result!),
            const SizedBox(height: 16),
            _RawText(
              title: 'ข้อความดิบ: Tesseract (ไทย)',
              text: _result!.thaiText,
            ),
            _RawText(
              title: 'ข้อความดิบ: ML Kit (Latin)',
              text: _result!.latinText,
            ),
            _RawText(title: 'ข้อมูล QR', text: _result!.qrPayload),
          ],
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final s = result.slip;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ผลที่ดึงได้ (${(s.completeness * 100).round()}%)',
              style: theme.textTheme.titleLarge,
            ),
            const Divider(),
            _row(
              context,
              'จำนวนเงิน',
              s.amount == null ? null : formatBaht(s.amount!),
              big: true,
            ),
            _row(
              context,
              'วันที่-เวลา',
              s.dateTime == null ? null : formatThaiDateTime(s.dateTime!),
            ),
            _row(context, 'ผู้โอน', s.senderName),
            _row(context, 'ผู้รับ', s.receiverName),
            _row(context, 'ธนาคาร', s.bank.thaiName),
            _row(context, 'เลขอ้างอิง', s.reference),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final e in result.timingsMs.entries)
                  Chip(label: Text('${e.key} ${e.value} ms')),
              ],
            ),
            for (final e in result.errors.entries)
              Text(
                '${e.key} ผิดพลาด: ${e.value}',
                style: TextStyle(color: theme.colorScheme.error),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String? value, {
    bool big = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: theme.textTheme.bodyLarge),
          ),
          Expanded(
            child: Text(
              value ?? 'อ่านไม่ได้',
              style:
                  (big
                          ? theme.textTheme.headlineSmall
                          : theme.textTheme.bodyLarge)
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: value == null ? theme.colorScheme.error : null,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RawText extends StatelessWidget {
  const _RawText({required this.title, required this.text});

  final String title;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final t = text;
    return Card(
      child: ExpansionTile(
        title: Text(title),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (t == null || t.trim().isEmpty)
            const Text('(ไม่มีข้อมูล)')
          else ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Clipboard.setData(ClipboardData(text: t)),
                icon: const Icon(Icons.copy),
                label: const Text('คัดลอก'),
              ),
            ),
            SelectableText(t, style: const TextStyle(fontFamily: 'monospace')),
          ],
        ],
      ),
    );
  }
}
