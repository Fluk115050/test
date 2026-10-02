/// ธนาคารที่รองรับ พร้อมรหัสธนาคาร 3 หลัก (ใช้ใน QR ของสลิป)
enum Bank {
  kbank('004', 'กสิกรไทย'),
  scb('014', 'ไทยพาณิชย์'),
  bbl('002', 'กรุงเทพ'),
  ktb('006', 'กรุงไทย'),
  bay('025', 'กรุงศรีอยุธยา'),
  ttb('011', 'ทหารไทยธนชาต'),
  gsb('030', 'ออมสิน'),
  unknown('', 'ไม่ทราบธนาคาร');

  const Bank(this.code, this.thaiName);

  final String code;
  final String thaiName;

  static Bank fromCode(String code) {
    // 065 = ธนชาต (ควบรวมเป็น ttb แล้ว)
    if (code == '065') return Bank.ttb;
    return Bank.values.firstWhere(
      (b) => b.code == code && b != Bank.unknown,
      orElse: () => Bank.unknown,
    );
  }
}

/// ข้อมูลที่ดึงได้จากสลิป 1 ใบ (ทุกช่องอาจเป็น null ถ้าอ่านไม่ได้)
class SlipData {
  const SlipData({
    this.amount,
    this.dateTime,
    this.senderName,
    this.receiverName,
    this.bank = Bank.unknown,
    this.reference,
  });

  final double? amount;
  final DateTime? dateTime;
  final String? senderName;
  final String? receiverName;

  /// ธนาคารที่ออกสลิป (ธนาคารของผู้โอน)
  final Bank bank;

  /// เลขที่รายการ/รหัสอ้างอิง ใช้กันบันทึกซ้ำในขั้นต่อไป
  final String? reference;

  /// สัดส่วนช่องหลักที่อ่านได้ (0..1)
  double get completeness {
    final fields = [amount, dateTime, senderName, receiverName];
    return fields.where((f) => f != null).length / fields.length;
  }

  SlipData copyWith({
    double? amount,
    DateTime? dateTime,
    String? senderName,
    String? receiverName,
    Bank? bank,
    String? reference,
  }) => SlipData(
    amount: amount ?? this.amount,
    dateTime: dateTime ?? this.dateTime,
    senderName: senderName ?? this.senderName,
    receiverName: receiverName ?? this.receiverName,
    bank: bank ?? this.bank,
    reference: reference ?? this.reference,
  );

  /// เติมช่องที่ยังว่างด้วยค่าจาก [other]
  SlipData fillFrom(SlipData other) => SlipData(
    amount: amount ?? other.amount,
    dateTime: dateTime ?? other.dateTime,
    senderName: senderName ?? other.senderName,
    receiverName: receiverName ?? other.receiverName,
    bank: bank != Bank.unknown ? bank : other.bank,
    reference: reference ?? other.reference,
  );

  @override
  String toString() =>
      'SlipData(amount: $amount, dateTime: $dateTime, sender: $senderName, '
      'receiver: $receiverName, bank: ${bank.name}, ref: $reference)';
}
