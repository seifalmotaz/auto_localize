import 'localization_package.dart';

/// Implementation of the LocalizationPackage interface for GetX
class GetXPackage implements LocalizationPackage {
  @override
  String get importStatement => "import 'package:get/get.dart';";

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
        .replaceFirst('"$original"', "'$key'.tr")
        .replaceFirst("'$original'", "'$key'.tr");
  }

  @override
  String replaceStringWithVariables(
    String fullMatch,
    String original,
    String key,
    String paramsMap,
  ) {
    return fullMatch
        .replaceFirst('"$original"', "'$key'.trParams($paramsMap)")
        .replaceFirst("'$original'", "'$key'.trParams($paramsMap)");
  }

  @override
  String formatJsonValue(String original, Map<String, String> placeholders) {
    // For GetX, we just replace placeholders with @paramId format
    String result = original;

    for (final entry in placeholders.entries) {
      final paramId = entry.key;
      final expression = entry.value;

      // Replace the expression with the placeholder
      result = result.replaceAll('\$$expression', '@$paramId');
      result = result.replaceAll('\${$expression}', '@$paramId');
    }

    return result;
  }

  @override
  String generateArbMetadata(
    String key,
    String original,
    Map<String, String> placeholders,
  ) {
    // GetX doesn't use ARB metadata, so we return an empty string
    return '';
  }

  @override
  bool isLocalized(String text) {
    return text.contains('.tr');
  }

  @override
  String get name => 'GetX';
}
