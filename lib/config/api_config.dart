/// Base URL for the Node.js/Express backend (see /backend in this repo).
///
/// IMPORTANT — "localhost" means different things depending on where the
/// app is actually running, NOT where your backend is running:
///
/// - Flutter Web (Chrome) on the SAME PC as the backend → `localhost` works.
/// - Android EMULATOR → use `10.0.2.2` instead of `localhost`. The emulator
///   runs in its own virtual machine, and `10.0.2.2` is a special alias
///   Android's emulator provides that forwards to your host PC's localhost.
/// - A REAL PHONE (via USB or same WiFi) → use your PC's actual LAN IP
///   address, e.g. `192.168.1.42`. Find it by running `ipconfig` in
///   PowerShell and looking for "IPv4 Address" under your active adapter
///   (WiFi or Ethernet). Your phone and PC must be on the same network.
/// - iOS Simulator → `localhost` works (simulator shares the host network).
///
/// Change ONE line below to match how you're testing, then hot-restart
/// (not just hot-reload) the app.
class ApiConfig {
  // static const String baseUrl = 'http://localhost:4000';   // Web / iOS Simulator / USB ADB
  static const String baseUrl = 'http://10.0.2.2:4000';   // Android Emulator (Default)
  // static const String baseUrl = 'http://10.228.206.96:4000'; // Real physical phone on Wi-Fi

  static Uri uri(String path) => Uri.parse('$baseUrl$path');
}
