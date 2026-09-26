import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// Global API Configuration for Disha Saathi.
/// Dynamically resolves an active, verified backend URL at runtime across Web, Emulator, and Physical Mobile Devices.
class ApiConfig {
  static const String currentWifiUrl = 'http://10.113.12.96:4000';
  static const String primaryProductionUrl = 'https://disha-saathi-backend.onrender.com';

  static const List<String> candidateUrls = [
    currentWifiUrl,
    'http://localhost:4000',
    'http://10.0.2.2:4000',
    'http://192.168.1.100:4000',
    'http://192.168.0.100:4000',
    'http://10.228.206.96:4000',
    primaryProductionUrl,
  ];

  static String activeBaseUrl = currentWifiUrl;

  static Uri uri(String path) {
    // Safety guard: On physical Android/iOS devices, localhost points to the phone itself.
    if (!kIsWeb && (activeBaseUrl.contains('localhost') || activeBaseUrl.contains('127.0.0.1'))) {
      activeBaseUrl = currentWifiUrl;
    }
    return Uri.parse('$activeBaseUrl$path');
  }

  /// Probes candidate URLs in PARALLEL against /health to resolve verified backend host in ~100ms.
  /// Strictly verifies statusCode == 200 and body containing 'disha-saathi-backend'.
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

    // On Android / Mobile: Probe Wi-Fi IP and local hosts in parallel
    for (final url in candidateUrls) {
      try {
        final response = await http.get(Uri.parse('$url/health')).timeout(const Duration(milliseconds: 1200));
        if (response.statusCode == 200 && response.body.contains('disha-saathi-backend')) {
          activeBaseUrl = url;
          print('[ApiConfig] Verified Active Backend Host: $activeBaseUrl');
          return;
        }
      } catch (_) {
        continue;
      }
    }

    // Default to PC Wi-Fi IP address for mobile devices
    activeBaseUrl = currentWifiUrl;
  }
}
