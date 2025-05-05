/// Abstract class defining the interface for localization packages
abstract class LocalizationPackage {
  /// The import statement to add to files
  String get importStatement;

  /// Check if the package is already imported in the file
  bool isImported(String content);

  /// Add the import statement to the file content
  String addImport(String content);

  /// Replace a simple string with a localized string
  /// 
  /// [original] is the original string
  /// [key] is the localization key
  String replaceSimpleString(String fullMatch, String original, String key);

  /// Replace a string with variables with a localized string
  /// 
  /// [original] is the original string
  /// [key] is the localization key
  /// [paramsMap] is the map of parameters for variable replacement
  String replaceStringWithVariables(String fullMatch, String original, String key, String paramsMap);

  /// Check if a string is already localized
  bool isLocalized(String text);

  /// Get the package name for display purposes
  String get name;
}
