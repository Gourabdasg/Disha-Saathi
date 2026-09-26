import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  static String activeBaseUrl = primaryProductionUrl;

  static Uri uri(String path) => Uri.parse('$activeBaseUrl$path');

  /// Probes candidate URLs in PARALLEL against /health to resolve host in ~100ms.
  static Future<void> resolveActiveBaseUrl() async {
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host == 'localhost' || host == '127.0.0.1') {
        activeBaseUrl = 'http://localhost:4000';
        try {
          final res = await http.get(Uri.parse('$activeBaseUrl/health')).timeout(const Duration(milliseconds: 800));
          if (res.statusCode == 200) return;
        } catch (_) {}
      }
      activeBaseUrl = primaryProductionUrl;
      return;
    }

    final completer = Completer<String>();

    for (final url in candidateUrls) {
      http.get(Uri.parse('$url/health')).timeout(const Duration(milliseconds: 1800)).then((res) {
        if (res.statusCode == 200 && !completer.isCompleted) {
          completer.complete(url);
        }
      }).catchError((_) {});
    }

    try {
      final resolved = await completer.future.timeout(const Duration(milliseconds: 2000));
      activeBaseUrl = resolved;
      print('[ApiConfig] Resolved Active Backend Host: $activeBaseUrl');
    } catch (_) {
      activeBaseUrl = primaryProductionUrl;
    }
  }
}
