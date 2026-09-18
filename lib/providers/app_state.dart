import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/api_service.dart';

/// Central app state shared across screens using Provider.
/// Talks to the Node.js/Express backend (see /backend) for auth,
/// beneficiary profile persistence, and the AI Chat.
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

  void setLanguage(AppLanguage lang) {
    selectedLanguage = lang;
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

  // --- Auth ---

  Future<bool> sendOtp(String mobile) async {
    if (this.mobile != mobile) _chatHistoryLoaded = false;
    this.mobile = mobile;
    _setLoading(true);
    try {
      await ApiService.sendOtp(mobile);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<String?> verifyOtp(String otp) async {
    _setLoading(true);
    try {
      await ApiService.verifyOtp(mobile, otp);
      final existing = await ApiService.fetchProfile(mobile);
      isLoading = false;
      if (existing != null) {
        profile = existing;
        isAuthenticated = true;
        notifyListeners();
        return 'existing';
      }
      notifyListeners();
      return 'new';
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // --- Email OTP Auth ---

  Future<bool> sendEmailOtp(String email) async {
    if (this.email != email) _chatHistoryLoaded = false;
    this.email = email;
    _setLoading(true);
    try {
      await ApiService.sendEmailOtp(email);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<String?> verifyEmailOtp(String otp) async {
    _setLoading(true);
    try {
      await ApiService.verifyEmailOtp(email, otp);
      final lookupKey = mobile.isNotEmpty ? mobile : email;
      final existing = await ApiService.fetchProfile(lookupKey);
      isLoading = false;
      if (existing != null) {
        profile = existing;
        isAuthenticated = true;
        notifyListeners();
        return 'existing';
      }
      notifyListeners();
      return 'new';
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<String?> loginWithPassword(String mobile, String password) async {
    if (this.mobile != mobile) _chatHistoryLoaded = false;
    this.mobile = mobile;
    _setLoading(true);
    try {
      await ApiService.loginWithPassword(mobile, password);
      final existing = await ApiService.fetchProfile(mobile);
      isLoading = false;
      if (existing != null) {
        profile = existing;
        isAuthenticated = true;
        notifyListeners();
        return 'existing';
      }
      notifyListeners();
      return 'new';
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // --- Google & Email Auth ---

  Future<String?> loginWithGoogle(String email, String name, String? googleId) async {
    this.email = email;
    if (this.name.isEmpty) this.name = name;
    _setLoading(true);
    try {
      await ApiService.loginWithGoogle(email: email, name: name, googleId: googleId);
      final lookupKey = mobile.isNotEmpty ? mobile : email;
      final existing = await ApiService.fetchProfile(lookupKey);
      isLoading = false;
      if (existing != null) {
        profile = existing;
        isAuthenticated = true;
        notifyListeners();
        return 'existing';
      }
      notifyListeners();
      return 'new';
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<String?> signUpWithEmail(String email, String password, String name, String mobile) async {
    this.email = email;
    this.name = name;
    if (mobile.isNotEmpty) this.mobile = mobile;
    _setLoading(true);
    try {
      await ApiService.signUpWithEmail(email: email, password: password, name: name, mobile: mobile);
      isLoading = false;
      notifyListeners();
      return 'new';
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<String?> loginWithEmail(String email, String password) async {
    this.email = email;
    _setLoading(true);
    try {
      await ApiService.loginWithEmail(email: email, password: password);
      final lookupKey = mobile.isNotEmpty ? mobile : email;
      final existing = await ApiService.fetchProfile(lookupKey);
      isLoading = false;
      if (existing != null) {
        profile = existing;
        isAuthenticated = true;
        notifyListeners();
        return 'existing';
      }
      notifyListeners();
      return 'new';
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // --- Registration ---

  Future<bool> completeRegistration() async {
    profile.mobile = mobile.isNotEmpty ? mobile : email;
    profile.name = name.isNotEmpty ? name : profile.name;
    profile.annualIncome = annualIncome;
    profile.category = category;
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
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  bool _chatHistoryLoaded = false;

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
