import 'parking_transaction.dart';
import 'parking_fee_calculator.dart';

class ParkingReceipt{
  final String plate;
  final String vehicleType;
  final int duration;
  final int normalFee;
  final int discount;
  final int lostTicketFee;
  final int finalFee;

  ParkingReceipt({
  required this.plate,
  required this.vehicleType,
  required this.duration,
  required this.normalFee,
  required this.discount,
  required this.lostTicketFee,
  required this.finalFee,
});

} 


