import 'package:flutter_test/flutter_test.dart';
import 'package:auto_localize/auto_localize.dart';

void main() {
  test('generateKey creates valid keys', () {
    expect(generateKey('Hello World'), equals('hello_world'));
    expect(generateKey('Hello \$name'), equals('hello'));
    expect(generateKey('Hello \${user.name}!'), equals('hello'));
    expect(generateKey('Special @#\$% chars'), equals('special__chars'));
  });

  test('generateKey handles keys that would start with numbers', () {
    expect(generateKey('123 Test'), equals('key_123_test'));
    expect(generateKey('1st Place'), equals('key_1st_place'));
    expect(generateKey('42 is the answer'), equals('key_42_is_the_answer'));
    expect(generateKey('9'), equals('key_9'));
  });

  test('generateKey handles empty or invalid input by returning null', () {
    expect(generateKey(''), isNull);
    expect(generateKey('   '), isNull);
    expect(generateKey('#@!%'), isNull);
  });
}
