import 'parking_transaction.dart';

// ผลลัพธ์การคำนวณค่าจอดรถ แยกเป็น normal fee / discount / final fee
class ParkingFeeResult {
  final int normalFee;
  final int discount;
  final int finalFee;

  ParkingFeeResult({
    required this.normalFee,
    required this.discount,
    required this.finalFee,
  });
}

// คำนวณค่าจอดรถจากข้อมูล ParkingTransaction
// บัตรหายไม่มีค่าปรับแล้ว เป็นเพียงข้อมูลที่ ParkingSummary นับจำนวนไว้
class ParkingFeeCalculator {
  ParkingFeeResult calculateFee(ParkingTransaction transaction) {
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
      finalFee: finalFee,
    );
  }
}
