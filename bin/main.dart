import 'dart:io';

import 'package:campus_parking/parking_fee_calculator.dart';
import 'package:campus_parking/parking_transaction.dart';
import 'package:campus_parking/parking_summary.dart';
import 'package:campus_parking/parking_receipt.dart';
import 'package:campus_parking/parking_menu.dart';
import 'package:campus_parking/plate_rules.dart';

// คำสั่งที่ผู้ใช้พิมพ์เพื่อยกเลิก transaction ที่กำลังกรอกอยู่
// เก็บเป็นค่าคงที่จุดเดียว ถ้าอยากเปลี่ยนคำสั่งจะได้แก้ที่เดียว
const String cancelCommand = 'cancel';

void main() {
  ParkingFeeCalculator feeCalculator = ParkingFeeCalculator();
  ParkingSummary summary = ParkingSummary();
  ParkingReceipt receipt = ParkingReceipt();

  while (true) {
    printMainMenu();

    stdout.write('Select: ');
    String? choice = stdin.readLineSync()?.trim();

    // อ่านค่าไม่ได้แล้ว แปลว่าไม่มีใครป้อนข้อมูลต่อ จึงปิดโปรแกรม
    // ถ้าไม่ดักไว้ จะวนพิมพ์ Invalid choice ไม่รู้จบ
    if (choice == null) {
      break;
    }

    if (choice == '1') {
      ParkingTransaction? transaction = readTransaction();

      // ยกเลิกกลางคัน: ไม่คำนวณ ไม่ออกใบเสร็จ และไม่นับเข้า daily summary
      if (transaction == null) {
        print('Transaction cancelled.');
        continue;
      }

      ParkingFeeResult feeResult = feeCalculator.calculateFee(transaction);
      receipt.printReceipt(transaction, feeResult);

      // บันทึกว่า transaction นี้สำเร็จและเพิ่มยอดสะสม
      summary.addTransaction(transaction, feeResult);
      //เป็นขั้นตอนสุดท้าย รถสามารถออกได้จย้า
      print('Car Out');
    } else if (choice == '2') {
      printDailySummary(summary);
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

  // ทะเบียนที่ลงท้ายด้วยตัวอักษร 3 ตัว เป็นมอเตอร์ไซค์อยู่แล้ว จึงไม่ต้องถาม
  String vehicleType;
  if (isMotorcyclePlate(plate)) {
    vehicleType = 'motorcycle';
  } else {
    // ทะเบียนไม่ได้บอกประเภท จึงต้องถามเจ้าหน้าที่ตามปกติ
    String? answer = readVehicleType();
    if (answer == null) return null;
    vehicleType = answer;
  }

  int? duration = readDuration();
  if (duration == null) return null;

  // สมาชิกถูกตัดสินจากรูปแบบทะเบียนโดยตรง จึงไม่ถามผู้ใช้อีก
  bool isMember = isMemberPlate(plate);

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
    String? line = stdin.readLineSync();

    // อ่านค่าไม่ได้แล้ว แปลว่าไม่มีใครกรอกต่อ ต่างจากการกด Enter เปล่า
    // ที่ยังได้ค่าว่างกลับมา กรณีนี้จึงถือว่ายกเลิกรายการ
    if (line == null) {
      return null;
    }

    String input = line.trim();

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

    String? line = stdin.readLineSync();

    // อ่านค่าไม่ได้แล้ว แปลว่าไม่มีใครกรอกต่อ ต่างจากการกด Enter เปล่า
    // ที่ยังได้ค่าว่างกลับมา กรณีนี้จึงถือว่ายกเลิกรายการ
    if (line == null) {
      return null;
    }

    // trim/toLowerCase เพื่อให้ ' CAR ' กับ 'car' ถือเป็นค่าเดียวกัน
    String input = line.trim().toLowerCase();

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
    String? line = stdin.readLineSync();

    // อ่านค่าไม่ได้แล้ว แปลว่าไม่มีใครกรอกต่อ ต่างจากการกด Enter เปล่า
    // ที่ยังได้ค่าว่างกลับมา กรณีนี้จึงถือว่ายกเลิกรายการ
    if (line == null) {
      return null;
    }

    String input = line.trim();

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
    String? line = stdin.readLineSync();

    // อ่านค่าไม่ได้แล้ว แปลว่าไม่มีใครกรอกต่อ ต่างจากการกด Enter เปล่า
    // ที่ยังได้ค่าว่างกลับมา กรณีนี้จึงถือว่ายกเลิกรายการ
    if (line == null) {
      return null;
    }

    String input = line.trim().toLowerCase();

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
