import 'package:test/test.dart';

import '../lib/parking_fee_calculator.dart';
import '../lib/parking_transaction.dart';

void main() {
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
;
});
}
