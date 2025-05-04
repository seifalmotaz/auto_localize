# Flutter Localization Automation Tool

A command-line utility that automatically scans your Flutter project to find hardcoded UI strings and replaces them with localization keys using GetX's `.tr` and `.trParams` methods.

## What This Tool Does

This script automates the tedious process of manually implementing localization in Flutter projects by:

1. **Scanning Dart Files**: Recursively searches through your project's lib directory for hardcoded strings in UI widgets.

2. **Identifying Text Patterns**: Detects various text widget patterns including:
   - Standard `Text` widgets
   - Text inside buttons and other widgets
   - `TextSpan` components
   - `RichText` widgets
   - Text with complex string interpolation (e.g., `'Expires: ${DateFormat('MMM dd, yyyy').format(item.priceExpiry!)}'`)

3. **String Replacement**:
   - Converts simple strings like `Text('Hello')` to `Text('hello'.tr)`
   - Handles complex strings with variables using `trParams` method
   - Preserves expressions inside string interpolations

4. **JSON Generation**:
   - Creates a JSON translation file with original strings as values
   - Maintains placeholders for interpolated variables

5. **GetX Integration**:
   - Adds the necessary GetX import if not present
   - Removes the `const` keyword where needed for compatibility

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  auto_localize: ^0.0.1
  get: ^4.6.5  # Required for the .tr and .trParams methods
```

Or install it from the command line:

```bash
flutter pub add auto_localize
```

## Usage

### As a Command-Line Tool

You can run the tool directly from the command line:

```bash
# Navigate to your Flutter project
cd path/to/your/flutter/project

# Run the localization tool
dart run auto_localize [language_code]
```

Or install it globally:

```bash
dart pub global activate auto_localize
```

Then run it from anywhere:

```bash
auto_localize [project_path] [language_code]
```

### Programmatic Usage

You can also use the package programmatically in your Dart code:

```dart
import 'package:auto_localize/auto_localize.dart';

Future<void> main() async {
  // Run with default settings (current directory, 'en' language)
  await localize();

  // Or with custom settings
  await localize(
    projectPath: '/path/to/your/project',
    lang: 'fr',
  );
}
```

## Setting Up GetX Translations

After running the tool, you'll need to set up GetX to use the generated translations:

1. Add the following code to your `main.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load translations
  await loadTranslations();

  runApp(MyApp());
}

Future<void> loadTranslations() async {
  // Define supported languages
  final languages = ['en', 'fr', 'es']; // Add your supported languages

  for (final lang in languages) {
    try {
      final jsonString = await rootBundle.loadString('assets/lang/lang_$lang.json');
      final Map<String, dynamic> translations = json.decode(jsonString);
      Get.addTranslations({lang: translations});
    } catch (e) {
      print('Failed to load $lang translations: $e');
    }
  }

  // Set default language
  Get.locale = const Locale('en', 'US');
  Get.fallbackLocale = const Locale('en', 'US');
}
```

2. Wrap your app with `GetMaterialApp`:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My App',
      translations: GetxTranslations(), // Your translations class if needed
      locale: Get.locale,
      fallbackLocale: Get.fallbackLocale,
      home: HomePage(),
    );
  }
}
```

## Running Tests

To run the tests for this package:

```bash
flutter test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.