// เก็บข้อมูลของ parking transaction หนึ่งครั้ง
class ParkingTransaction {
  String? plate;
  String? vehicleType;
  int duration;
  bool isMember;
  bool lostTicket;
  int fee = 0;

  ParkingTransaction(
    this.plate,
    this.vehicleType,
    this.duration,
    this.isMember,
    this.lostTicket,
  );
}
