import 'parking_transaction.dart';
import 'parking_fee_calculator.dart';

//::summary ต้องใช้ ข้อมูลจาก transaction และ fee::

class ParkingSummary {
  int totalTransactions = 0;
  int carCount = 0;
  int motorcycleCount = 0;
  int otherCount = 0;
  int memberCount = 0;
  int lostTicketCount = 0;
  double totalRevenue = 0;

  void addTransaction(
    ParkingTransaction transaction,
    ParkingFeeResult feeResult,
  ) {
    totalTransactions++;

    if (transaction.vehicleType == 'car') {
      carCount++;
    } else if (transaction.vehicleType == 'motorcycle') {
      motorcycleCount++;
    } else {
      otherCount++;
    }

    if (transaction.isMember) {
      memberCount++;
    }

    if (transaction.lostTicket) {
      lostTicketCount++;
    }

    totalRevenue += feeResult.finalFee;
  }
}
