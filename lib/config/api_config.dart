import 'package:flutter/foundation.dart';

/// Global Production API Configuration for Disha Saathi.
/// Uses a public HTTPS production backend endpoint accessible from any network globally.
class ApiConfig {
  // Public production cloud URL reachable over Mobile Data (4G/5G) & Wi-Fi from anywhere
  static const String primaryProductionUrl = 'https://disha-saathi-backend.onrender.com';

  static String get baseUrl {
    if (kDebugMode && kIsWeb) {
      return 'http://localhost:4000';
    }
    return primaryProductionUrl;
  }

  static Uri uri(String path) => Uri.parse('$baseUrl$path');
}
