import '../slip_data.dart';

/// ข้อมูลจาก QR บนสลิป (มาตรฐาน Slip Verification ของ ธปท./สมาคมธนาคารไทย)
/// รูปแบบ TLV: tag 00 มี sub-tag 01 = รหัสธนาคารผู้โอน, 02 = เลขอ้างอิงรายการ
class SlipQr {
  const SlipQr({required this.bank, this.reference});

  final Bank bank;
  final String? reference;

  static SlipQr? tryParse(String? payload) {
    if (payload == null || payload.length < 10) return null;
    final top = _tlv(payload.trim());
    final inner = top['00'];
    if (inner == null) return null;
    final sub = _tlv(inner);
    final code = sub['01'];
    if (code == null) return null;
    return SlipQr(bank: Bank.fromCode(code), reference: sub['02']);
  }

  static Map<String, String> _tlv(String s) {
    final out = <String, String>{};
    var i = 0;
    while (i + 4 <= s.length) {
      final tag = s.substring(i, i + 2);
      final len = int.tryParse(s.substring(i + 2, i + 4));
      if (len == null || i + 4 + len > s.length) break;
      out[tag] = s.substring(i + 4, i + 4 + len);
      i += 4 + len;
    }
    return out;
  }
}
