## 0.0.2+1

* Enhanced Flutter Intl support with advanced features:
  * Added support for placeholders with proper ARB metadata generation
  * Added support for plurals with automatic number type detection
  * Added support for selects (gender, etc.) with automatic type detection
* Improved documentation with examples of advanced Flutter Intl features
* Fixed minor bugs in package implementations

## 0.0.2

* Added support for multiple localization packages
* Implemented a modular architecture with package adapters
* Added support for Flutter's built-in localization (intl)
* Improved command-line interface with package selection
* Updated documentation with examples for each supported package

## 0.0.1+3

* Fixed bin file references in pubspec.yaml
* Improved command-line interface
* Added better error handling for file operations

## 0.0.1+2

* Added support for global installation via `dart pub global activate`
* Fixed issues with path handling on different operating systems
* Improved documentation

## 0.0.1+1

* Bug fixes and performance improvements
* Enhanced pattern matching for text widgets

## 0.0.1

Initial release of auto_localize:

* Automatically scan Flutter projects for hardcoded UI strings
* Replace hardcoded strings with localization keys
* Support for various text widget patterns (Text, TextSpan, RichText, etc.)
* Handle complex strings with variables
* Generate JSON translation files with original strings as values
* Add necessary imports automatically
* GetX support
