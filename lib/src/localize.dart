import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path/path.dart' as p;

import 'packages/packages.dart';

/// List of regular expressions to match different text widget patterns
final List<RegExp> textPatterns = [
  // Standard Text widget - capturing up to 1000 chars to handle more complex strings with variables
  RegExp(
    r'''(?:const\s+)?Text\s*\(\s*["']([^"']*(?:(?:\$\{[^{}]*(?:\([^()]*\))*[^{}]*\}|\$\w+)[^"']*)*)["']\s*[\),]''',
  ),

  // Text as child of widgets like TextButton, ElevatedButton, etc.
  RegExp(
    r'''(?:child|title|label|text)\s*:\s*(?:const\s+)?Text\s*\(\s*["']([^"']*(?:(?:\$\{[^{}]*(?:\([^()]*\))*[^{}]*\}|\$\w+)[^"']*)*)["']\s*[\),]''',
  ),

  // TextSpan widget
  RegExp(
    r'''TextSpan\s*\(\s*text\s*:\s*["']([^"']*(?:(?:\$\{[^{}]*(?:\([^()]*\))*[^{}]*\}|\$\w+)[^"']*)*)["']''',
  ),

  // RichText and Text.rich
  RegExp(
    r'''RichText\s*\(\s*text\s*:\s*TextSpan\s*\(\s*text\s*:\s*["']([^"']*(?:(?:\$\{[^{}]*(?:\([^()]*\))*[^{}]*\}|\$\w+)[^"']*)*)["']''',
  ),
  RegExp(
    r'''Text\.rich\s*\(\s*TextSpan\s*\(\s*text\s*:\s*["']([^"']*(?:(?:\$\{[^{}]*(?:\([^()]*\))*[^{}]*\}|\$\w+)[^"']*)*)["']''',
  ),

  // Buttons with Text child (TextButton, ElevatedButton, OutlinedButton)
  RegExp(
    r'''(?:TextButton|ElevatedButton|OutlinedButton)\s*\(\s*child\s*:\s*(?:const\s+)?Text\s*\(\s*["']([^"']*(?:(?:\$\{[^{}]*(?:\([^()]*\))*[^{}]*\}|\$\w+)[^"']*)*)["']''',
  ),

  // TextSpan with style, capturing "style" and "text" parameters
  RegExp(
    r'''TextSpan\s*\(\s*style\s*:\s*TextStyle\([^\)]*\)\s*,\s*text\s*:\s*["']([^"']*(?:(?:\$\{[^{}]*(?:\([^()]*\))*[^{}]*\}|\$\w+)[^"']*)*)["']''',
  ),

  // BottomNavigationBarItem label parameter
  RegExp(
    r'''BottomNavigationBarItem\s*\((?:[^,]*,)*\s*label\s*:\s*["']([^"']*(?:(?:\$\{[^{}]*(?:\([^()]*\))*[^{}]*\}|\$\w+)[^"']*)*)["']''',
  ),
];

/// RegExp to detect const keyword
final RegExp constPattern = RegExp(r'const\s+Text');

/// RegExp for finding variables in strings
final RegExp simpleVarPattern = RegExp(r'\$(\w+)');

/// Enhanced complex pattern to handle nested brackets, parentheses, quotes, and special characters
final RegExp complexVarPattern = RegExp(
  r'\$\{([^{}]*(?:\([^()]*\)[^{}]*)*(?:\{[^{}]*\}[^{}]*)*)\}',
);

/// RegExp for finding placeholders in existing translations
final RegExp placeholderPattern = RegExp(r'@(\w+)');

/// Default localization package
LocalizationPackage? _defaultPackage;

/// Random string generator for parameter IDs
final _random = Random();

/// Global mapping of expressions to generated IDs
final Map<String, String> expressionToIdMap = {};

/// Set to store IDs from existing translations to avoid conflicts
final Set<String> existingPlaceholderIds = {};

/// Debug mode flag
bool debugMode = true;

