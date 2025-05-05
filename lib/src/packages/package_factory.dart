import 'localization_package.dart';
import 'getx_package.dart';
import 'flutter_intl_package.dart';

/// Factory class to create the appropriate localization package
class PackageFactory {
  /// Get a localization package by name
  static LocalizationPackage getPackage(String packageName) {
    switch (packageName.toLowerCase()) {
      case 'getx':
        return GetXPackage();
      case 'flutter_intl':
        return FlutterIntlPackage();
      default:
        throw ArgumentError('Unsupported package: $packageName. Supported packages: getx, flutter_intl');
    }
  }

  /// Get a list of supported package names
  static List<String> getSupportedPackages() {
    return ['getx', 'flutter_intl'];
  }
}
