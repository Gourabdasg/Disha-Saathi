import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../models/app_models.dart';
import '../services/api_service.dart';
import '../services/firebase_auth_service.dart';

/// Central app state shared across screens using Provider.
/// Integrates Firebase Authentication for Google Sign-In and PostgreSQL for backend storage.
class AppState extends ChangeNotifier {
  AppLanguage selectedLanguage =
      AppLanguage.all.firstWhere((l) => l.code == 'en'); // English default
  UserProfile profile = UserProfile();
  final List<ChatMessage> chatMessages = [
    const ChatMessage(
      "Hello! I'm your AI Skill Assistant. Tell me about the work you currently do. आप वर्तमान में क्या काम करते हैं?",
      true,
    ),
  ];

  int registrationStep = 0; // 0..3 across the 4-step form
  bool isAuthenticated = false;

  // Set as soon as the person enters/confirms a mobile number or email
  String mobile = '';
  String email = '';
  String latestDemoOtp = '';

  // UI feedback for in-flight network calls.
  bool isLoading = false;
  String? errorMessage;

  // Registration form fields (Step 1: Personal Info)
  String name = '';
  String fatherName = '';
  String motherName = '';
  String aadhaar = '';
  String annualIncome = '';
  String category = 'Scheduled Caste (SC)';
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

  // --- Session & Language Persistence Methods (shared_preferences) ---

