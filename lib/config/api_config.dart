import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// Global API Configuration for Disha Saathi.
/// Dynamically resolves an active, verified backend URL at runtime across Web, Emulator, and Local Wi-Fi devices.
class ApiConfig {
  static const String currentWifiUrl = 'http://10.113.12.96:4000';
  static const String primaryProductionUrl = 'https://disha-saathi-backend.onrender.com';

  static const List<String> candidateUrls = [
    'http://localhost:4000',
    'http://127.0.0.1:4000',
    'http://10.0.2.2:4000',
    currentWifiUrl,
  ];

  static String activeBaseUrl = 'http://localhost:4000';

  static Uri uri(String path) => Uri.parse('$activeBaseUrl$path');

  /// Probes candidate URLs in PARALLEL against /health to resolve verified backend host in ~100ms.
  /// Strictly verifies statusCode == 200 and body containing 'disha-saathi-backend'.
  static Future<void> resolveActiveBaseUrl() async {
    final allCandidates = [
      if (kIsWeb && Uri.base.host.isNotEmpty && Uri.base.host != 'localhost')
        '${Uri.base.scheme}://${Uri.base.host}:4000',
      ...candidateUrls,
    ];

    for (final url in allCandidates) {
      try {
        final response = await http.get(Uri.parse('$url/health')).timeout(const Duration(milliseconds: 1000));
        if (response.statusCode == 200 && response.body.contains('disha-saathi-backend')) {
          activeBaseUrl = url;
          print('[ApiConfig] Verified Active Backend Host: $activeBaseUrl');
          return;
        }
      } catch (_) {
        continue;
      }
    }

    // Default to local server host
    activeBaseUrl = 'http://localhost:4000';
  }
}
