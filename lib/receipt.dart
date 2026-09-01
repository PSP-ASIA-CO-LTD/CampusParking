import 'parking_transaction.dart';
import 'parking_fee_calculator.dart';

class ParkingReceipt {
  //ParkingReceipt มีเท่านี้เพราะไม่จำเป็นต้องเก็บข้อมูลเอง แค่รับ transaction>ข้อมูลรถ>feeResult
  //>ผลคำนวณเงิน
  void printReceipt(
    ParkingTransaction transaction,
    ParkingFeeResult feeResult,
  ) {}
}