/// Generate a random string of specified length that always starts with a letter
String _generateRandomString(int length) {
  const letters = 'abcdefghijklmnopqrstuvwxyz';
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';

  // First character must be a letter
  final firstChar = letters[_random.nextInt(letters.length)];

  // Rest of the characters can be alphanumeric
  final restOfString =
      length > 1
          ? String.fromCharCodes(
            Iterable.generate(
              length - 1,
              (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
            ),
          )
          : '';

  return firstChar + restOfString;
}

/// Get a consistent ID for an expression, avoiding conflicts with existing IDs
String getIdForExpression(String expression) {
  if (!expressionToIdMap.containsKey(expression)) {
    String id;
    do {
      id = _generateRandomString(8);
    } while (existingPlaceholderIds.contains(id));

    expressionToIdMap[expression] = id;
  }
  return expressionToIdMap[expression]!;
}

/// Debug logging function
void debugLog(String message) {
  if (debugMode) {
    print('DEBUG: $message');
  }
}

/// Set debug mode
void setDebugMode(bool value) {
  debugMode = value;
}

/// Main function to run the localization process
Future<void> localize({
  String? projectPath,
  String lang = 'en',
  String packageName = 'getx',
}) async {
  print('🚀 Flutter Localization Script');

  // Get the localization package
  final package = PackageFactory.getPackage(packageName);
  _defaultPackage = package;

  print('📦 Using ${package.name} localization package');

  final path = projectPath ?? Directory.current.path;
  final outputDir = Directory(p.join(path, 'assets/lang'));
  final output = File(p.join(outputDir.path, 'lang_$lang.json'));

  final Map<String, String> jsonMap = {};

  // Check if the JSON file already exists and load it
  if (await output.exists()) {
    print('📂 Found existing language file, loading translations...');
    try {
      String existingContent = await output.readAsString();
      Map<String, dynamic> existingMap = json.decode(existingContent);

      // Load existing translations into the map
      existingMap.forEach((key, value) {
        if (value is String) {
          jsonMap[key] = value;

          // Extract placeholder IDs from existing translations
          extractPlaceholderIds(value);
        }
      });

      print(
        '✅ Loaded ${jsonMap.length} existing translations with ${existingPlaceholderIds.length} parameter placeholders',
      );
    } catch (e) {
      print('⚠️ Error loading existing translations: $e');
      print('🔄 Will proceed with creating a new file');
    }
  } else {
    print('ℹ️ No existing language file found, will create a new one');
  }

  print('🔍 Scanning for hardcoded text...');
  await processDirectory(Directory(p.join(path, 'lib')), jsonMap, package);

  print('🗂️ Creating directory: ${outputDir.path}');
  await outputDir.create(recursive: true);

  print('📝 Generating ${output.path}...');
  await output.writeAsString(JsonEncoder.withIndent('  ').convert(jsonMap));

  int newKeys =
      jsonMap.length -
      (existingPlaceholderIds.isEmpty ? 0 : existingPlaceholderIds.length);
  print(
    '✅ Done! ${jsonMap.length} total keys ($newKeys new, ${existingPlaceholderIds.length} preserved)',
  );
  print('📊 Expression mappings (showing up to 10):');
  int count = 0;
  expressionToIdMap.forEach((expr, id) {
    if (count < 10) {
      print('  @$id: $expr');
      count++;
    }
  });
  if (expressionToIdMap.length > 10) {
    print('  ... and ${expressionToIdMap.length - 10} more');
  }
}

/// Command-line entry point
Future<void> main(List<String> arguments) async {
  final projectPath =
      arguments.isNotEmpty ? arguments[0] : Directory.current.path;
  final lang = arguments.length > 1 ? arguments[1] : 'en';
  final packageName = arguments.length > 2 ? arguments[2] : 'getx';

  await localize(
    projectPath: projectPath,
    lang: lang,
    packageName: packageName,
  );
}

/// Extract placeholder IDs from existing translations
void extractPlaceholderIds(String jsonValue) {
  final matches = placeholderPattern.allMatches(jsonValue);

  for (final match in matches) {
    final id = match.group(1)!;
    existingPlaceholderIds.add(id);
    debugLog('Found existing placeholder ID: @$id');
  }
}

/// Class to store information about variables in strings
class VariableInfo {
  final String
  original; // Original variable expression ($name or ${complex.expression})
  final String paramId; // Random ID to use in trParams
  final String jsonPlaceholder; // Placeholder to use in JSON
  final String expression; // The actual expression without $ or ${}

  VariableInfo({
    required this.original,
    required this.paramId,
    required this.jsonPlaceholder,
    required this.expression,
  });
}

/// Check if the package is imported in the file
bool isPackageImported(String content, LocalizationPackage package) {
  return package.isImported(content);
}

/// Add the package import to file content
String addPackageImport(String content, LocalizationPackage package) {
  return package.addImport(content);
}

/// Process a directory to find and replace hardcoded strings
Future<void> processDirectory(
  Directory dir,
  Map<String, String> jsonMap,
  LocalizationPackage package,
) async {
  final files = await dir.list(recursive: true).toList();
  for (final file in files) {
    if (file is File && file.path.endsWith('.dart')) {
      String content = await file.readAsString();
      var updated = content;
      var localizationApplied = false;

      for (final pattern in textPatterns) {
        final matches = pattern.allMatches(content).toList();

        for (final match in matches) {
          final original = match.group(1)!;

          // Skip if already localized
          if (package.isLocalized(original)) continue;

          debugLog('Found string: $original');

          final key = generateKey(original);

          // Process variables in the string
          final variables = processVariables(original);

          if (variables.isNotEmpty) {
            debugLog('Variables found in: $original');
            for (var variable in variables) {
              debugLog(
                '  Original: ${variable.original}, ID: ${variable.paramId}, Expression: ${variable.expression}',
              );
            }
          }

          // Only add to JSON map if the key doesn't exist yet
          if (!jsonMap.containsKey(key)) {
            String jsonValue = formatJsonValue(original, variables, package);
            jsonMap[key] = jsonValue;
            debugLog('JSON: "$key" -> "$jsonValue"');

            // For Flutter Intl, we need to add metadata for each key
            if (package.name == 'Flutter Intl') {
              // Convert VariableInfo list to a Map<String, String> for the package
              final placeholdersMap = <String, String>{};
              for (final variable in variables) {
                placeholdersMap[variable.paramId] = variable.expression;
              }

              final metadata = package.generateArbMetadata(
                key,
                original,
                placeholdersMap,
              );
              if (metadata.isNotEmpty) {
                jsonMap['@$key'] = metadata;
                debugLog('Added metadata for key: $key');
              }
            }
          } else {
            debugLog('Reusing existing translation for key: $key');
          }

          final fullMatch = match.group(0)!;

          // Skip if already localized
          if (package.isLocalized(fullMatch)) continue;

          String replacement;
          if (variables.isEmpty) {
            // Simple case - no variables
            replacement = package.replaceSimpleString(fullMatch, original, key);
          } else {
            // Complex case - with variables
            final paramsMap = buildParamsMap(variables);
            replacement = package.replaceStringWithVariables(
              fullMatch,
              original,
              key,
              paramsMap,
            );
          }

          // Remove const from Text widgets
          if (constPattern.hasMatch(fullMatch)) {
            replacement = replacement.replaceFirst(constPattern, 'Text');
          }

          debugLog('Replacing: \n  "$fullMatch" \n  with: \n  "$replacement"');
          updated = updated.replaceAll(fullMatch, replacement);
          localizationApplied = true;
        }
      }

      // Add package import if needed and localization was applied
      if (localizationApplied && !isPackageImported(updated, package)) {
        debugLog('Adding ${package.name} import to ${file.path}');
        updated = addPackageImport(updated, package);
      }

      if (updated != content) {
        await file.writeAsString(updated);
        print('✏️ Updated: ${file.path}');
      }
    }
  }
}

/// Process all variables in a string and return structured info
List<VariableInfo> processVariables(String text) {
  final List<VariableInfo> variables = [];

  // Process complex variables first (${expression}) to avoid issues with nested patterns
  final complexMatches = complexVarPattern.allMatches(text);
  for (final match in complexMatches) {
    final expression = match.group(1)!;
    final fullMatch = match.group(0)!;

    // Generate a random ID for this expression
    final randomId = getIdForExpression(expression);

    variables.add(
      VariableInfo(
        original: fullMatch,
        paramId: randomId,
        jsonPlaceholder: '@$randomId',
        expression: expression,
      ),
    );
  }

  // Process simple variables ($name) only if they're not part of a complex expression
  final simpleMatches = simpleVarPattern.allMatches(text);
  for (final match in simpleMatches) {
    final varName = match.group(1)!;
    final fullMatch = match.group(0)!;

    // Skip if this is part of a complex expression already processed
    bool isPartOfComplex = false;
    for (var variable in variables) {
      if (variable.original.contains(fullMatch)) {
        isPartOfComplex = true;
        break;
      }
    }

    if (!isPartOfComplex) {
      // Generate a random ID for this variable
      final randomId = getIdForExpression(varName);

      variables.add(
        VariableInfo(
          original: fullMatch,
          paramId: randomId,
          jsonPlaceholder: '@$randomId',
          expression: varName,
        ),
      );
    }
  }

  return variables;
}

/// Format JSON value with appropriate placeholders
String formatJsonValue(
  String original,
  List<VariableInfo> variables, [
  LocalizationPackage? package,
]) {
  // If a package is provided and it has a custom implementation, use it
  if (package != null) {
    // Convert VariableInfo list to a Map<String, String> for the package
    final placeholdersMap = <String, String>{};
    for (final variable in variables) {
      placeholdersMap[variable.paramId] = variable.expression;
    }

    final customFormat = package.formatJsonValue(original, placeholdersMap);
    if (customFormat != original) {
      return customFormat;
    }
  }

  // Default implementation (used by GetX)
  String result = original;

  // Sort variables by length of original expression (descending)
  // to avoid partial replacements of nested variables
  final sortedVars = List<VariableInfo>.from(variables)
    ..sort((a, b) => b.original.length.compareTo(a.original.length));

  for (final variable in sortedVars) {
    result = result.replaceAll(variable.original, variable.jsonPlaceholder);
  }

  return result;
}

/// Build the parameters map for trParams
String buildParamsMap(List<VariableInfo> variables) {
  final params = variables
      .map((variable) {
        return "'${variable.paramId}': (${variable.expression}).toString()";
      })
      .join(',\n    ');

  return "{\n    $params\n  }";
}

/// Generate a key from text by removing variables and special characters
/// Ensures the key never starts with a number
String generateKey(String text) {
  // Remove variables for key generation
  String cleanText = text;

  // Remove simple variables
  cleanText = cleanText.replaceAll(simpleVarPattern, '');

  // Remove complex variables
  cleanText = cleanText.replaceAll(complexVarPattern, '');

  // Generate the key by removing special characters and replacing spaces with underscores
  String key = cleanText
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
      .trim()
      .replaceAll(' ', '_');

  // If the key is empty or starts with a number, prefix it with 'key_'
  if (key.isEmpty || RegExp(r'^[0-9]').hasMatch(key)) {
    key = 'key_$key';
  }

  return key;
}
