import 'dart:async';
import 'package:http/http.dart' as http;

/// Global API Configuration for Disha Saathi.
/// Dynamically resolves an active, reachable backend URL at runtime.
class ApiConfig {
  static const String primaryProductionUrl = 'https://disha-saathi-backend.onrender.com';
  static const String localWifiUrl = 'http://10.228.206.96:4000';

  static const List<String> candidateUrls = [
    primaryProductionUrl,
    localWifiUrl,
    'http://10.0.2.2:4000',
    'http://localhost:4000',
  ];

  static String activeBaseUrl = primaryProductionUrl;

  static Uri uri(String path) => Uri.parse('$activeBaseUrl$path');

  /// Probes each candidate URL in order against /health with a 2.5-second timeout.
  /// Reassigns [activeBaseUrl] to the first responding host, or falls back to [primaryProductionUrl].
  static Future<void> resolveActiveBaseUrl() async {
    for (final url in candidateUrls) {
      try {
        final pingUri = Uri.parse('$url/health');
        final response = await http.get(pingUri).timeout(const Duration(milliseconds: 2500));
        if (response.statusCode == 200) {
          activeBaseUrl = url;
          return;
        }
      } catch (_) {
        continue;
      }
    }
    activeBaseUrl = primaryProductionUrl;
  }
}
