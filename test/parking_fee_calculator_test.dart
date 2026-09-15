import 'package:test/test.dart';

import 'package:campus_parking/parking_fee_calculator.dart';
import 'package:campus_parking/parking_transaction.dart';

// Boundary cases (ค่าจอดปกติ)
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
  test('Motorcycle parked for 15 minutes should be free', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'motorcycle',
      duration: 15,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 0);
    expect(result.finalFee, 0);
  });

  test('Motorcycle parked for 16 minutes should cost 10 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'motorcycle',
      duration: 16,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 10);
    expect(result.finalFee, 10);
  });

  test('Motorcycle parked for 60 minutes should cost 10 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'motorcycle',
      duration: 60,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 10);
    expect(result.finalFee, 10);
  });

  test('Motorcycle parked for 61 minutes should cost 20 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'motorcycle',
      duration: 61,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 20);
    expect(result.finalFee, 20);
  });

  test('Motorcycle parked for 360 minutes should cost 50 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'motorcycle',
      duration: 360,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 50);
    expect(result.finalFee, 50);
  });

  //Other vehicle

  test('Other vehicle parked for 15 minutes should cost 0 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'other',
      duration: 15,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 0);
    expect(result.finalFee, 0);
  });

  test('Other vehicle parked for 16 minutes should cost 30 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'other',
      duration: 30,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 30);
    expect(result.finalFee, 30);
  });

  test('Other vehicle parked for 61 minutes should cost 60 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'other',
      duration: 61,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 60);
    expect(result.finalFee, 60);
  });

  test('Other vehicle parked for 360 minutes should cost 150 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'other',
      duration: 360,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 150);
    expect(result.finalFee, 150);
  });

  //member
  test('Member car parked for 16 minutes should cost 16 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'car',
      duration: 16,
      isMember: true,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 20);
    expect(result.finalFee, 16);
  });

  test('Member car parked for 360 minutes should cost 80 baht after cap and discount', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'car',
      duration: 360,
      isMember: true,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 100);
    expect(result.finalFee, 80);
  });

  //lost ticket does not add any fee any more
  test('Car with a lost ticket should still pay the normal fee', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'car',
      duration: 30,
      isMember: false,
      lostTicket: true,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 20);
    expect(result.finalFee, 20);
  });

  test('Motorcycle with a lost ticket should still pay the normal fee', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'motorcycle',
      duration: 30,
      isMember: false,
      lostTicket: true,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 10);
    expect(result.finalFee, 10);
  });

  test('Other vehicle with a lost ticket should still pay the normal fee', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'other',
      duration: 30,
      isMember: false,
      lostTicket: true,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 30);
    expect(result.finalFee, 30);
  });

  //more car boundary cases
  test('Car parked for 0 minutes should be free', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'car',
      duration: 0,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 0);
    expect(result.finalFee, 0);
  });

  test('Car parked for 120 minutes should cost 40 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'car',
      duration: 120,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 40);
    expect(result.finalFee, 40);
  });

  test('Car parked for 121 minutes should cost 60 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'car',
      duration: 121,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 60);
    expect(result.finalFee, 60);
  });

  test('Car parked for 500 minutes should be capped at 100 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'car',
      duration: 500,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 100);
    expect(result.finalFee, 100);
  });

  test(
    'Car parked for a very long time should still be capped at 100 baht',
    () {
      final calculator = ParkingFeeCalculator();
      final transaction = ParkingTransaction(
        plate: 'ABC123',
        vehicleType: 'car',
        duration: 999999,
        isMember: false,
        lostTicket: false,
      );

      final result = calculator.calculateFee(transaction);

      expect(result.normalFee, 100);
      expect(result.finalFee, 100);
    },
  );

  //more motorcycle boundary cases
  test('Motorcycle parked for 121 minutes should cost 30 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'motorcycle',
      duration: 121,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 30);
    expect(result.finalFee, 30);
  });

  test('Motorcycle parked for 500 minutes should be capped at 50 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'motorcycle',
      duration: 500,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 50);
    expect(result.finalFee, 50);
  });

  //more other-vehicle cases
  test('Other vehicle parked for 30 minutes should cost 30 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'other',
      duration: 30,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 30);
    expect(result.finalFee, 30);
  });

  test('Other vehicle parked for 500 minutes should be capped at 150 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'other',
      duration: 500,
      isMember: false,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 150);
    expect(result.finalFee, 150);
  });

  //member discount combined with other rules
  test(
    'Member car should get the discount after the maximum fee is applied',
    () {
      final calculator = ParkingFeeCalculator();
      final transaction = ParkingTransaction(
        plate: 'ABC123',
        vehicleType: 'car',
        duration: 500,
        isMember: true,
        lostTicket: false,
      );

      final result = calculator.calculateFee(transaction);

      expect(result.normalFee, 100);
      expect(result.discount, 20);
      expect(result.finalFee, 80);
    },
  );

  test('Member motorcycle parked for 500 minutes should cost 40 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'motorcycle',
      duration: 500,
      isMember: true,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 50);
    expect(result.discount, 10);
    expect(result.finalFee, 40);
  });

  test('Member parked within the free period should get no discount', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'car',
      duration: 10,
      isMember: true,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 0);
    expect(result.discount, 0);
    expect(result.finalFee, 0);
  });

  test('Member car parked for 185 minutes should cost 64 baht', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'car',
      duration: 185,
      isMember: true,
      lostTicket: false,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 80);
    expect(result.discount, 16);
    expect(result.finalFee, 64);
  });

  test('Member with a lost ticket should still get the member discount', () {
    final calculator = ParkingFeeCalculator();
    final transaction = ParkingTransaction(
      plate: 'ABC123',
      vehicleType: 'car',
      duration: 30,
      isMember: true,
      lostTicket: true,
    );

    final result = calculator.calculateFee(transaction);

    expect(result.normalFee, 20);
    expect(result.discount, 4);
    expect(result.finalFee, 16);
  });
}
