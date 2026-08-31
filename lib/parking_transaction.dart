// เก็บข้อมูลของ parking transaction หนึ่งครั้ง
class ParkingTransaction {
  final String plate;
  final String vehicleType;
  final int duration;
  final bool isMember;
  final bool lostTicket;

  ParkingTransaction({
    required this.plate,
    required this.vehicleType,
    required this.duration,
    required this.isMember,
    required this.lostTicket,
  });
}
