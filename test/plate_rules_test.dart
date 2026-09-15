import 'package:test/test.dart';

import 'package:campus_parking/plate_rules.dart';

void main() {
  //ทะเบียนที่เข้ากฎสมาชิก
  test('A plate starting with two digits and a hyphen should be a member', () {
    expect(isMemberPlate('12-ABC'), isTrue);
  });

  test('A plate with three digits and a hyphen should be a member', () {
    expect(isMemberPlate('123-ABC'), isTrue);
  });

  test('A plate starting with one digit and a hyphen should be a member', () {
    expect(isMemberPlate('1-AB'), isTrue);
  });

  test('Surrounding spaces should not change the result', () {
    expect(isMemberPlate('  12-ABC  '), isTrue);
  });

  //ทะเบียนที่ไม่เข้ากฎสมาชิก
  test('A plate starting with letters should not be a member', () {
    expect(isMemberPlate('ABC123'), isFalse);
  });

  test('A plate with digits but no hyphen should not be a member', () {
    expect(isMemberPlate('12ABC'), isFalse);
  });

  test('A plate made of digits only should not be a member', () {
    expect(isMemberPlate('1234'), isFalse);
  });

  test('A plate with nothing after the hyphen should not be a member', () {
    expect(isMemberPlate('12-'), isFalse);
  });

  test('A plate starting with a hyphen should not be a member', () {
    expect(isMemberPlate('-123'), isFalse);
  });

  test('A plate whose hyphen comes after letters should not be a member', () {
    expect(isMemberPlate('AB-123'), isFalse);
  });

  //ทะเบียนที่เข้ากฎมอเตอร์ไซค์
  test('A plate ending with three letters should be a motorcycle', () {
    expect(isMotorcyclePlate('12-ABC'), isTrue);
  });

  test('Only the last three characters should matter', () {
    expect(isMotorcyclePlate('12-ABCD'), isTrue);
  });

  test('A plate of exactly three letters should be a motorcycle', () {
    expect(isMotorcyclePlate('ABC'), isTrue);
  });

  test('Lower case letters should count as letters', () {
    expect(isMotorcyclePlate('12-abc'), isTrue);
  });

  test('Surrounding spaces should not change the motorcycle result', () {
    expect(isMotorcyclePlate('  12-ABC  '), isTrue);
  });

  //ทะเบียนที่ไม่เข้ากฎมอเตอร์ไซค์
  test('A plate ending with digits should not be a motorcycle', () {
    expect(isMotorcyclePlate('ABC123'), isFalse);
  });

  test('A plate with two trailing letters should not be a motorcycle', () {
    expect(isMotorcyclePlate('12-AB'), isFalse);
  });

  test('A plate shorter than three characters is not a motorcycle', () {
    expect(isMotorcyclePlate('AB'), isFalse);
  });

  test('A plate made of digits only should not be a motorcycle', () {
    expect(isMotorcyclePlate('1234'), isFalse);
  });

  test('A plate ending with one digit should not be a motorcycle', () {
    expect(isMotorcyclePlate('12-AB1'), isFalse);
  });

  //กฎสองข้อทำงานพร้อมกันได้ เคสนี้จดข้อตกลงนั้นไว้เป็นลายลักษณ์อักษร
  test('A plate can be both a member plate and a motorcycle plate', () {
    expect(isMemberPlate('12-ABC'), isTrue);
    expect(isMotorcyclePlate('12-ABC'), isTrue);
  });
}
