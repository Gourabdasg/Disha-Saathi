import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
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
/// Uses global production HTTPS backend URL accessible over Mobile Data (4G/5G) & Wi-Fi.
class ApiService {
  static const _timeout = Duration(seconds: 15);
  static const _headers = {'Content-Type': 'application/json'};

  /// Background warmup ping to wake up cloud backend container and resolve active base URL on app launch
  static Future<void> warmupBackend() async {
    try {
      await ApiConfig.resolveActiveBaseUrl();
    } catch (_) {}
  }

  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(ApiConfig.uri(path), headers: _headers, body: jsonEncode(body))
          .timeout(_timeout);
      return _decodeMap(res);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        504,
        'Unable to connect to server. Please check your internet connection and try again.',
      );
    }
  }

  static Future<Map<String, dynamic>> _get(String path) async {
    try {
      final res = await http.get(ApiConfig.uri(path)).timeout(_timeout);
      return _decodeMap(res);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        504,
        'Unable to reach server. Please check your internet connection and try again.',
      );
    }
  }

  static Future<List<dynamic>> _getList(String path) async {
    try {
      final res = await http.get(ApiConfig.uri(path)).timeout(_timeout);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return res.body.isEmpty ? [] : jsonDecode(res.body) as List<dynamic>;
      }
      throw ApiException(res.statusCode, _errorMessageFrom(res));
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        504,
        'Unable to reach server. Please check your internet connection and try again.',
      );
    }
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

  static Future<Map<String, dynamic>> sendOtp(String mobile) async {
    return await _post('/api/auth/otp/send', {'mobile': mobile});
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

  // --- SC Caste Certificate Upload ---

  static Future<Map<String, dynamic>?> uploadCertificateFile(PlatformFile file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        ApiConfig.uri('/api/media/upload-certificate'),
      );
      if (file.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'certificate',
            file.bytes!,
            filename: file.name,
          ),
        );
      } else if (file.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath('certificate', file.path!),
        );
      }
      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // Fallback for offline mode
    }
    return null;
  }

  // --- NVIDIA Speech-to-Text & Text-to-Speech Media Endpoints ---

  static Future<String?> textToSpeech(String text, String languageCode) async {
    try {
      final json = await _post('/api/media/tts', {
        'text': text,
        'languageCode': languageCode,
      });
      return json['audioBase64'] as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> speechToText(String audioBase64, String languageCode) async {
    try {
      final json = await _post('/api/media/stt', {
        'audioBase64': audioBase64,
        'languageCode': languageCode,
      });
      return json['text'] as String?;
    } catch (_) {
      return null;
    }
  }

  // --- AI Chat (backend/routes/chat.js) ---

  static Future<String> sendChatMessage(String mobile, String text, String languageCode, {String? sessionId}) async {
    try {
      final json = await _post('/api/chat/message', {
        'mobile': mobile,
        'text': text,
        'language': languageCode,
        if (sessionId != null) 'sessionId': sessionId,
      });
      return json['reply'] as String? ?? '';
    } catch (_) {
      // Rapid parallel re-probe active backend host
      await ApiConfig.resolveActiveBaseUrl();
      final json = await _post('/api/chat/message', {
        'mobile': mobile,
        'text': text,
        'language': languageCode,
        if (sessionId != null) 'sessionId': sessionId,
      });
      return json['reply'] as String? ?? '';
    }
  }

  static Future<List<ChatMessage>> fetchChatHistory(String mobile, {String? sessionId}) async {
    final path = sessionId != null ? '/api/chat/history/$mobile?sessionId=$sessionId' : '/api/chat/history/$mobile';
    final list = await _getList(path);
    return list
        .map((m) => ChatMessage(m['text'] as String, m['sender'] == 'bot'))
        .toList();
  }

  static Future<List<ChatSessionItem>> fetchChatSessions(String mobile) async {
    try {
      final list = await _getList('/api/chat/sessions/$mobile');
      return list.map((item) => ChatSessionItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> deleteChatSession(String mobile, String sessionId) async {
    try {
      await http.delete(ApiConfig.uri('/api/chat/session/$mobile/$sessionId')).timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  static Future<void> clearChatHistory(String mobile, {String? sessionId}) async {
    try {
      await _post('/api/chat/clear', {
        'mobile': mobile,
        if (sessionId != null) 'sessionId': sessionId,
      });
    } catch (_) {}
  }

  static Future<void> restartChat(String mobile) async {
    try {
      await _post('/api/chat/restart', {'mobile': mobile});
    } catch (_) {}
  }
}
