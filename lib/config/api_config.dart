import 'package:flutter/foundation.dart';

/// Global API Configuration for Disha Saathi.
/// Automatically routes requests across active Wi-Fi, Mobile Data, and Cloud Backend.
class ApiConfig {
  static const String primaryProductionUrl = 'https://disha-saathi-backend.onrender.com';
  static const String localWifiUrl = 'http://10.228.206.96:4000';

  static const List<String> candidateUrls = [
    localWifiUrl,
    primaryProductionUrl,
    'http://10.0.2.2:4000',
    'http://localhost:4000',
  ];

  static String activeBaseUrl = localWifiUrl;

  static Uri uri(String path) => Uri.parse('$activeBaseUrl$path');
}
