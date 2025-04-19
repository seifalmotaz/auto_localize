import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;

final List<RegExp> textPatterns = [
  // Standard Text widget
  RegExp(r'''(?:const\s+)?Text\s*\(\s*["\']([^"\']{1,200})["\']\s*[\),]'''),

  // Text as child of widgets like TextButton, ElevatedButton, etc.
  RegExp(
      r'''(?:child|title|label|text)\s*:\s*(?:const\s+)?Text\s*\(\s*["\']([^"\']{1,200})["\']\s*[\),]'''),

  // TextSpan widget
  RegExp(r'''TextSpan\s*\(\s*text\s*:\s*["\']([^"\']{1,200})["\']'''),

  // RichText and Text.rich
  RegExp(
      r'''RichText\s*\(\s*text\s*:\s*TextSpan\s*\(\s*text\s*:\s*["\']([^"\']{1,200})["\']'''),
  RegExp(
      r'''Text\.rich\s*\(\s*TextSpan\s*\(\s*text\s*:\s*["\']([^"\']{1,200})["\']'''),

  // Buttons with Text child (TextButton, ElevatedButton, OutlinedButton)
  RegExp(
      r'''(?:TextButton|ElevatedButton|OutlinedButton)\s*\(\s*child\s*:\s*Text\s*\(\s*["\']([^"\']{1,200})["\']'''),

  // TextSpan with style, capturing "style" and "text" parameters
  RegExp(
      r'''TextSpan\s*\(\s*style\s*:\s*TextStyle\([^\)]*\)\s*,\s*text\s*:\s*["\']([^"\']{1,200})["\']'''),
];

void main(List<String> arguments) async {
  final projectPath =
      arguments.isNotEmpty ? arguments[0] : Directory.current.path;
  final lang = arguments.length > 1 ? arguments[1] : 'en';
  final outputDir = Directory(p.join(projectPath, 'assets/lang'));
  final output = File(p.join(outputDir.path, 'lang_$lang.json'));

  final Map<String, String> jsonMap = {};

  print('🔍 Scanning for hardcoded text...');
  await processDirectory(Directory(p.join(projectPath, 'lib')), jsonMap);

  print('🗂️ Creating directory: ${outputDir.path}');
  await outputDir.create(recursive: true);

  print('📝 Generating ${output.path}...');
  await output.writeAsString(JsonEncoder.withIndent('  ').convert(jsonMap));

  print('✅ Done! ${jsonMap.length} keys generated.');
}

Future<void> processDirectory(
    Directory dir, Map<String, String> jsonMap) async {
  final files = await dir.list(recursive: true).toList();
  for (final file in files) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = await file.readAsString();
      var updated = content;
      Map<int, String> history = {};

      for (final pattern in textPatterns) {
        final matches = pattern.allMatches(updated).toList();

        for (final match in matches) {
          String original = match.group(1)!;
          final key = generateKey(original);
          if (!jsonMap.containsKey(key)) {
            jsonMap[key] = original;
          }

          final fullMatch = match.group(0)!;
          // Replace only if the key isn't already used
          if (!fullMatch.contains('.tr')) {
            updated.replaceFirst('"$original".tr', '"$original"');
            final replaced = fullMatch.replaceFirst('"$original"', '"$key".tr');
            updated = updated.replaceFirst(fullMatch, replaced);
          }
        }
      }

      if (updated != content) {
        await file.writeAsString(updated);
        print('✏️ Updated: ${file.path}');
      }
    }
  }
}

String generateKey(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
      .trim()
      .replaceAll(' ', '_');
}
