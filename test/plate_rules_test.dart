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

  //ทะเบียนที่เข้ากฎรถเก๋ง
  test('Two letters and three digits should be a car', () {
    expect(isCarPlate('AB123'), isTrue);
  });

  test('Two letters and four digits should be a car', () {
    expect(isCarPlate('AB1234'), isTrue);
  });

  test('Lower case letters should count for the car rule too', () {
    expect(isCarPlate('ab1234'), isTrue);
  });

  test('Surrounding spaces should not change the car result', () {
    expect(isCarPlate('  AB1234  '), isTrue);
  });

  //ทะเบียนที่ไม่เข้ากฎรถเก๋ง
  test('One leading letter is not enough to be a car', () {
    expect(isCarPlate('A1234'), isFalse);
  });

  test('Three leading letters should not be a car', () {
    expect(isCarPlate('ABC123'), isFalse);
  });

  test('Only two trailing digits should not be a car', () {
    expect(isCarPlate('AB12'), isFalse);
  });

  test('Five trailing digits should not be a car', () {
    expect(isCarPlate('AB12345'), isFalse);
  });

  test('A letter after the digits should not be a car', () {
    expect(isCarPlate('AB1234C'), isFalse);
  });

  test('A member plate should not be a car plate', () {
    expect(isCarPlate('12-ABC'), isFalse);
  });

  //กฎรถเก๋งกับกฎมอเตอร์ไซค์ตอบคำถามเดียวกัน จึงต้องพิสูจน์ว่าไม่มีวันชนกัน
  test('No plate can be both a car plate and a motorcycle plate', () {
    List<String> plates = [
      'AB1234',
      'AB123',
      'ab1234',
      '12-ABC',
      '12-ABCD',
      'ABC',
      'ABC123',
    ];

    for (String plate in plates) {
      expect(
        isCarPlate(plate) && isMotorcyclePlate(plate),
        isFalse,
        reason: 'ทะเบียน $plate เข้าทั้งสองกฎ ซึ่งไม่ควรเกิดขึ้น',
      );
    }
  });

  //ฟังก์ชันที่รวมกฎประเภทรถไว้ที่เดียว ต้องครบทั้งสามทางออก
  test('vehicleTypeFromPlate reads a motorcycle from the plate', () {
    expect(vehicleTypeFromPlate('12-ABC'), 'motorcycle');
  });

  test('vehicleTypeFromPlate reads a car from the plate', () {
    expect(vehicleTypeFromPlate('AB1234'), 'car');
  });

  test('vehicleTypeFromPlate returns null when the plate says nothing', () {
    expect(vehicleTypeFromPlate('ABC123'), isNull);
  });
}
