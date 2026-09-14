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

  
}
