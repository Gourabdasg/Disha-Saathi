/// Supported UI languages (from language-select screen).
/// Includes all 22 languages listed in the Eighth Schedule of the
/// Constitution of India, plus English (used for the PM-AJAY/GIA portal UI).
class AppLanguage {
  final String code;
  final String nativeName;
  final String englishName;
  final String flagLabel; // short language-code badge shown in the UI
  const AppLanguage(this.code, this.nativeName, this.englishName, this.flagLabel);

  static const List<AppLanguage> all = [
    AppLanguage('as', 'অসমীয়া', 'Assamese', 'AS'),
    AppLanguage('bn', 'বাংলা', 'Bengali', 'BN'),
    AppLanguage('brx', 'बड़ो', 'Bodo', 'BR'),
    AppLanguage('doi', 'डोगरी', 'Dogri', 'DO'),
    AppLanguage('en', 'English', 'English', 'EN'),
    AppLanguage('gu', 'ગુજરાતી', 'Gujarati', 'GU'),
    AppLanguage('hi', 'हिंदी', 'Hindi', 'HI'),
    AppLanguage('kn', 'ಕನ್ನಡ', 'Kannada', 'KN'),
    AppLanguage('ks', 'कॉशुर', 'Kashmiri', 'KS'),
    AppLanguage('kok', 'कोंकणी', 'Konkani', 'KO'),
    AppLanguage('mai', 'मैथिली', 'Maithili', 'MA'),
    AppLanguage('ml', 'മലയാളം', 'Malayalam', 'ML'),
    AppLanguage('mni', 'মৈতৈলোন্', 'Manipuri (Meitei)', 'MN'),
    AppLanguage('mr', 'मराठी', 'Marathi', 'MR'),
    AppLanguage('ne', 'नेपाली', 'Nepali', 'NE'),
    AppLanguage('or', 'ଓଡ଼ିଆ', 'Odia', 'OD'),
    AppLanguage('pa', 'ਪੰਜਾਬੀ', 'Punjabi', 'PA'),
    AppLanguage('sa', 'संस्कृतम्', 'Sanskrit', 'SA'),
    AppLanguage('sat', 'ᱥᱟᱱᱛᱟᱲᱤ', 'Santali', 'ST'),
    AppLanguage('sd', 'سنڌي', 'Sindhi', 'SD'),
    AppLanguage('ta', 'தமிழ்', 'Tamil', 'TA'),
    AppLanguage('te', 'తెలుగు', 'Telugu', 'TE'),
    AppLanguage('ur', 'اردو', 'Urdu', 'UR'),
  ];
}

/// Beneficiary profile collected across the registration and profile completion flows.
class UserProfile {
  String mobile;
  String email;
  String name;
  int? age;
  String fatherName;
  String motherName;
  String aadhaar;
  String annualIncome;
  String category; // Always 'Scheduled Caste (SC)'
  String scCategoryNo; // SC Certificate Number
  String scCertificateUrl; // Uploaded SC Certificate File URL
  String scCertificateFilename; // Uploaded file display name
  String district;
  String state;
  String location; // Full location string (e.g. Barasat, West Bengal)

  String highestQualification;
  String stream;
  String yearOfQualification;
  int yearsOfStudy;

  String experienceName;
  String experienceDuration;
  int workExperienceYears;

  String livelihood; // Current Livelihood / Occupation
  String familyOccupation;
  String employmentPreference;
  String mobilityConstraints;
  String careerGoal;
  bool onboardingComplete;
  String photoUrl;
  String bio;

  List<String> existingSkills;
  List<String> careerInterests;
  String preferredLanguage;

  int profileCompletionPercent;
  int journeyPercent;

