# Flutter Localization Automation Tool

A command-line utility that automatically scans your Flutter project to find hardcoded UI strings and replaces them with localization keys. Supports multiple localization packages including GetX and Flutter's built-in localization.

> **Orignally Forked from [localize_generator_keys](https://github.com/abdoelmorap/localize_generator_keys) by [Abdelrahman Abdelsalam](https://github.com/abdoelmorap)**
> This is my own opinionated version of the tool, I added some features.

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

5. **Multiple Package Support**:
   - Supports GetX (default), Flutter's built-in localization, and more
   - Adds the necessary imports automatically
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

# Run the localization tool with default settings (GetX, 'en' language)
dart run auto_localize

# Run with a specific language
dart run auto_localize [language_code]

# Run with a specific language and package
dart run auto_localize [project_path] [language_code] [package_name]
```

Supported package names:
- `getx` (default)
- `flutter_intl` (Flutter's built-in localization)

Or install it globally:

```bash
dart pub global activate auto_localize
```

Then run it from anywhere:

```bash
auto_localize [project_path] [language_code] [package_name]
```

### Programmatic Usage

You can also use the package programmatically in your Dart code:

```dart
import 'package:auto_localize/auto_localize.dart';

Future<void> main() async {
  // Run with default settings (current directory, 'en' language, GetX package)
  await localize();

  // Or with custom settings
  await localize(
    projectPath: '/path/to/your/project',
    lang: 'fr',
    packageName: 'getx', // 'getx' or 'flutter_intl'
  );
}
```

## Setting Up Translations

After running the tool, you'll need to set up your chosen localization package to use the generated translations:

### GetX Setup

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

### Flutter Intl Setup

1. Configure your `l10n.yaml` file in the root of your project:

```yaml
arb-dir: assets/lang
template-arb-file: lang_en.json
output-localization-file: app_localizations.dart
```

2. Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

flutter:
  generate: true
```

3. Use the generated localizations in your app:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MyHomePage(),
    );
  }
}
```

#### Advanced Flutter Intl Features

The Flutter Intl implementation supports advanced features like placeholders, plurals, and selects:

1. **Placeholders**: Variables in strings are automatically converted to named parameters:

```dart
// Original: "Hello, $name!"
// Generated ARB:
// "greeting": "Hello, {name}!",
// "@greeting": {
//   "description": "A greeting message",
//   "placeholders": {
//     "name": {
//       "type": "String",
//       "example": "John"
//     }
//   }
// }

// Usage:
Text(AppLocalizations.of(context)!.greeting(name: userName))
```

2. **Plurals**: Number variables are automatically detected and can be used with plural forms:

```dart
// Original: "You have $count messages"
// Generated ARB:
// "messageCount": "{count, plural, =0{No messages} =1{One message} other{{count} messages}}",
// "@messageCount": {
//   "description": "Message count",
//   "placeholders": {
//     "count": {
//       "type": "num",
//       "format": "compact"
//     }
//   }
// }

// Usage:
Text(AppLocalizations.of(context)!.messageCount(count: messages.length))
```

3. **Selects**: String variables with specific names (gender, type, etc.) can be used with select statements:

```dart
// Original: "The $gender student"
// Generated ARB:
// "studentGender": "{gender, select, male{He} female{She} other{They}}",
// "@studentGender": {
//   "description": "Student gender pronoun",
//   "placeholders": {
//     "gender": {
//       "type": "String"
//     }
//   }
// }

// Usage:
Text(AppLocalizations.of(context)!.studentGender(gender: userGender))
```

## Running Tests

To run the tests for this package:

```bash
flutter test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.