import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/app_models.dart';

/// Thrown when the backend responds with a non-2xx status, carrying the
/// server's error message (from `{ error: '...' }` JSON bodies) so the UI
/// can show something more useful than "something went wrong".
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

/// Thin wrapper around the Node.js/Express backend's REST endpoints.
/// See backend/routes/*.js for the corresponding server-side code.
class ApiService {
  static const _timeout = Duration(seconds: 10);
  static const _headers = {'Content-Type': 'application/json'};

  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final res = await http
        .post(ApiConfig.uri(path), headers: _headers, body: jsonEncode(body))
        .timeout(_timeout);
    return _decodeMap(res);
  }

  static Future<Map<String, dynamic>> _get(String path) async {
    final res = await http.get(ApiConfig.uri(path)).timeout(_timeout);
    return _decodeMap(res);
  }

  static Future<List<dynamic>> _getList(String path) async {
    final res = await http.get(ApiConfig.uri(path)).timeout(_timeout);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isEmpty ? [] : jsonDecode(res.body) as List<dynamic>;
    }
    throw ApiException(res.statusCode, _errorMessageFrom(res));
  }

  static Map<String, dynamic> _decodeMap(http.Response res) {
    final decoded = res.body.isEmpty ? {} : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded as Map<String, dynamic>;
    }
    throw ApiException(res.statusCode, _errorMessageFrom(res));
  }

  static String _errorMessageFrom(http.Response res) {
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map && decoded['error'] != null) return decoded['error'].toString();
    } catch (_) {
      // fall through to generic message below
    }
    return 'Request failed (HTTP ${res.statusCode})';
  }

  // --- Auth (backend/routes/auth.js) ---

  static Future<void> sendOtp(String mobile) async {
    await _post('/api/auth/otp/send', {'mobile': mobile});
  }

  static Future<String> verifyOtp(String mobile, String otp) async {
    final json = await _post('/api/auth/otp/verify', {'mobile': mobile, 'otp': otp});
    return json['token'] as String? ?? '';
  }

  static Future<String> loginWithPassword(String mobile, String password) async {
    final json = await _post('/api/auth/login', {'mobile': mobile, 'password': password});
    return json['token'] as String? ?? '';
  }

  // --- Email OTP Auth ---

  static Future<Map<String, dynamic>> sendEmailOtp(String email) async {
    return await _post('/api/auth/email/otp/send', {'email': email});
  }

  static Future<String> verifyEmailOtp(String email, String otp) async {
    final json = await _post('/api/auth/email/otp/verify', {'email': email, 'otp': otp});
    return json['token'] as String? ?? '';
  }

  // --- Google & Email Password Auth (backend/routes/auth.js) ---

  static Future<Map<String, dynamic>> loginWithGoogle({
    required String email,
    required String name,
    String? googleId,
  }) async {
    return await _post('/api/auth/google', {
      'email': email,
      'name': name,
      if (googleId != null) 'googleId': googleId,
    });
  }

  static Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    String? name,
    String? mobile,
  }) async {
    return await _post('/api/auth/email/signup', {
      'email': email,
      'password': password,
      if (name != null) 'name': name,
      if (mobile != null) 'mobile': mobile,
    });
  }

  static Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await _post('/api/auth/email/login', {
      'email': email,
      'password': password,
    });
  }

  // --- Beneficiary profile (backend/routes/beneficiary.js) ---

  /// Returns null if no profile exists yet for this mobile number (HTTP 404)
  /// — that's the signal the app uses to send a first-time user to
  /// registration instead of the home dashboard.
  static Future<UserProfile?> fetchProfile(String mobile) async {
    try {
      final json = await _get('/api/beneficiary/profile/$mobile');
      return UserProfile.fromJson(json);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  static Future<UserProfile> saveProfile(UserProfile profile) async {
    final json = await _post('/api/beneficiary/profile', profile.toJson());
    return UserProfile.fromJson(json['profile'] as Map<String, dynamic>);
  }

  // --- AI Chat (backend/routes/chat.js) ---

  /// Sends a chat message for [mobile], gets back the rule-based matched
  /// reply (see backend/data/skillsDataset.js), and returns just the reply
  /// text for display. Both the user's message and this reply are already
  /// persisted server-side by the time this returns.
  static Future<String> sendChatMessage(String mobile, String text) async {
    final json = await _post('/api/chat/message', {'mobile': mobile, 'text': text});
    return json['reply'] as String? ?? '';
  }

  /// Loads the full stored conversation for [mobile], oldest first.
  static Future<List<ChatMessage>> fetchChatHistory(String mobile) async {
    final list = await _getList('/api/chat/history/$mobile');
    return list
        .map((m) => ChatMessage(m['text'] as String, m['sender'] == 'bot'))
        .toList();
  }

  static Future<void> clearChatHistory(String mobile) async {
    try {
      await http.delete(ApiConfig.uri('/api/chat/history/$mobile')).timeout(_timeout);
    } catch (_) {}
  }

  static Future<void> restartChat(String mobile) async {
    try {
      await _post('/api/chat/restart', {'mobile': mobile});
    } catch (_) {}
  }
}
