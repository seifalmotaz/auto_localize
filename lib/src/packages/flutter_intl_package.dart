import 'localization_package.dart';

/// Implementation of the LocalizationPackage interface for Flutter's built-in localization (intl)
class FlutterIntlPackage implements LocalizationPackage {
  @override
  String get importStatement =>
      "import 'package:flutter_gen/gen_l10n/app_localizations.dart';";

  @override
  bool isImported(String content) {
    return content.contains(importStatement);
  }

  @override
  String addImport(String content) {
    // Insert as first import
    final importIndex = content.indexOf('import');
    return '${content.substring(0, importIndex)}$importStatement\n${content.substring(importIndex)}';
  }

  @override
  String replaceSimpleString(String fullMatch, String original, String key) {
    return fullMatch
        .replaceFirst('"$original"', "AppLocalizations.of(context)!.$key")
        .replaceFirst("'$original'", "AppLocalizations.of(context)!.$key");
  }

  @override
  String replaceStringWithVariables(
    String fullMatch,
    String original,
    String key,
    String paramsMap,
  ) {
    // Extract parameters from the paramsMap
    final paramRegex = RegExp(r"'(\w+)': \(([^)]+)\)\.toString\(\)");
    final matches = paramRegex.allMatches(paramsMap);

    // Build named parameters for the intl method
    final params = matches
        .map((match) {
          // final paramName = match.group(1);
          final paramValue = match.group(2);
          return "$paramValue";
        })
        .join(", ");

    return fullMatch
        .replaceFirst(
          '"$original"',
          "AppLocalizations.of(context)!.$key($params)",
        )
        .replaceFirst(
          "'$original'",
          "AppLocalizations.of(context)!.$key($params)",
        );
  }

  /// Analyzes the original string to determine if it contains plural or select patterns
  /// and generates appropriate ARB file content
  @override
  String formatJsonValue(String original, Map<String, String> placeholders) {
    // For simple strings with placeholders, just return the original with placeholders
    return original;
  }

  /// Generates ARB file metadata for a key with placeholders, plurals, or selects
  @override
  String generateArbMetadata(
    String key,
    String original,
    Map<String, String> placeholders,
  ) {
    if (placeholders.isEmpty) {
      return '"@$key": {\n    "description": "Auto-generated for $key"\n  }';
    }

    final placeholdersJson = placeholders.entries
        .map((entry) {
          final paramId = entry.key;
          final paramType = _determineParameterType(entry.value);

          if (paramType == 'num') {
            // For number parameters, add format options for plurals
            return '"$paramId": {\n      "type": "$paramType",\n      "format": "compact"\n    }';
          } else {
            return '"$paramId": {\n      "type": "$paramType",\n      "example": "${entry.value}"\n    }';
          }
        })
        .join(',\n    ');

    return '"@$key": {\n    "description": "Auto-generated for $key",\n    "placeholders": {\n    $placeholdersJson\n    }\n  }';
  }

  /// Determines the parameter type based on the expression
  String _determineParameterType(String expression) {
    // This is a simplified version - in a real implementation, you would
    // analyze the expression to determine if it's a number, date, etc.
    if (expression.contains('.length') ||
        expression.contains('Count') ||
        expression.contains('count') ||
        expression.contains('number') ||
        expression.contains('Number')) {
      return 'num';
    } else if (expression.contains('Date') ||
        expression.contains('date') ||
        expression.contains('Time') ||
        expression.contains('time')) {
      return 'DateTime';
    } else if (expression.contains('gender') ||
        expression.contains('Gender') ||
        expression.contains('sex') ||
        expression.contains('Sex')) {
      return 'String'; // For gender/select
    } else {
      return 'String';
    }
  }

  @override
  bool isLocalized(String text) {
    return text.contains('AppLocalizations.of(context)');
  }

  @override
  String get name => 'Flutter Intl';
}
