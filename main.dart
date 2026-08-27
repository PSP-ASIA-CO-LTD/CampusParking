import 'dart:io';

//ประกาศตัวแปรไว้ นอก main() และนอก loop ทำให้ค่ามันสะสมตลอดการทำงานของโปรแกรมและไม่ถูก reset เมื่อเริ่ม transaction ใหม่(Interation3)
int totalTransactions = 0;
int carCount = 0;
int motorcycleCount = 0;
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
    String? choice = stdin.readLineSync();

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

      // Calculate fee
      int fee = 0;

      if (lostTicket) {
        // Lost ticket fee replaces everything: no duration, no cap, no discount
        if (vehicleType == 'car') {
          fee = 200;
        } else if (vehicleType == 'motorcycle') {
          fee = 100;
        } else {
          fee = 300;
        }
      } else {
        int hours = 0;

        if (duration <= 15) {
          fee = 0;
        } else {
          hours = (duration + 59) ~/ 60;

          if (vehicleType == 'car') {
            fee = hours * 20;
            if (fee > 100) {
              fee = 100;
            }
          } else if (vehicleType == 'motorcycle') {
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
        if (isMember) {
          fee = (fee * 0.8).round();
        }
      }

      print('Final fee: $fee baht');
      print('Car Out');
      // Update daily summary
      totalTransactions++;

      if (vehicleType == 'car') {
        carCount++;
      } else if (vehicleType == 'motorcycle') {
        motorcycleCount++;
      }

      if (isMember) {
        memberCount++;
      }

      if (lostTicket) {
        lostTicketCount++;
      }

      totalRevenue += fee;
    } else if (choice == '2') {
      print('========================================');
      print('DAILY SUMMARY');
      print('========================================');
      print('Total transactions : $totalTransactions');
      print('Cars               : $carCount');
      print('Motorcycles        : $motorcycleCount');
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
