import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../models/app_models.dart';
import '../services/api_service.dart';
import '../services/firebase_auth_service.dart';

String getInitialGreetingForLanguage(String langCode) {
  switch (langCode.toLowerCase().trim()) {
    case 'as':
      return 'নমস্কাৰ! 👋 দিশা সাথীলৈ স্বাগতম। আপোনাৰ নামটো জানিব পাৰোঁনে?';
    case 'bn':
      return 'নমস্কার! 👋 দিশা সাথীতে আপনাকে স্বাগতম। আপনার নাম জানতে পারি?';
    case 'brx':
      return 'खुलुमबाय! 👋 दिशा साथियांव नोंथांखौ सिनायनो हायोगोना?';
    case 'doi':
      return 'नमस्ते! 👋 दिशा साथी च तुंदा स्वागत ऐ। तुंदा नां केह ऐ?';
    case 'gu':
      return 'નમસ્તે! 👋 દિશા સાથીમાં આપનું સ્વાગત છે. શું હું તમારું નામ જાણી શકું?';
    case 'hi':
      return 'नमस्ते! 👋 दिशा साथी में आपका स्वागत है। क्या मैं आपका नाम जान सकता हूँ?';
    case 'kn':
      return 'ನಮಸ್ಕಾರ! 👋 ದಿಶಾ ಸಾಥಿಗೆ ಸುಸ್ವಾಗತ. ನಿಮ್ಮ ಹೆಸರು ತಿಳಿಯಬಹುದೇ?';
    case 'ks':
      return 'سلام! 👋 دِشا ساتھی منٛز تُہند سواتَگتھ۔ تُہند ناڤ کیاہ چھُ؟';
    case 'kok':
      return 'नमस्कार! 👋 दिशा साथींत तुमचें स्वागत. तुमचें नांव कळूं येता?';
    case 'mai':
      return 'नमस्कार! 👋 दिशा साथी मे अहाँक स्वागत अछि। अहाँक नाम की थिक?';
    case 'ml':
      return 'നമസ്കാരം! 👋 ദിശാ സാഥിയിലേക്ക് സ്വാഗതം. നിങ്ങളുടെ പേര് അറിയാമോ?';
    case 'mni':
      return 'খুরুমজরী! 👋 দিশা সাথীদা তরাম্না ওকচরী। নহাকগী মমিং পাম্বীয়ু?';
    case 'mr':
      return 'नमस्कार! 👋 दिशा साथी मध्ये तुमचे स्वागत आहे. तुमचे नाव काय आहे?';
    case 'ne':
      return 'नमस्ते! 👋 दिशा साथीमा तपाईंलाई स्वागत छ। तपाईंको नाम थाहा पाउन सकिन्छ?';
    case 'or':
      return 'ନମସ୍କାର! 👋 ଦିଶା ସାଥୀକୁ ଆପଣଙ୍କୁ ସ୍ୱାଗତ। ଆପଣଙ୍କ ନାମ ଜାଣିପାରେ କି?';
    case 'pa':
      return 'ਸਤਿ ਸ਼੍ਰੀ ਅਕਾਲ! 👋 ਦਿਸ਼ਾ ਸਾਥੀ ਵਿੱਚ ਤੁਹਾਡਾ ਸਵਾਗਤ ਹੈ। ਕੀ ਮੈਂ ਤੁਹਾਡਾ ਨਾਮ ਜਾਣ ਸਕਦਾ ਹਾਂ?';
    case 'sa':
      return 'नमो नमः! 👋 दिशा साथी इत्यत्र भवतः स्वागतम्। भवतः नाम किम्?';
    case 'sat':
      return 'ᱡᱚᱦᱟᱨ! 👋 ᱫᱤᱥᱟᱹ ᱥᱟᱛᱷᱤ ᱨᱮ ᱟᱢᱟᱜ ᱥᱟᱹᱜᱩᱱ ᱫᱟᱨᱟᱢ᱾ ᱟᱢᱟᱜ ᱧᱩᱛᱩᱢ ᱪᱮᱫ?';
    case 'sd':
      return 'سلام! 👋 دشا ساٿي ۾ ڀلي ڪري آيا. توهان جو نالو ڇا آهي؟';
    case 'ta':
      return 'வணக்கம்! 👋 திஷா சாதிக்கு வரவேற்கிறோம். உங்கள் பெயர் என்ன?';
    case 'te':
      return 'నమస్కారం! 👋 దిశా సాథీకి స్వాగతం. మీ పేరు తెలుసుకోవచ్చా?';
    case 'ur':
      return 'السلام علیکم! 👋 دِشا ساتھی میں آپ کا خیرمقدم ہے۔ کیا میں آپ کا نام جان سکتا ہوں؟';
    case 'en':
    default:
      return 'Hello! 👋 Welcome to Disha Saathi. May I know your name?';
  }
}

