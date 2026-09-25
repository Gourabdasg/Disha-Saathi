import 'dart:async';
import 'package:http/http.dart' as http;

/// Global API Configuration for Disha Saathi.
/// Dynamically resolves an active, reachable backend URL at runtime across Web, Emulator, and Local Wi-Fi devices.
class ApiConfig {
  static const String currentWifiUrl = 'http://10.113.12.96:4000';
  static const String primaryProductionUrl = 'https://disha-saathi-backend.onrender.com';

  static const List<String> candidateUrls = [
    'http://localhost:4000',
    'http://10.0.2.2:4000',
    currentWifiUrl,
    'http://10.228.206.96:4000',
    primaryProductionUrl,
  ];

  static String activeBaseUrl = 'http://localhost:4000';

  static Uri uri(String path) => Uri.parse('$activeBaseUrl$path');

  /// Probes candidate URLs rapidly against /health to resolve active backend host.
  static Future<void> resolveActiveBaseUrl() async {
    for (final url in candidateUrls) {
      try {
        final response = await http.get(Uri.parse('$url/health')).timeout(const Duration(milliseconds: 1500));
        if (response.statusCode == 200) {
          activeBaseUrl = url;
          print('[ApiConfig] Resolved Active Backend Host: $activeBaseUrl');
          return;
        }
      } catch (_) {
        continue;
      }
    }
  }
}