  UserProfile({
    this.mobile = '',
    this.email = '',
    this.name = 'Rahul Kumar',
    this.age,
    this.fatherName = '',
    this.motherName = '',
    this.aadhaar = '',
    this.annualIncome = '',
    this.category = 'Scheduled Caste (SC)',
    this.scCategoryNo = '',
    this.scCertificateUrl = '',
    this.scCertificateFilename = '',
    this.district = 'Murshidabad',
    this.state = 'West Bengal',
    this.location = 'Barasat, West Bengal',
    this.highestQualification = '',
    this.stream = '',
    this.yearOfQualification = '',
    this.yearsOfStudy = 10,
    this.experienceName = '',
    this.experienceDuration = '',
    this.workExperienceYears = 0,
    this.livelihood = '',
    this.familyOccupation = '',
    this.employmentPreference = '',
    this.mobilityConstraints = '',
    this.careerGoal = '',
    this.onboardingComplete = false,
    this.photoUrl = '',
    this.bio = '',
    this.workExperienceYears = 0,
    this.livelihood = '',
    this.familyOccupation = '',
    this.employmentPreference = '',
    this.mobilityConstraints = '',
    this.careerGoal = '',
    this.onboardingComplete = false,
    List<String>? existingSkills,
    List<String>? careerInterests,
    this.preferredLanguage = 'en',
    int? profileCompletionPercent,
    int? journeyPercent,
  })  : existingSkills = existingSkills ?? [],
        careerInterests = careerInterests ?? [],
        profileCompletionPercent = profileCompletionPercent ?? 0,
        journeyPercent = journeyPercent ?? 0 {
    this.profileCompletionPercent = calculateCompletionPercent();
    this.journeyPercent = calculateProgressPercent();
  }

  /// Dynamic Profile Completion % calculation based on filled 14 required fields
  int calculateCompletionPercent() {
    if (onboardingComplete) return 100;

    int filled = 0;
    const totalFields = 14;

    if (name.trim().isNotEmpty) filled++;
    if (age != null && age! > 0) filled++;
    if (state.trim().isNotEmpty) filled++;
    if (district.trim().isNotEmpty) filled++;
    if (location.trim().isNotEmpty) filled++;
    if (highestQualification.trim().isNotEmpty) filled++;
    if (livelihood.trim().isNotEmpty) filled++;
    if (familyOccupation.trim().isNotEmpty) filled++;
    if (existingSkills.isNotEmpty) filled++;
    if (experienceName.trim().isNotEmpty || workExperienceYears > 0) filled++;
    if (careerInterests.isNotEmpty) filled++;
    if (employmentPreference.trim().isNotEmpty) filled++;
    if (mobilityConstraints.trim().isNotEmpty) filled++;
    if (careerGoal.trim().isNotEmpty) filled++;

    final percent = ((filled / totalFields) * 100).round();
    return percent > 100 ? 100 : percent;
  }

  /// Dynamic My Progress % calculation based on actual completed activities
  int calculateProgressPercent() {
    int progress = 26; // Initial baseline progress
    if (calculateCompletionPercent() > 50) progress += 20;
    if (calculateCompletionPercent() >= 80) progress += 25;
    if (existingSkills.isNotEmpty) progress += 15;
    if (careerInterests.isNotEmpty) progress += 14;
    return progress > 100 ? 100 : progress;
  }

  /// Returns list of missing required profile field names for Dashboard display
  List<String> get missingFields {
    final missing = <String>[];
    if (highestQualification.trim().isEmpty) missing.add('Highest Qualification');
    if (stream.trim().isEmpty) missing.add('Stream');
    if (yearOfQualification.trim().isEmpty) missing.add('Year of Qualification');
    if (experienceName.trim().isEmpty) missing.add('Work Experience');
    if (livelihood.trim().isEmpty) missing.add('Current Occupation');
    if (existingSkills.isEmpty) missing.add('Skills');
    if (careerInterests.isEmpty) missing.add('Career Interests');
    return missing;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final profile = UserProfile(
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      name: (json['name'] as String?)?.isNotEmpty == true ? json['name'] : 'Rahul Kumar',
      age: json['age'] != null ? parseInt(json['age']) : null,
      fatherName: json['fatherName'] ?? '',
      motherName: json['motherName'] ?? '',
      aadhaar: json['aadhaar'] ?? '',
      annualIncome: json['annualIncome'] ?? '',
      category: 'Scheduled Caste (SC)', // Enforced
      scCategoryNo: json['scCategoryNo'] ?? '',
      scCertificateUrl: json['scCertificateUrl'] ?? '',
      scCertificateFilename: json['scCertificateFilename'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      location: json['location'] ?? '',
      highestQualification: json['highestQualification'] ?? json['education'] ?? '',
      stream: json['stream'] ?? '',
      yearOfQualification: json['yearOfQualification'] ?? '',
      yearsOfStudy: (json['yearsOfStudy'] as num?)?.toInt() ?? 0,
      experienceName: json['experienceName'] ?? json['experience'] ?? '',
      experienceDuration: json['experienceDuration'] ?? '',
      workExperienceYears: (json['workExperienceYears'] as num?)?.toInt() ?? 0,
      livelihood: json['livelihood'] ?? json['currentOccupation'] ?? '',
      familyOccupation: json['familyOccupation'] ?? '',
      employmentPreference: json['employmentPreference'] ?? '',
      mobilityConstraints: json['mobilityConstraints'] ?? '',
      careerGoal: json['careerGoal'] ?? '',
      onboardingComplete: json['onboardingComplete'] == true,
      photoUrl: json['photoUrl'] ?? json['photo_url'] ?? '',
      bio: json['bio'] ?? '',
      existingSkills: (json['existingSkills'] as List?)?.map((e) => e.toString()).toList() ??
          (json['skills'] is String && (json['skills'] as String).isNotEmpty
              ? (json['skills'] as String).split(',').map((s) => s.trim()).toList()
              : []),
      careerInterests: (json['careerInterests'] as List?)?.map((e) => e.toString()).toList() ??
          (json['interests'] is String && (json['interests'] as String).isNotEmpty
              ? (json['interests'] as String).split(',').map((s) => s.trim()).toList()
              : []),
      preferredLanguage: json['preferredLanguage'] ?? 'en',
    );

    profile.profileCompletionPercent = json['profileCompletionPercent'] != null
        ? (json['profileCompletionPercent'] as num).toInt()
        : profile.calculateCompletionPercent();
    profile.journeyPercent = profile.calculateProgressPercent();
    return profile;
  }

  static int? parseInt(dynamic val) {
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val);
    return null;
  }