class AppState extends ChangeNotifier {
  AppLanguage selectedLanguage = AppLanguage.all[4]; // Default: English (en)

  bool isAuthenticated = false;
  bool isLoading = false;
  String? errorMessage;

  String mobile = '';
  String email = '';
  String name = 'Rahul Kumar';
  String category = 'Scheduled Caste (SC)';
  String latestDemoOtp = '';

  UserProfile profile = UserProfile();

  int registrationStep = 0;

  // Step 1: Personal
  String fatherName = '';
  String motherName = '';
  String aadhaar = '';
  String annualIncome = '';
  String scCategoryNo = '';
  String scCertificateUrl = '';
  String scCertificateFilename = '';
  String district = 'Murshidabad';
  String stateName = 'West Bengal';
  String location = 'Barasat, West Bengal';

  // Step 2: Education
  String highestQualification = '';
  String stream = '';
  String yearsOfStudy = '';
  String workExperience = '';

  // Step 3: Livelihood
  String selectedLivelihood = '';

  // Step 4: Skills
  final Set<String> selectedSkills = {};
  final Set<String> selectedInterests = {};

  bool _chatHistoryLoaded = false;

  List<JourneyStep> get journeySteps {
    final completion = profile.calculateCompletionPercent();
    return [
      const JourneyStep('Registration', 'Completed', JourneyStepState.completed, 'person'),
      JourneyStep(
        'Livelihood Assessment',
        completion >= 100 ? 'Completed' : '$completion% Complete',
        completion >= 100 ? JourneyStepState.completed : JourneyStepState.active,
        'chat',
      ),
      JourneyStep(
        'Skill Recommendation',
        completion >= 100 ? 'Matched NSQF Courses' : 'In progress',
        completion >= 100 ? JourneyStepState.completed : JourneyStepState.active,
        'school',
      ),
      const JourneyStep('PM-AJAY Certification', 'In progress', JourneyStepState.active, 'medal'),
    ];
  }

  // --- Session & Language Persistence Methods (shared_preferences) ---

