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
}
