import 'dart:io';

import '../lib/parking_transaction.dart';

//ประกาศตัวแปรไว้ นอก main() และนอก loop ทำให้ค่ามันสะสมตลอดการทำงานของโปรแกรมและไม่ถูก reset เมื่อเริ่ม transaction ใหม่(Interation3)
int totalTransactions = 0;
int carCount = 0;
int motorcycleCount = 0;
int otherCount = 0;
int memberCount = 0;
int lostTicketCount = 0;
double totalRevenue = 0;

void main() {
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
      // Plate
      stdout.write('Enter plate number: ');
      String? plate = stdin.readLineSync();

      print('Plate: $plate');

      // Vehicle Type
      print('Which vehicle type?');
      print('Car or Motorcycle or Other');

      String? vehicleType = stdin.readLineSync()?.trim().toLowerCase();

      if (vehicleType == 'car') {
        print('Vehicle: Car');
      } else if (vehicleType == 'motorcycle') {
        print('Vehicle: Motorcycle');
      } else {
        print('Vehicle: Other');
      }

      // Duration
      int duration;

      while (true) {
        stdout.write('Parking duration (min): ');
        String? durationInput = stdin.readLineSync();

        int? parsedDuration = int.tryParse(durationInput?.trim() ?? '');

        if (parsedDuration == null) {
          print('Invalid number. Please try again.');
          continue;
        }

        if (parsedDuration < 0) {
          print('Duration cannot be negative.');
          continue;
        }

        duration = parsedDuration;
        break;
      }

      print('Duration: $duration minutes');

      // Member validation
      bool isMember = false;

      while (true) {
        stdout.write('Member? (y/n): ');
        String? input = stdin.readLineSync()?.trim().toLowerCase();

        if (input == 'y') {
          isMember = true;
          break;
        }

        if (input == 'n') {
          isMember = false;
          break;
        }

        print('Please enter y or n.');
      }

      // Lost ticket validation
      bool lostTicket = false;

      while (true) {
        stdout.write('Lost ticket? (y/n): ');
        String? input = stdin.readLineSync()?.trim().toLowerCase();

        if (input == 'y') {
          lostTicket = true;
          break;
        }

        if (input == 'n') {
          lostTicket = false;
          break;
        }

        print('Please enter y or n.');
      }

      // Store transaction data
      ParkingTransaction transaction = ParkingTransaction(
        plate,
        vehicleType,
        duration,
        isMember,
        lostTicket,
      );

      // Calculate fee
      int fee = 0;

      if (transaction.lostTicket) {
        // Lost ticket fee replaces everything: no duration, no cap, no discount
        if (transaction.vehicleType == 'car') {
          fee = 200;
        } else if (transaction.vehicleType == 'motorcycle') {
          fee = 100;
        } else {
          fee = 300;
        }
      } else {
        int hours = 0;

        if (transaction.duration <= 15) {
          fee = 0;
        } else {
          hours = (transaction.duration + 59) ~/ 60;

          if (transaction.vehicleType == 'car') {
            fee = hours * 20;
            if (fee > 100) {
              fee = 100;
            }
          } else if (transaction.vehicleType == 'motorcycle') {
            fee = hours * 10;
            if (fee > 50) {
              fee = 50;
            }
          } else {
            fee = hours * 30;
            if (fee > 150) {
              fee = 150;
            }
          }
        }

        // Member discount
        if (transaction.isMember) {
          fee = (fee * 0.8).round();
        }
      }

      transaction.fee = fee;

      print('Final fee: ${transaction.fee} baht');
      print('Car Out');
      // Update daily summary
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

      totalRevenue += transaction.fee;
    } else if (choice == '2') {
      print('========================================');
      print('DAILY SUMMARY');
      print('========================================');
      print('Total transactions : $totalTransactions');
      print('Cars               : $carCount');
      print('Motorcycles        : $motorcycleCount');
      print('Other              : $otherCount');
      print('Members            : $memberCount');
      print('Lost tickets       : $lostTicketCount');
      print('Total revenue      : ${totalRevenue.toStringAsFixed(2)} THB');
    } else if (choice == '3') {
      break;
    } else {
      print('Invalid choice. Please try again.');
    }
  }
}
