/// Global Production API Configuration for Disha Saathi.
/// Uses a public HTTPS production backend endpoint accessible from any network globally.
class ApiConfig {
  // Public production cloud URL reachable over Mobile Data (4G/5G) & Wi-Fi from anywhere
  static const String primaryProductionUrl = 'https://disha-saathi-backend.onrender.com';

  // Candidate URLs tried automatically depending on network interface
  static const List<String> candidateUrls = [
    primaryProductionUrl,
    'http://10.228.206.96:4000', // Wi-Fi LAN IP
    'http://10.0.2.2:4000',      // Android Emulator
    'http://localhost:4000',     // Localhost
  ];

  static String activeBaseUrl = primaryProductionUrl;

  static Uri uri(String path) => Uri.parse('$activeBaseUrl$path');
}
