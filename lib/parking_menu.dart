import 'parking_summary.dart';

// แยกออกจาก main.dart เพื่อให้ main เหลือแค่การควบคุม flow

// แสดงเมนูหลัก
void printMainMenu() {
  print('========================================');
  print('CAMPUS PARKING SYSTEM');
  print('========================================');
  print('1. New parking transaction');
  print('2. Show daily summary');
  print('3. Exit');
}

// แสดงยอดสรุปประจำวัน อ่านค่าผ่าน getter ของ ParkingSummary เท่านั้น
void printDailySummary(ParkingSummary summary) {
  print('========================================');
  print('DAILY SUMMARY');
  print('========================================');
  print('Total transactions : ${summary.totalTransactions}');
  print('Cars               : ${summary.carCount}');
  print('Motorcycles        : ${summary.motorcycleCount}');
  print('Other              : ${summary.otherCount}');
  print('Members            : ${summary.memberCount}');
  print('Lost tickets       : ${summary.lostTicketCount}');
  print('Total revenue      : ${summary.totalRevenue.toStringAsFixed(2)} THB');
}