  void setLanguage(AppLanguage lang) {
    selectedLanguage = lang;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('selected_language_code', lang.code);
    });
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
      if (email != null && email.isNotEmpty) await prefs.setString('user_email', email);
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

  Future<bool> checkAndRestoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedLangCode = prefs.getString('selected_language_code');
      if (savedLangCode != null && savedLangCode.isNotEmpty) {
        final foundLang = AppLanguage.all.firstWhere(
          (l) => l.code == savedLangCode,
          orElse: () => AppLanguage.all.first,
        );
        selectedLanguage = foundLang;
      }

      // Restore active Firebase user or SharedPreferences session
      final firebaseUser = FirebaseAuthService.currentUser;
      final isAuth = (prefs.getBool('is_authenticated') ?? false) || firebaseUser != null;
      final savedMobile = prefs.getString('user_mobile') ?? (firebaseUser?.phoneNumber ?? '');
      final savedEmail = prefs.getString('user_email') ?? (firebaseUser?.email ?? '');
      final savedName = prefs.getString('user_name') ?? (firebaseUser?.displayName ?? '');

      if (isAuth && (savedMobile.isNotEmpty || savedEmail.isNotEmpty)) {
        mobile = savedMobile;
        email = savedEmail;
        name = savedName;
        isAuthenticated = true;

        final lookupKey = mobile.isNotEmpty ? mobile : email;
        try {
          final existing = await ApiService.fetchProfile(lookupKey);
          if (existing != null) {
            profile = existing;
            if (existing.name.isNotEmpty) name = existing.name;
          }
        } catch (_) {}

        notifyListeners();
        return true;
      }
    } catch (_) {}
    notifyListeners();
    return false;
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

  /// Completely clears the user's session, Firebase auth, profile, form fields, and chat history.
  void logout() {
    FirebaseAuthService.signOut();
    clearSessionPrefs();
    isAuthenticated = false;
    mobile = '';
    email = '';
    latestDemoOtp = '';
    name = '';
    fatherName = '';
    motherName = '';
    aadhaar = '';
    annualIncome = '';
    category = 'Scheduled Caste (SC)';
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

    registrationStep = 0;
    _chatHistoryLoaded = false;
    isLoading = false;
    errorMessage = null;

    profile = UserProfile(
      mobile: '',
      email: '',
      name: 'Beneficiary',
      district: 'Murshidabad',
      state: 'West Bengal',
      location: 'Barasat, West Bengal',
    );

    chatMessages
      ..clear()
      ..add(
        const ChatMessage(
          "Hello! I'm your AI Skill Assistant. Tell me about the work you currently do. आप वर्तमान में क्या काम करते हैं?",
          true,
        ),
      );

    notifyListeners();
  }

  /// Helper to wipe any previous session data before commencing a new login/signup flow.
  void _prepareNewSession({String newMobile = '', String newEmail = '', String newName = ''}) {
    _chatHistoryLoaded = false;
    chatMessages
      ..clear()
      ..add(
        const ChatMessage(
          "Hello! I'm your AI Skill Assistant. Tell me about the work you currently do. आप वर्तमान में क्या काम करते हैं?",
          true,
        ),
      );
    mobile = newMobile;
    email = newEmail;
    name = newName;
    fatherName = '';
    motherName = '';
    aadhaar = '';
    annualIncome = '';
    scCategoryNo = '';
    scCertificateUrl = '';
    scCertificateFilename = '';
    highestQualification = '';
    stream = '';
    yearsOfStudy = '';
    workExperience = '';
    selectedLivelihood = '';
    selectedSkills.clear();
    selectedInterests.clear();
    registrationStep = 0;

    profile = UserProfile(
      mobile: newMobile,
      email: newEmail,
      name: newName.isNotEmpty ? newName : 'Beneficiary',
      district: district,
      state: stateName,
      location: location,
    );
  }

  // --- Auth (PostgreSQL) ---

  Future<String?> sendOtp(String mobile) async {
    _prepareNewSession(newMobile: mobile);
    _setLoading(true);
    try {
      final res = await ApiService.sendOtp(mobile);
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

  Future<String?> verifyOtp(String otp) async {
    _setLoading(true);
    try {
      final token = await ApiService.verifyOtp(mobile, otp);
      UserProfile? existing;
      try {
        existing = await ApiService.fetchProfile(mobile);
      } catch (_) {}

      isLoading = false;
      isAuthenticated = true;

      if (existing != null) {
        profile = existing;
        if (existing.name.isNotEmpty) name = existing.name;
        if (existing.mobile.isNotEmpty) mobile = existing.mobile;
        if (existing.email.isNotEmpty) email = existing.email;
        await saveSessionToPrefs(token: token, mobile: mobile, email: email, name: name);
        notifyListeners();
        return 'existing';
      }

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
    _prepareNewSession(newEmail: email);
    _setLoading(true);
    try {
      final res = await ApiService.sendEmailOtp(email);
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
      final token = await ApiService.verifyEmailOtp(email, otp);
      final lookupKey = mobile.isNotEmpty ? mobile : email;

      UserProfile? existing;
      try {
        existing = await ApiService.fetchProfile(lookupKey);
      } catch (_) {}

      isLoading = false;
      isAuthenticated = true;

      if (existing != null) {
        profile = existing;
        if (existing.name.isNotEmpty) name = existing.name;
        if (existing.mobile.isNotEmpty) mobile = existing.mobile;
        if (existing.email.isNotEmpty) this.email = existing.email;
        await saveSessionToPrefs(token: token, mobile: mobile, email: this.email, name: name);
        notifyListeners();
        return 'existing';
      }

      await saveSessionToPrefs(token: token, mobile: mobile, email: this.email, name: name);
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
        email = existing.email;
        isAuthenticated = true;
        await saveSessionToPrefs(token: token, mobile: mobile, email: email, name: name);
        notifyListeners();
        return 'existing';
      }
      await saveSessionToPrefs(token: token, mobile: mobile, email: email, name: name);
      notifyListeners();
      return 'new';
    } catch (e) {
      isLoading = false;
      errorMessage = _cleanError(e);
      notifyListeners();
      return null;
    }
  }

  // --- Google & Firebase Auth ---

  Future<String?> loginWithGoogle(String email, String name, String? googleId) async {
    _prepareNewSession(newEmail: email, newName: name);
    _setLoading(true);
    try {
      final res = await ApiService.loginWithGoogle(email: email, name: name, googleId: googleId);
      final token = res['token'] as String? ?? 'demo-google-jwt';
      final lookupKey = mobile.isNotEmpty ? mobile : email;
      final existing = await ApiService.fetchProfile(lookupKey);
      isLoading = false;
      if (existing != null) {
        profile = existing;
        this.name = existing.name.isNotEmpty ? existing.name : name;
        mobile = existing.mobile;
        this.email = existing.email.isNotEmpty ? existing.email : email;
        isAuthenticated = true;
        await saveSessionToPrefs(token: token, mobile: mobile, email: this.email, name: this.name);
        notifyListeners();
        return 'existing';
      }
      await saveSessionToPrefs(token: token, mobile: mobile, email: this.email, name: this.name);
      notifyListeners();
      return 'new';
    } catch (e) {
      isLoading = false;
      errorMessage = _cleanError(e);
      notifyListeners();
      return null;
    }
  }

  Future<String?> signUpWithEmail(String email, String password, String name, String mobile) async {
    _prepareNewSession(newEmail: email, newMobile: mobile, newName: name);
    _setLoading(true);
    try {
      final res = await ApiService.signUpWithEmail(email: email, password: password, name: name, mobile: mobile);
      final token = res['token'] as String? ?? 'demo-jwt';
      isLoading = false;
      await saveSessionToPrefs(token: token, mobile: mobile, email: email, name: name);
      notifyListeners();
      return 'new';
    } catch (e) {
      isLoading = false;
      errorMessage = _cleanError(e);
      notifyListeners();
      return null;
    }
  }

  Future<String?> loginWithEmail(String email, String password) async {
    _prepareNewSession(newEmail: email);
    _setLoading(true);
    try {
      final res = await ApiService.loginWithEmail(email: email, password: password);
      final token = res['token'] as String? ?? 'demo-jwt';
      final lookupKey = mobile.isNotEmpty ? mobile : email;
      final existing = await ApiService.fetchProfile(lookupKey);
      isLoading = false;
      if (existing != null) {
        profile = existing;
        name = existing.name;
        mobile = existing.mobile;
        this.email = existing.email;
        isAuthenticated = true;
        await saveSessionToPrefs(token: token, mobile: mobile, email: this.email, name: name);
        notifyListeners();
        return 'existing';
      }
      await saveSessionToPrefs(token: token, mobile: mobile, email: this.email, name: name);
      notifyListeners();
      return 'new';
    } catch (e) {
      isLoading = false;
      errorMessage = _cleanError(e);
      notifyListeners();
      return null;
    }
  }

  // --- Registration & Profile Updates ---

  Future<bool> updateUserProfile(UserProfile updatedProfile) async {
    _setLoading(true);
    try {
      profile = await ApiService.saveProfile(updatedProfile);
      isLoading = false;
      await saveSessionToPrefs(mobile: profile.mobile, email: profile.email, name: profile.name);
      notifyListeners();
      return true;
    } catch (e) {
      profile = updatedProfile;
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeRegistration() async {
    profile.mobile = mobile.isNotEmpty ? mobile : email;
    profile.email = email;
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

    _setLoading(true);
    try {
      profile = await ApiService.saveProfile(profile);
      isAuthenticated = true;
      isLoading = false;
      await saveSessionToPrefs(mobile: profile.mobile, email: profile.email, name: profile.name);
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // --- AI Chat Features ---

  Future<void> loadChatHistory() async {
    final lookupKey = mobile.isNotEmpty ? mobile : email;
    if (_chatHistoryLoaded || lookupKey.isEmpty) return;
    _chatHistoryLoaded = true;
    try {
      final history = await ApiService.fetchChatHistory(lookupKey);
      if (history.isNotEmpty) {
        chatMessages
          ..clear()
          ..addAll(history);
        notifyListeners();
      }
    } catch (_) {
      // Backend down or no history yet
    }
  }

  Future<void> sendChatMessage(String text) async {
    if (text.trim().isEmpty) return;
    chatMessages.add(ChatMessage(text, false));
    notifyListeners();
    final lookupKey = mobile.isNotEmpty ? mobile : email;
    try {
      final reply = await ApiService.sendChatMessage(lookupKey, text);
      chatMessages.add(ChatMessage(reply.isNotEmpty ? reply : "Sorry, I didn't get a response — please try again.", true));
    } catch (e) {
      chatMessages.add(const ChatMessage(
        "I couldn't reach the server just now. Please check your connection and try again.",
        true,
      ));
    }
    notifyListeners();
  }

  /// Permanently clears current conversation history on server & local state.
  Future<void> clearChat() async {
    final lookupKey = mobile.isNotEmpty ? mobile : email;
    if (lookupKey.isNotEmpty) {
      await ApiService.clearChatHistory(lookupKey);
    }
    _chatHistoryLoaded = true;
    chatMessages
      ..clear()
      ..add(
        const ChatMessage(
          "Hello! I'm your AI Skill Assistant. Tell me about the work you currently do. आप वर्तमान में क्या काम करते हैं?",
          true,
        ),
      );
    notifyListeners();
  }

  /// Restarts current conversation flow and onboarding context.
  Future<void> restartChat() async {
    final lookupKey = mobile.isNotEmpty ? mobile : email;
    if (lookupKey.isNotEmpty) {
      await ApiService.restartChat(lookupKey);
    }
    _chatHistoryLoaded = true;
    chatMessages
      ..clear()
      ..add(
        const ChatMessage(
          "Hello! 👋 Welcome to Disha Saathi AI Assistant. What is your name?",
          true,
        ),
      );
    notifyListeners();
  }

  /// Starts a completely new chat session without carrying over prior conversation context.
  void startNewChat() {
    chatMessages
      ..clear()
      ..add(
        const ChatMessage(
          "New conversation started! How can I assist you today with your skills and career?",
          true,
        ),
      );
    notifyListeners();
  }

  /// Deletes an individual chat message by index.
  void deleteChatMessage(int index) {
    if (index >= 0 && index < chatMessages.length) {
      chatMessages.removeAt(index);
      notifyListeners();
    }
  }

  /// Edits a previous user message, removes subsequent responses, and resends.
  Future<void> editAndResendMessage(int index, String newText) async {
    if (index >= 0 && index < chatMessages.length) {
      chatMessages.removeRange(index, chatMessages.length);
      notifyListeners();
      await sendChatMessage(newText);
    }
  }

  List<JourneyStep> get journeySteps => const [
    JourneyStep('Profile Setup', 'Completed', JourneyStepState.completed, 'check'),
    JourneyStep('Livelihood Mapping', 'Completed', JourneyStepState.completed, 'check'),
    JourneyStep('Skill Assessment', 'Completed', JourneyStepState.completed, 'check'),
    JourneyStep('Recommendations', 'Completed', JourneyStepState.completed, 'check'),
    JourneyStep('Training', 'In progress — Find training to continue', JourneyStepState.active, 'school'),
    JourneyStep('Completion', 'Locked · Complete previous step', JourneyStepState.locked, 'medal'),
    JourneyStep('Certification', 'Locked · Complete previous step', JourneyStepState.locked, 'certificate'),
  ];
}
