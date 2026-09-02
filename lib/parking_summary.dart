import 'parking_transaction.dart';
import 'parking_fee_calculator.dart';

//::summary ต้องใช้ ข้อมูลจาก transaction และ fee::

// เก็บยอดสะสมของทั้งวันระหว่างที่โปรแกรมทำงาน
// field ทุกตัวเป็น private เพื่อให้แก้ไขได้ทางเดียวคือผ่าน addTransaction()
// ป้องกันไม่ให้ส่วนอื่นของโปรแกรมเขียนทับยอดรวมโดยตรง
class ParkingSummary {
  int _totalTransactions = 0;
  int _carCount = 0;
  int _motorcycleCount = 0;
  int _otherCount = 0;
  int _memberCount = 0;
  int _lostTicketCount = 0;
  double _totalRevenue = 0;

  // getter สำหรับให้ภายนอกอ่านค่าได้อย่างเดียว (ไม่มี setter จึงเขียนทับไม่ได้)
  int get totalTransactions => _totalTransactions;
  int get carCount => _carCount;
  int get motorcycleCount => _motorcycleCount;
  int get otherCount => _otherCount;
  int get memberCount => _memberCount;
  int get lostTicketCount => _lostTicketCount;
  double get totalRevenue => _totalRevenue;

  // ทางเข้าเดียวที่แก้ยอดสะสมได้ เรียกเมื่อ transaction สำเร็จแล้วเท่านั้น
  void addTransaction(
    ParkingTransaction transaction,
    ParkingFeeResult feeResult,
  ) {
    _totalTransactions++;

    if (transaction.vehicleType == 'car') {
      _carCount++;
    } else if (transaction.vehicleType == 'motorcycle') {
      _motorcycleCount++;
    } else {
      _otherCount++;
    }

    if (transaction.isMember) {
      _memberCount++;
    }

    if (transaction.lostTicket) {
      _lostTicketCount++;
    }

    _totalRevenue += feeResult.finalFee;
  }
}