  Map<String, dynamic> toJson() => {
    'mobile': mobile,
    'email': email,
    'name': name,
    'age': age,
    'fatherName': fatherName,
    'motherName': motherName,
    'aadhaar': aadhaar,
    'annualIncome': annualIncome,
    'category': 'Scheduled Caste (SC)',
    'scCategoryNo': scCategoryNo,
    'scCertificateUrl': scCertificateUrl,
    'scCertificateFilename': scCertificateFilename,
    'district': district,
    'state': state,
    'location': location,
    'highestQualification': highestQualification,
    'education': highestQualification,
    'stream': stream,
    'yearOfQualification': yearOfQualification,
    'yearsOfStudy': yearsOfStudy,
    'experienceName': experienceName,
    'experience': experienceName,
    'experienceDuration': experienceDuration,
    'workExperienceYears': workExperienceYears,
    'livelihood': livelihood,
    'currentOccupation': livelihood,
    'familyOccupation': familyOccupation,
    'employmentPreference': employmentPreference,
    'mobilityConstraints': mobilityConstraints,
    'careerGoal': careerGoal,
    'onboardingComplete': onboardingComplete,
    'photoUrl': photoUrl,
    'photo_url': photoUrl,
    'bio': bio,
    'existingSkills': existingSkills,
    'skills': existingSkills.join(', '),
    'careerInterests': careerInterests,
    'interests': careerInterests.join(', '),
    'preferredLanguage': preferredLanguage,
    'profileCompletionPercent': calculateCompletionPercent(),
    'journeyPercent': calculateProgressPercent(),
  };
}

/// A single saved Chat Session item in Chat History
class ChatSessionItem {
  final String sessionId;
  final String title;
  final String lastMessage;
  final String updatedAt;
  final int messageCount;

  ChatSessionItem({
    required this.sessionId,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
    required this.messageCount,
  });

  factory ChatSessionItem.fromJson(Map<String, dynamic> json) {
    return ChatSessionItem(
      sessionId: json['sessionId'] ?? 'default',
      title: json['title'] ?? 'AI Skill Assessment',
      lastMessage: json['lastMessage'] ?? 'Conversation started',
      updatedAt: json['updatedAt'] ?? '',
      messageCount: json['messageCount'] as int? ?? 0,
    );
  }
}

/// A single NSQF-aligned skill/career recommendation generated by the AI engine.
class SkillRecommendation {
  final String title;
  final int matchPercent;
  final int nsqfLevel;
  final String duration;
  final String icon; // emoji / material icon key
  final String insight;
  final List<String> pathway;
  final List<String> skillsToLearn;
  final String expectedSalary;
  final String colorKey; // maps to AppColors

  const SkillRecommendation({
    required this.title,
    required this.matchPercent,
    required this.nsqfLevel,
    required this.duration,
    required this.icon,
    required this.insight,
    required this.pathway,
    required this.skillsToLearn,
    required this.expectedSalary,
    required this.colorKey,
  });

