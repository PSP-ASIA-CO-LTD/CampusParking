import 'dart:io';

import 'package:campus_parking/parking_fee_calculator.dart';
import 'package:campus_parking/parking_transaction.dart';
import 'package:campus_parking/parking_summary.dart';
import 'package:campus_parking/parking_receipt.dart';

// คำสั่งที่ผู้ใช้พิมพ์เพื่อยกเลิก transaction ที่กำลังกรอกอยู่
// เก็บเป็นค่าคงที่จุดเดียว ถ้าอยากเปลี่ยนคำสั่งจะได้แก้ที่เดียว
const String cancelCommand = 'cancel';

void main() {
  ParkingFeeCalculator feeCalculator = ParkingFeeCalculator();
  ParkingSummary summary = ParkingSummary();
  ParkingReceipt receipt = ParkingReceipt();

  while (true) {
    print('========================================');
    print('CAMPUS PARKING SYSTEM');
    print('========================================');
    print('1. New parking transaction');
    print('2. Show daily summary');
    print('3. Exit');

    stdout.write('Select: ');
    String? choice = stdin.readLineSync()?.trim();

    if (choice == '1') {
      ParkingTransaction? transaction = readTransaction();

      // ยกเลิกกลางคัน: ไม่คำนวณ ไม่ออกใบเสร็จ และไม่นับเข้า daily summary
      if (transaction == null) {
        print('Transaction cancelled.');
        continue;
      }

      ParkingFeeResult feeResult = feeCalculator.calculateFee(transaction);
      receipt.printReceipt(transaction, feeResult);

      print('Car Out');

      // นับเข้ายอดสะสมเมื่อรายการสำเร็จแล้วเท่านั้น
      summary.addTransaction(transaction, feeResult);
    } else if (choice == '2') {
      print('========================================');
      print('DAILY SUMMARY');
      print('========================================');
      print('Total transactions : ${summary.totalTransactions}');
      print('Cars               : ${summary.carCount}');
      print('Motorcycles        : ${summary.motorcycleCount}');
      print('Other              : ${summary.otherCount}');
      print('Members            : ${summary.memberCount}');
      print('Lost tickets       : ${summary.lostTicketCount}');
      print(
        'Total revenue      : ${summary.totalRevenue.toStringAsFixed(2)} THB',
      );
    } else if (choice == '3') {
      break;
    } else {
      print('Invalid choice. Please try again.');
    }
  }
}

// รวบรวมข้อมูลของ transaction หนึ่งรายการจากผู้ใช้
// คืน null ถ้าผู้ใช้ยกเลิกที่ขั้นตอนใดก็ตาม
ParkingTransaction? readTransaction() {
  String? plate = readPlate();
  if (plate == null) return null;

  String? vehicleType = readVehicleType();
  if (vehicleType == null) return null;

  int? duration = readDuration();
  if (duration == null) return null;

  bool? isMember = readYesNo('Member?');
  if (isMember == null) return null;

  bool? lostTicket = readYesNo('Lost ticket?');
  if (lostTicket == null) return null;

  return ParkingTransaction(
    plate: plate,
    vehicleType: vehicleType,
    duration: duration,
    isMember: isMember,
    lostTicket: lostTicket,
  );
}

/// อ่านทะเบียนรถ ต้องไม่เป็นค่าว่าง
/// trim() ก่อนตรวจ ถ้ากรอกเว้นวรรคล้วน ๆ ก็ถือว่ายังไม่ได้กรอก
String? readPlate() {
  while (true) {
    stdout.write('Enter plate number (type "$cancelCommand" to cancel): ');
    String input = (stdin.readLineSync() ?? '').trim();

    if (input.toLowerCase() == cancelCommand) {
      return null;
    }

    if (input.isNotEmpty) {
      return input;
    }

    print('Plate cannot be empty. Please try again.');
  }
}

/// อ่านประเภทรถ รับเฉพาะ car / motorcycle / other เท่านั้น
/// input อื่นถือว่าไม่ถูกต้อง ให้ถามใหม่แทนการเดาประเภทรถให้ผู้ใช้
String? readVehicleType() {
  while (true) {
    print('Which vehicle type?');
    stdout.write(
      'Car or Motorcycle or Other (type "$cancelCommand" to cancel): ',
    );

    // ?? '' กัน null จาก readLineSync แล้วค่อย trim/toLowerCase
    // เพื่อให้ ' CAR ' กับ 'car' ถือเป็นค่าเดียวกัน
    String input = (stdin.readLineSync() ?? '').trim().toLowerCase();

    if (input == cancelCommand) {
      return null;
    }

    if (input == 'car' || input == 'motorcycle' || input == 'other') {
      return input;
    }

    print('Invalid vehicle type. Please enter car, motorcycle or other.');
  }
}

// ใช้ tryParse เพราะ input จากผู้ใช้อาจไม่ใช่ตัวเลข ถ้าใช้ parse โปรแกรมจะพัง
int? readDuration() {
  while (true) {
    stdout.write('Parking duration (min) (type "$cancelCommand" to cancel): ');
    String input = (stdin.readLineSync() ?? '').trim();

    if (input.toLowerCase() == cancelCommand) {
      return null;
    }

    int? parsedDuration = int.tryParse(input);

    if (parsedDuration == null) {
      print('Invalid number. Please try again.');
      continue;
    }

    if (parsedDuration < 0) {
      print('Duration cannot be negative.');
      continue;
    }

    return parsedDuration;
  }
}

bool? readYesNo(String question) {
  while (true) {
    stdout.write('$question (y/n, type "$cancelCommand" to cancel): ');
    String input = (stdin.readLineSync() ?? '').trim().toLowerCase();

    if (input == cancelCommand) {
      return null;
    }
    if (input == 'y') {
      return true;
    }
    if (input == 'n') {
      return false;
    }

    print('Please enter y or n.');
  }
}