  void setLanguage(AppLanguage lang) {
    selectedLanguage = lang;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('selected_language_code', lang.code);
    });

    if (chatMessages.length <= 1) {
      chatMessages
        ..clear()
        ..add(
          ChatMessage(
            getInitialGreetingForLanguage(lang.code),
            true,
          ),
        );
    }

    notifyListeners();
  }

  String tr(String key) {
    return AppStrings.get(selectedLanguage.code, key);
  }

  Future<void> saveSessionToPrefs({String? token, String? mobile, String? email, String? name}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);
      await prefs.setString('selected_language_code', selectedLanguage.code);
      if (token != null) await prefs.setString('auth_token', token);
      if (mobile != null && mobile.isNotEmpty) await prefs.setString('user_mobile', mobile);
      if (email != null && email.isNotEmpty) await prefs.setString('user_email', email.trim().toLowerCase());
      if (name != null && name.isNotEmpty) await prefs.setString('user_name', name);
    } catch (_) {}
  }

  Future<void> clearSessionPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_authenticated');
      await prefs.remove('auth_token');
      await prefs.remove('user_mobile');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
    } catch (_) {}
  }

  Future<bool> restoreSessionFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedLangCode = prefs.getString('selected_language_code');
      if (savedLangCode != null && savedLangCode.isNotEmpty) {
        final foundLang = AppLanguage.all.firstWhere(
          (l) => l.code == savedLangCode,
          orElse: () => AppLanguage.all[4],
        );
        selectedLanguage = foundLang;
      }

      final isAuth = prefs.getBool('is_authenticated') ?? false;
      if (!isAuth) return false;

      final savedMobile = prefs.getString('user_mobile') ?? '';
      final savedEmail = prefs.getString('user_email') ?? '';
      final savedName = prefs.getString('user_name') ?? 'Rahul Kumar';

      final lookupKey = savedMobile.isNotEmpty ? savedMobile : savedEmail;
      if (lookupKey.isEmpty) return false;

      UserProfile? existing;
      try {
        existing = await ApiService.fetchProfile(lookupKey);
      } catch (_) {}

      if (existing != null) {
        profile = existing;
        mobile = existing.mobile;
        email = existing.email.trim().toLowerCase();
        name = existing.name.isNotEmpty ? existing.name : savedName;
      } else {
        mobile = savedMobile;
        email = savedEmail;
        name = savedName;
        profile = UserProfile(mobile: mobile, email: email, name: name);
      }

      isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkAndRestoreSession() => restoreSessionFromPrefs();

  /// Completely clears the user's session, Firebase auth, profile, form fields, and chat history.
  Future<void> logout() async {
    await clearSessionPrefs();

    isAuthenticated = false;
    isLoading = false;
    errorMessage = null;

    mobile = '';
    email = '';
    name = 'Rahul Kumar';
    latestDemoOtp = '';

    profile = UserProfile();

    registrationStep = 0;
    fatherName = '';
    motherName = '';
    aadhaar = '';
    annualIncome = '';
    scCategoryNo = '';
    scCertificateUrl = '';
    scCertificateFilename = '';
    district = 'Murshidabad';
    stateName = 'West Bengal';
    location = 'Barasat, West Bengal';

    highestQualification = '';
    stream = '';
    yearsOfStudy = '';
    workExperience = '';
    selectedLivelihood = '';
    selectedSkills.clear();
    selectedInterests.clear();

    _chatHistoryLoaded = false;
    chatMessages
      ..clear()
      ..add(
        ChatMessage(
          getInitialGreetingForLanguage(selectedLanguage.code),
          true,
        ),
      );

    notifyListeners();
  }

  // --- Registration Step Methods ---

  void setRegistrationStep(int step) {
    registrationStep = step;
    notifyListeners();
  }

  void nextRegistrationStep() {
    if (registrationStep < 3) {
      registrationStep++;
      notifyListeners();
    }
  }

  void prevRegistrationStep() {
    if (registrationStep > 0) {
      registrationStep--;
      notifyListeners();
    }
  }

  void toggleSkill(String skill) {
    if (selectedSkills.contains(skill)) {
      selectedSkills.remove(skill);
    } else {
      selectedSkills.add(skill);
    }
    notifyListeners();
  }

  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    errorMessage = null;
    notifyListeners();
  }

  String _cleanError(dynamic e) {
    final str = e.toString();
    if (str.contains('TimeoutException') || str.contains('Future not completed') || str.contains('SocketException')) {
      return 'Unable to connect to server. Please check your internet connection and try again.';
    }
    return str.replaceFirst('Exception: ', '');
  }

  void _prepareNewSession({String? newMobile, String? newEmail, String? newName}) {
    mobile = newMobile ?? mobile;
    email = newEmail != null ? newEmail.trim().toLowerCase() : email;
    name = newName ?? name;

    profile = UserProfile(
      mobile: mobile,
      email: email,
      name: name,
    );

    _chatHistoryLoaded = false;
    chatMessages
      ..clear()
      ..add(
        ChatMessage(
          getInitialGreetingForLanguage(selectedLanguage.code),
          true,
        ),
      );
  }

  // --- Mobile OTP Auth ---

  String firebaseVerificationId = '';

  Future<String?> sendOtp(String mobileNumber) async {
    _prepareNewSession(newMobile: mobileNumber);
    _setLoading(true);

    final completer = Completer<String?>();

    try {
      final res = await ApiService.sendOtp(mobileNumber);
      latestDemoOtp = res['demoOtp'] as String? ?? '';

      await FirebaseAuthService.sendPhoneOtp(
        phoneNumber: mobileNumber,
        onCodeSent: (verificationId, resendToken) {
          firebaseVerificationId = verificationId;
          isLoading = false;
          notifyListeners();
          if (!completer.isCompleted) completer.complete(latestDemoOtp);
        },
        onError: (err) {
          if (latestDemoOtp.isNotEmpty) {
            isLoading = false;
            notifyListeners();
            if (!completer.isCompleted) completer.complete(latestDemoOtp);
          } else {
            isLoading = false;
            errorMessage = err;
            notifyListeners();
            if (!completer.isCompleted) completer.complete(null);
          }
        },
        onAutoVerified: (credential) async {
          // Auto SMS verification
        },
      );
    } catch (e) {
      isLoading = false;
      errorMessage = _cleanError(e);
      notifyListeners();
      return null;
    }

    return completer.future;
  }

  Future<String?> verifyOtp(String otp) async {
    _setLoading(true);
    try {
      if (firebaseVerificationId.isNotEmpty && otp != '123456') {
        try {
          await FirebaseAuthService.verifyPhoneOtp(
            verificationId: firebaseVerificationId,
            smsCode: otp,
          );
        } catch (_) {}
      }

      final token = await ApiService.verifyOtp(mobile, otp);
      UserProfile? existing;
      try {
        existing = await ApiService.fetchProfile(mobile);
      } catch (_) {}

      isLoading = false;

      if (existing != null) {
        profile = existing;
        if (existing.name.isNotEmpty) name = existing.name;
        if (existing.mobile.isNotEmpty) mobile = existing.mobile;
        if (existing.email.isNotEmpty) email = existing.email.trim().toLowerCase();
        isAuthenticated = true;
        await saveSessionToPrefs(token: token, mobile: mobile, email: email, name: name);
        notifyListeners();
        return 'existing';
      }

      isAuthenticated = true;
      await saveSessionToPrefs(token: token, mobile: mobile, email: email, name: name);
      notifyListeners();
      return 'new';
    } catch (e) {
      isLoading = false;
      isAuthenticated = false;
      errorMessage = _cleanError(e);
      notifyListeners();
      return null;
    }
  }

  // --- Email OTP Auth ---

  Future<String?> sendEmailOtp(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    _prepareNewSession(newEmail: normalizedEmail);
    _setLoading(true);
    try {
      final res = await ApiService.sendEmailOtp(normalizedEmail);
      isLoading = false;
      latestDemoOtp = res['demoOtp'] as String? ?? '';
      notifyListeners();
      return latestDemoOtp;
    } catch (e) {
      isLoading = false;
      errorMessage = _cleanError(e);
      notifyListeners();
      return null;
    }
  }

  Future<String?> verifyEmailOtp(String otp) async {
    _setLoading(true);
    try {
      final normalizedEmail = email.trim().toLowerCase();
      email = normalizedEmail;
      final token = await ApiService.verifyEmailOtp(normalizedEmail, otp);
      final lookupKey = mobile.isNotEmpty ? mobile : normalizedEmail;

      UserProfile? existing;
      try {
        existing = await ApiService.fetchProfile(lookupKey);
      } catch (_) {}

      isLoading = false;

      if (existing != null) {
        profile = existing;
        if (existing.name.isNotEmpty) name = existing.name;
        if (existing.mobile.isNotEmpty) mobile = existing.mobile;
        if (existing.email.isNotEmpty) email = existing.email.trim().toLowerCase();
        isAuthenticated = true;
        await saveSessionToPrefs(token: token, mobile: mobile, email: email, name: name);
        notifyListeners();
        return 'existing';
      }

      isAuthenticated = true;
      await saveSessionToPrefs(token: token, mobile: mobile, email: email, name: name);
      notifyListeners();
      return 'new';
    } catch (e) {
      isLoading = false;
      isAuthenticated = false;
      errorMessage = _cleanError(e);
      notifyListeners();
      return null;
    }
  }

  Future<String?> loginWithPassword(String mobile, String password) async {
    _prepareNewSession(newMobile: mobile);
    _setLoading(true);
    try {
      final token = await ApiService.loginWithPassword(mobile, password);
      final existing = await ApiService.fetchProfile(mobile);
      isLoading = false;
      if (existing != null) {
        profile = existing;
        name = existing.name;
        mobile = existing.mobile;
        email = existing.email.trim().toLowerCase();
        isAuthenticated = true;
        await saveSessionToPrefs(token: token, mobile: mobile, email: email, name: name);
        notifyListeners();
        return 'existing';
      }

      isAuthenticated = true;
      await saveSessionToPrefs(token: token, mobile: mobile, email: email, name: name);
      notifyListeners();
      return 'new';
    } catch (e) {
      isLoading = false;
      isAuthenticated = false;
      errorMessage = _cleanError(e);
      notifyListeners();
      return null;
    }
  }

  Future<String?> loginWithGoogle(String email, String name, String? googleId) async {
    final normalizedEmail = email.trim().toLowerCase();
    _prepareNewSession(newEmail: normalizedEmail, newName: name);
    _setLoading(true);

    try {
      final safeEmail = normalizedEmail.isNotEmpty ? normalizedEmail : 'google.user@example.com';
      final safeName = name.isNotEmpty ? name : 'Google User';
      final safeUid = googleId ?? 'google_${DateTime.now().millisecondsSinceEpoch}';

      Map<String, dynamic> res = {};
      try {
        res = await ApiService.loginWithGoogle(email: safeEmail, name: safeName, googleId: safeUid);
      } catch (_) {}

      final token = res['token'] as String? ?? 'demo-google-jwt';

      UserProfile? existing;
      try {
        final lookupKey = safeEmail.isNotEmpty ? safeEmail : (mobile.isNotEmpty ? mobile : 'anonymous');
        existing = await ApiService.fetchProfile(lookupKey);
      } catch (_) {}

      isLoading = false;

      if (existing != null) {
        profile = existing;
        this.name = existing.name.isNotEmpty ? existing.name : safeName;
        mobile = existing.mobile;
        this.email = existing.email.isNotEmpty ? existing.email.trim().toLowerCase() : safeEmail;
        isAuthenticated = true;
        await saveSessionToPrefs(token: token, mobile: mobile, email: this.email, name: this.name);
        notifyListeners();
        return 'existing';
      }

      this.email = safeEmail;
      this.name = safeName;
      this.profile = UserProfile(email: this.email, name: this.name);
      isAuthenticated = true;
      await saveSessionToPrefs(token: token, mobile: mobile, email: this.email, name: this.name);
      notifyListeners();
      return 'new';
    } catch (e) {
      final fallbackEmail = normalizedEmail.isNotEmpty ? normalizedEmail : 'google.user@example.com';
      final fallbackName = name.isNotEmpty ? name : 'Google User';
      this.email = fallbackEmail;
      this.name = fallbackName;
      this.profile = UserProfile(email: this.email, name: this.name);
      this.isAuthenticated = true;
      isLoading = false;
      await saveSessionToPrefs(token: 'demo-google-jwt', mobile: mobile, email: this.email, name: this.name);
      notifyListeners();
      return 'new';
    }
  }

  Future<String?> signUpWithEmail(String email, String password, String name, String mobile) async {
    final normalizedEmail = email.trim().toLowerCase();
    _prepareNewSession(newEmail: normalizedEmail, newMobile: mobile, newName: name);
    _setLoading(true);
    try {
      final res = await ApiService.signUpWithEmail(email: normalizedEmail, password: password, name: name, mobile: mobile);
      final token = res['token'] as String? ?? 'demo-jwt';
      isLoading = false;
      await saveSessionToPrefs(token: token, mobile: mobile, email: normalizedEmail, name: name);
      notifyListeners();
      return 'new';
    } catch (e) {
      isLoading = false;
      errorMessage = _cleanError(e);
      notifyListeners();
      return null;
    }
  }

  // --- AI Chat Features ---

  String activeSessionId = 'session_default';

  final List<ChatMessage> chatMessages = [
    const ChatMessage(
      "Hello! 👋 Welcome to Disha Saathi. May I know your name?",
      true,
    ),
  ];

  /// Starts a fresh, new Chat Session without deleting previous profile or sessions.
  void startNewChatSession() {
    activeSessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    _chatHistoryLoaded = true;
    chatMessages
      ..clear()
      ..add(
        ChatMessage(
          getInitialGreetingForLanguage(selectedLanguage.code),
          true,
        ),
      );
    notifyListeners();
  }

  /// Switches to and loads a specific conversation session from Chat History.
  Future<void> loadChatSession(String sessionId) async {
    activeSessionId = sessionId;
    final lookupKey = mobile.isNotEmpty ? mobile : email.trim().toLowerCase();
    if (lookupKey.isEmpty) return;
    try {
      final history = await ApiService.fetchChatHistory(lookupKey, sessionId: sessionId);
      chatMessages
        ..clear()
        ..addAll(history);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadChatHistory() async {
    final lookupKey = mobile.isNotEmpty ? mobile : email.trim().toLowerCase();
    if (_chatHistoryLoaded || lookupKey.isEmpty) return;
    _chatHistoryLoaded = true;
    try {
      final history = await ApiService.fetchChatHistory(lookupKey, sessionId: activeSessionId);
      if (history.isNotEmpty) {
        chatMessages
          ..clear()
          ..addAll(history);
      } else {
        chatMessages
          ..clear()
          ..add(
            ChatMessage(
              getInitialGreetingForLanguage(selectedLanguage.code),
              true,
            ),
          );
      }
      notifyListeners();
    } catch (_) {
      // Backend down or no history yet
    }
  }

  Future<void> sendChatMessage(String text) async {
    if (text.trim().isEmpty) return;
    chatMessages.add(ChatMessage(text, false));
    notifyListeners();
    final lookupKey = mobile.isNotEmpty ? mobile : email.trim().toLowerCase();
    try {
      final reply = await ApiService.sendChatMessage(
        lookupKey,
        text,
        selectedLanguage.code,
        sessionId: activeSessionId,
      );
      if (reply.isNotEmpty) {
        chatMessages.add(ChatMessage(reply, true));
      } else {
        final fallback = getFallbackAssessmentReply(text, profile, selectedLanguage.code);
        chatMessages.add(ChatMessage(fallback, true));
      }

      // Refresh profile state dynamically from backend
      if (lookupKey.isNotEmpty) {
        try {
          final updatedProfile = await ApiService.fetchProfile(lookupKey);
          if (updatedProfile != null) {
            profile = updatedProfile;
          }
        } catch (_) {}
      }
    } catch (e) {
      final fallbackReply = getFallbackAssessmentReply(text, profile, selectedLanguage.code);
      chatMessages.add(ChatMessage(fallbackReply, true));
    }
    notifyListeners();
  }

  String getFallbackAssessmentReply(String text, UserProfile profile, String langCode) {
    if (profile.name.isEmpty || profile.name == 'Rahul Kumar') {
      profile.name = text.trim();
      return getInitialGreetingForLanguage(langCode);
    } else if (profile.age == null) {
      final cleanAge = text.replaceAll(RegExp(r'\D'), '');
      final numAge = int.tryParse(cleanAge);
      if (numAge != null && numAge >= 12 && numAge <= 90) {
        profile.age = numAge;
        return getInitialGreetingForLanguage(langCode);
      }
      return 'Sorry, I didn\'t quite catch that — could you tell me your age as a number (e.g. 22)?';
    } else if (profile.state.isEmpty) {
      profile.state = text.trim();
      return getInitialGreetingForLanguage(langCode);
    } else if (profile.district.isEmpty) {
      profile.district = text.trim();
      return getInitialGreetingForLanguage(langCode);
    } else if (profile.location.isEmpty) {
      profile.location = text.trim();
      return getInitialGreetingForLanguage(langCode);
    } else if (profile.highestQualification.isEmpty) {
      profile.highestQualification = text.trim();
      return getInitialGreetingForLanguage(langCode);
    } else if (profile.livelihood.isEmpty) {
      profile.livelihood = text.trim();
      return getInitialGreetingForLanguage(langCode);
    } else if (profile.familyOccupation.isEmpty) {
      profile.familyOccupation = text.trim();
      return getInitialGreetingForLanguage(langCode);
    } else if (profile.existingSkills.isEmpty) {
      profile.existingSkills = [text.trim()];
      return getInitialGreetingForLanguage(langCode);
    } else if (profile.experienceName.isEmpty) {
      profile.experienceName = text.trim();
      return getInitialGreetingForLanguage(langCode);
    } else if (profile.careerInterests.isEmpty) {
      profile.careerInterests = [text.trim()];
      return getInitialGreetingForLanguage(langCode);
    } else if (profile.employmentPreference.isEmpty) {
      profile.employmentPreference = text.trim();
      return getInitialGreetingForLanguage(langCode);
    } else if (profile.mobilityConstraints.isEmpty) {
      profile.mobilityConstraints = text.trim();
      return getInitialGreetingForLanguage(langCode);
    } else {
      profile.careerGoal = text.trim();
      profile.onboardingComplete = true;
      return 'Thank you, ${profile.name}! 🎉 I have completed your profile assessment.\n\n🎯 Recommended Career Role:\n**Software Engineer** (Sector: IT-ITeS)\n\n📚 Recommended Official NSQF Training Courses:\n1. **Certificate Course in Coding Skills** (NSQF Level 5 · 270 Hours)\n   • Awarding Body: Additional Skill Acquisition Programme\n   • Career Pathway: Software Engineer / Project Engineer\n\n💡 Reason for Recommendation:\nYour education, skills, interests, and career goals match the requirements of this training.';
    }
  }

  /// Permanently clears current conversation history on server & local state.
  Future<void> clearChat() async {
    final lookupKey = mobile.isNotEmpty ? mobile : email.trim().toLowerCase();
    if (lookupKey.isNotEmpty) {
      await ApiService.clearChatHistory(lookupKey, sessionId: activeSessionId);
    }
    _chatHistoryLoaded = true;
    chatMessages
      ..clear()
      ..add(
        ChatMessage(
          getInitialGreetingForLanguage(selectedLanguage.code),
          true,
        ),
      );
    notifyListeners();
  }

  /// Restarts current conversation flow and onboarding context.
  Future<void> restartChat() async {
    final lookupKey = mobile.isNotEmpty ? mobile : email.trim().toLowerCase();
    if (lookupKey.isNotEmpty) {
      await ApiService.restartChat(lookupKey);
    }
    _chatHistoryLoaded = true;
    chatMessages
      ..clear()
      ..add(
        ChatMessage(
          getInitialGreetingForLanguage(selectedLanguage.code),
          true,
        ),
      );
    notifyListeners();
  }

  // --- Profile Modifications & Saves ---

  Future<bool> updateUserProfile(UserProfile updatedProfile) async {
    _setLoading(true);
    try {
      updatedProfile.email = updatedProfile.email.trim().toLowerCase();
      profile = await ApiService.saveProfile(updatedProfile);
      mobile = profile.mobile;
      email = profile.email;
      name = profile.name;
      await saveSessionToPrefs(mobile: profile.mobile, email: profile.email, name: profile.name);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      profile = updatedProfile;
      isLoading = false;
      errorMessage = _cleanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveRegistrationProfile() async {
    _setLoading(true);
    try {
      profile.mobile = mobile.isNotEmpty ? mobile : email.trim().toLowerCase();
      profile.email = email.trim().toLowerCase();
      profile.name = name.isNotEmpty ? name : profile.name;
      profile.annualIncome = annualIncome;
      profile.category = 'Scheduled Caste (SC)';
      profile.scCategoryNo = scCategoryNo;
      profile.scCertificateUrl = scCertificateUrl;
      profile.scCertificateFilename = scCertificateFilename;
      profile.district = district.isNotEmpty ? district : profile.district;
      profile.state = stateName.isNotEmpty ? stateName : profile.state;
      profile.location = location.isNotEmpty ? location : profile.location;
      profile.highestQualification = highestQualification;
      profile.stream = stream;
      profile.yearsOfStudy = int.tryParse(yearsOfStudy) ?? profile.yearsOfStudy;
      profile.workExperienceYears = int.tryParse(workExperience) ?? profile.workExperienceYears;
      profile.livelihood = selectedLivelihood.isNotEmpty ? selectedLivelihood : profile.livelihood;

      if (selectedSkills.isNotEmpty) {
        profile.existingSkills
          ..clear()
          ..addAll(selectedSkills);
      }
      if (selectedInterests.isNotEmpty) {
        profile.careerInterests
          ..clear()
          ..addAll(selectedInterests);
      }

      profile = await ApiService.saveProfile(profile);
      mobile = profile.mobile;
      email = profile.email;
      name = profile.name;
      await saveSessionToPrefs(mobile: profile.mobile, email: profile.email, name: profile.name);

      isLoading = false;
      isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = _cleanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeRegistration() => saveRegistrationProfile();
}
