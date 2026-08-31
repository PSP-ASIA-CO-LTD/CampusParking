import 'parking_transaction.dart';

// ผลลัพธ์การคำนวณค่าจอดรถ แยกเป็น normal fee / discount / lost-ticket fee / final fee
class ParkingFeeResult {
  final int normalFee;
  final int discount;
  final int lostTicketFee;
  final int finalFee;

  ParkingFeeResult({
    required this.normalFee,
    required this.discount,
    required this.lostTicketFee,
    required this.finalFee,
  });
}

// คำนวณค่าจอดรถจากข้อมูล ParkingTransaction
class ParkingFeeCalculator {
  ParkingFeeResult calculateFee(ParkingTransaction transaction) {
    if (transaction.lostTicket) {
      // Lost ticket fee replaces everything: no duration, no cap, no discount
      int lostTicketFee;

      if (transaction.vehicleType == 'car') {
        lostTicketFee = 200;
      } else if (transaction.vehicleType == 'motorcycle') {
        lostTicketFee = 100;
      } else {
        lostTicketFee = 300;
      }

      return ParkingFeeResult(
        normalFee: 0,
        discount: 0,
        lostTicketFee: lostTicketFee,
        finalFee: lostTicketFee,
      );
    }

    int normalFee = 0;
    int hours = 0;

    if (transaction.duration > 15) {
      hours = (transaction.duration + 59) ~/ 60;

      if (transaction.vehicleType == 'car') {
        normalFee = hours * 20;
        if (normalFee > 100) {
          normalFee = 100;
        }
      } else if (transaction.vehicleType == 'motorcycle') {
        normalFee = hours * 10;
        if (normalFee > 50) {
          normalFee = 50;
        }
      } else {
        normalFee = hours * 30;
        if (normalFee > 150) {
          normalFee = 150;
        }
      }
    }

    // Member discount
    int finalFee = normalFee;
    int discount = 0;

    if (transaction.isMember) {
      finalFee = (normalFee * 0.8).round();
      discount = normalFee - finalFee;
    }

    return ParkingFeeResult(
      normalFee: normalFee,
      discount: discount,
      lostTicketFee: 0,
      finalFee: finalFee,
    );
  }
}
