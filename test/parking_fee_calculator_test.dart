import 'package:test/test.dart';

import '../lib/parking_fee_calculator.dart';
import '../lib/parking_transaction.dart';

void main() {
  //car test
  test('Car parked for 15 minutes should be free', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'car',
      duration: 15,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 0);
    expect(result.finalFee, 0);
  });

  test('Car parked for 16 minutes should cost 20 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'car',
      duration: 16,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 20);
    expect(result.finalFee, 20);
  });

  test('Car parked for 60 minutes should cost 20 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'car',
      duration: 60,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 20);
    expect(result.finalFee, 20);
  });

  test('Car parked for 61 minutes should cost 40 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'car',
      duration: 61,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 40);
    expect(result.finalFee, 40);
  });

  test('Car parked for 360 minutes should be capped at 100 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'car',
      duration: 360,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 100);
    expect(result.finalFee, 100);
  });


  //motorcycle test
  test('Motorcycle parked for 15 minutes should be free',(){});

}
