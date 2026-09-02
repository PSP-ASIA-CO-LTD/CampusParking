import 'dart:io';

import 'package:campus_parking/parking_fee_calculator.dart';
import 'package:campus_parking/parking_transaction.dart';
import 'package:campus_parking/parking_summary.dart';
import 'package:campus_parking/parking_receipt.dart';

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
      // Plate
      stdout.write('Enter plate number: ');
      String plate = stdin.readLineSync() ?? '';

      print('Plate: $plate');

      // Vehicle Type
      print('Which vehicle type?');
      print('Car or Motorcycle or Other');

      String vehicleType = (stdin.readLineSync() ?? '').trim().toLowerCase();

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
        plate: plate,
        vehicleType: vehicleType,
        duration: duration,
        isMember: isMember,
        lostTicket: lostTicket,
      );

      // Calculate fee
      ParkingFeeResult feeResult = feeCalculator.calculateFee(transaction);
      //receipt
      receipt.printReceipt(transaction, feeResult);

      print('Final fee: ${feeResult.finalFee} baht');
      print('Car Out');

      // Update daily summary
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