  static List<SkillRecommendation> mock = [
    const SkillRecommendation(
      title: 'Digital Office Assistant',
      matchPercent: 92,
      nsqfLevel: 3,
      duration: '3 months',
      icon: 'computer',
      insight: 'Your education and interest in digital skills make this a perfect fit.',
      pathway: ['Basic Computer', 'Office Software', 'Data Entry', 'Job Ready'],
      skillsToLearn: ['Computer Operation', 'MS Office', 'Data Entry', 'Internet Use'],
      expectedSalary: '₹12,000–18,000/month',
      colorKey: 'navy',
    ),
    const SkillRecommendation(
      title: 'Data Entry Operator',
      matchPercent: 87,
      nsqfLevel: 2,
      duration: '2 months',
      icon: 'assignment',
      insight: 'Strong attention to detail and literacy background suits data entry roles perfectly.',
      pathway: ['Typing Training', 'Data Tools', 'Accuracy Practice', 'Certified'],
      skillsToLearn: ['Typing Speed', 'Data Accuracy', 'Computer Basics', 'File Management'],
      expectedSalary: '₹10,000–15,000/month',
      colorKey: 'purple',
    ),
    const SkillRecommendation(
      title: 'Retail Sales Associate',
      matchPercent: 81,
      nsqfLevel: 2,
      duration: '6 weeks',
      icon: 'cart',
      insight: 'Your communication skills and customer interaction experience are key assets here.',
      pathway: ['Retail Basics', 'Customer Skills', 'POS Training', 'Job Ready'],
      skillsToLearn: ['Customer Service', 'Cash Handling', 'Inventory', 'Communication'],
      expectedSalary: '₹9,000–14,000/month',
      colorKey: 'teal',
    ),
  ];
}

/// A nearby / online training opportunity (NSDC / PMKK / SSDM partners).
class TrainingCourse {
  final String title;
  final String provider;
  final double distanceKm;
  final String duration;
  final int nsqfLevel;
  final bool freeGiaFunded;
  final int? seatsLeft;
  final String mode; // Classroom / Hybrid / Online
  final String schedule;
  final String eligibility;
  final String icon;

  const TrainingCourse({
    required this.title,
    required this.provider,
    required this.distanceKm,
    required this.duration,
    required this.nsqfLevel,
    required this.freeGiaFunded,
    this.seatsLeft,
    required this.mode,
    required this.schedule,
    required this.eligibility,
    required this.icon,
  });

  static List<TrainingCourse> mock = const [
    TrainingCourse(
      title: 'Digital Office Assistant',
      provider: 'NSDC Training Partner',
      distanceKm: 4.2,
      duration: '3 Months',
      nsqfLevel: 3,
      freeGiaFunded: true,
      mode: 'Classroom',
      schedule: 'Mon–Sat, 9am–12pm',
      eligibility: 'Pass 10th/12th, Age 18–35',
      icon: 'computer',
    ),
    TrainingCourse(
      title: 'Data Entry Operator',
      provider: 'Pradhan Mantri Kaushal Kendra',
      distanceKm: 7.8,
      duration: '2 Months',
      nsqfLevel: 2,
      freeGiaFunded: true,
      seatsLeft: 3,
      mode: 'Hybrid',
      schedule: 'Mon–Fri, 2pm–5pm',
      eligibility: 'Pass 8th/10th, Age 18–40',
      icon: 'assignment',
    ),
  ];
}

/// A step in the "My Progress" skill journey tracker.
class JourneyStep {
  final String title;
  final String subtitle;
  final JourneyStepState state;
  final String icon;
  const JourneyStep(this.title, this.subtitle, this.state, this.icon);
}

enum JourneyStepState { completed, active, locked }

/// Notification item.
class AppNotification {
  final String title;
  final String body;
  final String time;
  final String icon;
  final bool unread;
  const AppNotification(this.title, this.body, this.time, this.icon, this.unread);

  static List<AppNotification> mock = const [
    AppNotification('New Match Found!', 'Digital Office Assistant — 92% match to your profile', '2 min ago', 'star', true),
    AppNotification('Training Starting Soon', 'Data Entry Operator course begins Sep 1 at Berhampore center', '1 hour ago', 'school', true),
  ];
}

/// A chat/voice bubble in the AI Skill Assistant conversation.
class ChatMessage {
  final String text;
  final bool isBot;
  final String? audioBase64;
  const ChatMessage(this.text, this.isBot, {this.audioBase64});
}
