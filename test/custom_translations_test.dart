import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:auto_localize/src/localize.dart';

void main() {
  group('Custom Translation Files Tests', () {
    late Directory tempDir;
    late Directory libDir;
    late File customTranslationFile;
    late Map<String, String> jsonMap;

    setUp(() async {
      // Create a temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('auto_localize_test_');
      libDir = Directory(p.join(tempDir.path, 'lib'));
      await libDir.create();

      // Create a custom translation file
      customTranslationFile = File(p.join(libDir.path, 'custom.tr.json'));
      await customTranslationFile.writeAsString(json.encode({
        'custom_key1': 'Custom value 1',
        'custom_key2': 'Custom value 2 with @param',
        'custom_key3': 'Another custom value'
      }));

      // Create a nested custom translation file
      final nestedDir = Directory(p.join(libDir.path, 'nested'));
      await nestedDir.create();
      final nestedFile = File(p.join(nestedDir.path, 'nested.tr.json'));
      await nestedFile.writeAsString(json.encode({
        'nested_key1': 'Nested value 1',
        'nested_key2': 'Nested value 2'
      }));

      // Initialize the jsonMap
      jsonMap = {};
    });

    tearDown(() async {
      // Clean up the temporary directory
      await tempDir.delete(recursive: true);
    });

    test('processCustomTranslationFiles should find and process all .tr.json files', () async {
      // Process the custom translation files
      await processCustomTranslationFiles(libDir, jsonMap);

      // Verify that all custom keys were added to the jsonMap
      expect(jsonMap.length, equals(5));
      expect(jsonMap['custom_key1'], equals('Custom value 1'));
      expect(jsonMap['custom_key2'], equals('Custom value 2 with @param'));
      expect(jsonMap['custom_key3'], equals('Another custom value'));
      expect(jsonMap['nested_key1'], equals('Nested value 1'));
      expect(jsonMap['nested_key2'], equals('Nested value 2'));

      // Verify that placeholder IDs were extracted
      expect(existingPlaceholderIds.contains('param'), isTrue);
    });

    test('processCustomTranslationFiles should handle invalid JSON files gracefully', () async {
      // Create an invalid JSON file
      final invalidFile = File(p.join(libDir.path, 'invalid.tr.json'));
      await invalidFile.writeAsString('This is not valid JSON');

      // Process the custom translation files
      await processCustomTranslationFiles(libDir, jsonMap);

      // Verify that valid files were still processed
      expect(jsonMap.length, equals(5));
      expect(jsonMap['custom_key1'], equals('Custom value 1'));
    });

    test('processCustomTranslationFiles should not process non-.tr.json files', () async {
      // Create a regular JSON file
      final regularJsonFile = File(p.join(libDir.path, 'regular.json'));
      await regularJsonFile.writeAsString(json.encode({
        'regular_key': 'Regular value'
      }));

      // Process the custom translation files
      await processCustomTranslationFiles(libDir, jsonMap);

      // Verify that only .tr.json files were processed
      expect(jsonMap.length, equals(5));
      expect(jsonMap.containsKey('regular_key'), isFalse);
    });
  });
}
