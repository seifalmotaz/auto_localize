import 'package:flutter_test/flutter_test.dart';
import 'package:auto_localize/auto_localize.dart';

void main() {
  test('generateKey creates valid keys', () {
    expect(generateKey('Hello World'), equals('hello_world'));
    expect(generateKey('Hello \$name'), equals('hello'));
    expect(generateKey('Hello \${user.name}!'), equals('hello'));
    expect(generateKey('Special @#\$% chars'), equals('special__chars'));
  });
}
