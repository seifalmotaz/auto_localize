import 'localization_package.dart';

/// Implementation of the LocalizationPackage interface for Flutter's built-in localization (intl)
class FlutterIntlPackage implements LocalizationPackage {
  @override
  String get importStatement => "import 'package:flutter_gen/gen_l10n/app_localizations.dart';";

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
  String replaceStringWithVariables(String fullMatch, String original, String key, String paramsMap) {
    // Extract parameters from the paramsMap
    final paramRegex = RegExp(r"'(\w+)': \(([^)]+)\)\.toString\(\)");
    final matches = paramRegex.allMatches(paramsMap);
    
    // Build the parameter list for the intl method
    final params = matches.map((match) => "${match.group(2)}").join(", ");
    
    return fullMatch
        .replaceFirst('"$original"', "AppLocalizations.of(context)!.$key($params)")
        .replaceFirst("'$original'", "AppLocalizations.of(context)!.$key($params)");
  }

  @override
  bool isLocalized(String text) {
    return text.contains('AppLocalizations.of(context)');
  }

  @override
  String get name => 'Flutter Intl';
}
