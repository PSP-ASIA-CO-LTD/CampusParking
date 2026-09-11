import 'package:test/test.dart';

import 'package:campus_parking/parking_fee_calculator.dart';
import 'package:campus_parking/parking_summary.dart';
import 'package:campus_parking/parking_transaction.dart';

void main() {
  //starting state
  test('A new summary should start with every counter at zero', () {
    final summary = ParkingSummary();

    expect(summary.totalTransactions, 0);
    expect(summary.carCount, 0);
    expect(summary.motorcycleCount, 0);
    expect(summary.otherCount, 0);
    expect(summary.memberCount, 0);
    expect(summary.lostTicketCount, 0);
    expect(summary.totalRevenue, 0);
  });

  //accumulating transactions
  test('Summary should accumulate counters and revenue from three '
      'transactions', () {
    final calculator = ParkingFeeCalculator();
    final summary = ParkingSummary();

    final first = ParkingTransaction(
      plate: 'AB1234',
      vehicleType: 'car',
      duration: 30,
      isMember: false,
      lostTicket: false,
    );
    final second = ParkingTransaction(
      plate: 'CD5678',
      vehicleType: 'motorcycle',
      duration: 121,
      isMember: true,
      lostTicket: false,
    );
    final third = ParkingTransaction(
      plate: 'EF9012',
      vehicleType: 'car',
      duration: 10,
      isMember: true,
      lostTicket: true,
    );

    summary.addTransaction(first, calculator.calculateFee(first));
    summary.addTransaction(second, calculator.calculateFee(second));
    summary.addTransaction(third, calculator.calculateFee(third));

    expect(summary.totalTransactions, 3);
    expect(summary.carCount, 2);
    expect(summary.motorcycleCount, 1);
    expect(summary.memberCount, 2);
    expect(summary.lostTicketCount, 1);
    expect(summary.totalRevenue, 20 + 24 + 0);
  });

  //vehicle type counters
  test('Summary should count each vehicle type separately', () {
    final calculator = ParkingFeeCalculator();
    final summary = ParkingSummary();

    final car = ParkingTransaction(
      plate: 'AB1234',
      vehicleType: 'car',
      duration: 30,
      isMember: false,
      lostTicket: false,
    );
    final motorcycle = ParkingTransaction(
      plate: 'CD5678',
      vehicleType: 'motorcycle',
      duration: 30,
      isMember: false,
      lostTicket: false,
    );
    final other = ParkingTransaction(
      plate: 'EF9012',
      vehicleType: 'other',
      duration: 30,
      isMember: false,
      lostTicket: false,
    );

    summary.addTransaction(car, calculator.calculateFee(car));
    summary.addTransaction(motorcycle, calculator.calculateFee(motorcycle));
    summary.addTransaction(other, calculator.calculateFee(other));

    expect(summary.carCount, 1);
    expect(summary.motorcycleCount, 1);
    expect(summary.otherCount, 1);
    expect(summary.totalTransactions, 3);
  });

  //member is still a member even without a discount
  test('Summary should count a member whose ticket was lost', () {
    final calculator = ParkingFeeCalculator();
    final summary = ParkingSummary();

    final transaction = ParkingTransaction(
      plate: 'AB1234',
      vehicleType: 'car',
      duration: 30,
      isMember: true,
      lostTicket: true,
    );

    summary.addTransaction(transaction, calculator.calculateFee(transaction));

    expect(summary.memberCount, 1);
    expect(summary.lostTicketCount, 1);
    expect(summary.totalRevenue, 16);
  });

  //free parking still counts as a transaction
  test('Summary should count a free parking transaction with zero revenue', () {
    final calculator = ParkingFeeCalculator();
    final summary = ParkingSummary();

    final transaction = ParkingTransaction(
      plate: 'AB1234',
      vehicleType: 'car',
      duration: 10,
      isMember: false,
      lostTicket: false,
    );

    summary.addTransaction(transaction, calculator.calculateFee(transaction));

    expect(summary.totalTransactions, 1);
    expect(summary.totalRevenue, 0);
  });
}
