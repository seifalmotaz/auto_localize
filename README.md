# localize_generator_keys

A Dart CLI tool that automatically scans your Flutter project for hardcoded UI strings and replaces them with `.tr` keys for localization using GetX. EasyLocalization etc It also generates a corresponding JSON file containing the translations.

## 🚀 Features
- Detects and replaces hardcoded strings in widgets like `Text`, `TextSpan`, `RichText`, `Text.rich`, and buttons.
- Generates a translation key based on the original string.
- Outputs a structured JSON file under `assets/lang/`.
- Supports customization for language code.

## 📦 Installation


Add the package to `dev_dependencies` in `pubspec.yaml`:

```yaml
dev_dependencies:
  localize_generator_keys: latest
```

or 
```bash
dart pub global activate localize_generator_keys
```

## 🔧 Usage

From the root of your Flutter project:

```bash
dart run localize_generator_keys 
```

also can use it like 

```bash
dart run localize_generator_keys . en
```

- The first argument is the root path to scan (e.g., `.`).
- The second argument is the language code (`en`, `ar`, etc).

The tool will:
- Scan all `.dart` files under `lib/`
- Replace hardcoded strings with `.tr` keys
- Output `assets/lang/lang_en.json`

## 🧠 How it works
This tool uses regular expressions to match widgets like:

```dart
Text("Hello World")
TextSpan(text: "Welcome")
TextButton(child: Text("Click Me"))
```

And transforms them into:

```dart
Text("hello_world".tr)
TextSpan(text: "welcome".tr)
TextButton(child: Text("click_me".tr))
```

With a generated `lang_en.json` like:

```json
{
  "hello_world": "Hello World",
  "welcome": "Welcome",
  "click_me": "Click Me"
}
```

## 📁 Output
```
assets/
└── lang/
    └── lang_en.json
```
# Great Mix 

## 🌍 Support for Multiple Languages (Offline)

To translate your translation files (`lang_en.json`) to other languages without the need for an internet connection, you can use the [argos_translator_offline](https://pub.dev/packages/argos_translator_offline) package that I developed.

### ✅ Features:

- Offline translation using the Argos Translate library.
- Supports more than 50 languages.
- No external API or internet connection required.

### 🧪 Example Usage:

```bash
dart run argos_translator_offline path=assets/lang/lang_en.json from=en to=ar
```

This will translate the file from English to Arabic while maintaining the same structure.

For more details, check out the [argos_translator_offline](https://pub.dev/packages/argos_translator_offline) package page on pub.dev.

## ⚠️ Limitations
- Only works with strings in quotes (single/double).
- Does not detect variables inside text.
- Regex-based matching may skip edge cases.

## 📄 License
MIT

---

Built with ❤️ by [abdelrhmantolba.online] 

