/// จัดรูปแบบตัวเลข/วันที่ภาษาไทย (ไม่พึ่ง intl)
const _months = [
  'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', //
  'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
];

String formatBaht(double v) {
  final parts = v.toStringAsFixed(2).split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '$intPart.${parts[1]} บาท';
}

String formatThaiDateTime(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.day} ${_months[d.month - 1]} ${d.year + 543} '
      '${two(d.hour)}:${two(d.minute)} น.';
}
