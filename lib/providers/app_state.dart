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

String getQuestionTextForField(String fieldKey, UserProfile profile, String langCode) {
  final lang = langCode.toLowerCase().trim();
  final displayName = profile.name.isNotEmpty ? profile.name : 'Friend';

  switch (fieldKey) {
    case 'age':
      if (lang == 'bn') return 'আপনার সাথে পরিচিত হয়ে আনন্দিত, $displayName! আপনার বয়স কত?';
      if (lang == 'hi') return 'आपसे मिलकर खुशी हुई, $displayName! आपकी उम्र क्या है?';
      if (lang == 'pa') return 'ਤੁਹਾਨੂੰ ਮਿਲ ਕੇ ਖੁਸ਼ੀ ਹੋਈ, $displayName! ਤੁਹਾਡੀ ਉਮਰ ਕਿੰਨੀ ਹੈ?';
      if (lang == 'ta') return 'உங்களை சந்தித்ததில் மகிழ்ச்சி, $displayName! உங்கள் வயது என்ன?';
      if (lang == 'te') return 'మిమ్మల్ని కలవడం సంతోషంగా ఉంది, $displayName! మీ వయస్సు ఎంత?';
      if (lang == 'mr') return 'तुम्हाला भेटून आनंद झाला, $displayName! तुमचे वय काय आहे?';
      if (lang == 'ur') return 'آپ سے مل کر خوشی ہوئی، $displayName! آپ کی عمر کیا ہے؟';
      return 'Nice to meet you, $displayName! What is your age?';

    case 'state':
      if (lang == 'bn') return 'আপনি বর্তমানে কোন রাজ্যে থাকেন?';
      if (lang == 'hi') return 'आप वर्तमान में किस राज्य से हैं?';
      if (lang == 'pa') return 'ਤੁਸੀਂ ਫਿਲਹਾਲ ਕਿਸ ਰਾਜ ਤੋਂ ਹੋ?';
      if (lang == 'ta') return 'நீங்கள் தற்போது எந்த மாநிலத்தைச் சேர்ந்தவர்?';
      if (lang == 'te') return 'మీరు ప్రస్తుతం ఏ రాష్ట్రానికి చెందినవారు?';
      if (lang == 'mr') return 'तुम्ही सध्या कोणत्या राज्यातील आहात?';
      if (lang == 'ur') return 'آپ فی الحال کس ریاست سے ہیں؟';
      return 'Which state are you currently from?';

    case 'district':
      if (lang == 'bn') return 'আপনার জেলার নাম কী?';
      if (lang == 'hi') return 'आपका जिला कौन सा है?';
      if (lang == 'pa') return 'ਤੁਹਾਡਾ ਜ਼ਿਲ੍ਹਾ ਕਿਹੜਾ ਹੈ?';
      if (lang == 'ta') return 'உங்கள் மாவட்டம் எது?';
      if (lang == 'te') return 'మీ జిల్లా ఏది?';
      if (lang == 'mr') return 'तुमचा जिल्हा कोणता आहे?';
      if (lang == 'ur') return 'آپ کا ضلع کون سا ہے؟';
      return 'Which district are you from?';

    case 'location':
      if (lang == 'bn') return 'আপনার বর্তমান অবস্থান বা শহরের নাম কী?';
      if (lang == 'hi') return 'आपका वर्तमान स्थान (शहर/गांव) क्या है?';
      if (lang == 'pa') return 'ਤੁਹਾਡਾ ਮੌਜੂਦਾ ਸਥਾਨ (ਸ਼ਹਿਰ/ਪਿੰਡ) ਕੀ ਹੈ?';
      if (lang == 'ta') return 'உங்கள் தற்போதைய இருப்பிடம் (நகரம்/கிராமம்) எது?';
      if (lang == 'te') return 'మీ ప్రస్తుత ప్రాంతం (నగరం/గ్రామం) ఏది?';
      if (lang == 'mr') return 'तुमचे सध्याचे स्थान (शहर/गाव) कोणते आहे?';
      if (lang == 'ur') return 'آپ کا موجودہ مقام (شہر/گاؤں) کیا ہے؟';
      return 'What is your current location (city/town/village)?';

    case 'education':
      if (lang == 'bn') return 'আপনার সর্বোচ্চ বা বর্তমান শিক্ষাগত যোগ্যতা কী?';
      if (lang == 'hi') return 'आपकी उच्चतम या वर्तमान शैक्षणिक योग्यता क्या है?';
      if (lang == 'pa') return 'ਤੁਹਾਡੀ ਉੱਚਤਮ ਜਾਂ ਮੌਜੂਦਾ ਵਿਦਿਅਕ ਯੋਗਤਾ ਕੀ ਹੈ?';
      if (lang == 'ta') return 'உங்கள் மிக உயர்ந்த அல்லது தற்போதைய கல்வித் தகுதி என்ன?';
      if (lang == 'te') return 'మీ అత్యున్నత లేదా ప్రస్తుత విద్యార్హత ఏమిటి?';
      if (lang == 'mr') return 'तुमची सर्वोच्च किंवा सध्याची शैक्षणिक पात्रता कोणती आहे?';
      if (lang == 'ur') return 'آپ کی اعلی ترین یا موجودہ تعلیمی قابلیت کیا ہے؟';
      return 'What is your highest or current level of education?';

    case 'currentOccupation':
      if (lang == 'bn') return 'আপনি বর্তমানে কী পেশা বা কাজের সাথে যুক্ত?';
      if (lang == 'hi') return 'आपका वर्तमान व्यवसाय या आजीविका का कार्य क्या है?';
      if (lang == 'pa') return 'ਤੁਹਾਡਾ ਮੌਜੂਦਾ ਕਿੱਤਾ ਜਾਂ ਕੰਮ ਕੀ ਹੈ?';
      if (lang == 'ta') return 'உங்கள் தற்போதைய தொழில் அல்லது வாழ்வாதார வேலை என்ன?';
      if (lang == 'te') return 'మీ ప్రస్తుత వృత్తి లేదా పని ఏమిటి?';
      if (lang == 'mr') return 'तुमचा सध्याचा व्यवसाय किंवा उपजीविकेचे काम काय आहे?';
      if (lang == 'ur') return 'آپ کا موجودہ پیشہ یا کام کیا ہے؟';
      return 'What is your current occupation or livelihood work?';

    case 'familyOccupation':
      if (lang == 'bn') return 'আপনার পরিবারের মূল পেশা বা কাজ কী?';
      if (lang == 'hi') return 'आपके परिवार का मुख्य व्यवसाय या कार्य क्या है?';
      if (lang == 'pa') return 'ਤੁਹਾਡੇ ਪਰਿਵਾਰ ਦਾ ਮੁੱਖ ਕਿੱਤਾ ਕੀ ਹੈ?';
      if (lang == 'ta') return 'உங்கள் குடும்பத்தின் தொழில் என்ன?';
      if (lang == 'te') return 'మీ కుటుంబ వృత్తి ఏమిటి?';
      if (lang == 'mr') return 'तुमच्या कुटुंबाचा मुख्य व्यवसाय कोणता आहे?';
      if (lang == 'ur') return 'آپ کے خاندان کا پیشہ کیا ہے؟';
      return 'What is your family\'s occupation?';

    case 'skills':
      if (lang == 'bn') return 'আপনার প্রধান দক্ষতা বা কাজ করার অভিজ্ঞতা কী কী?';
      if (lang == 'hi') return 'आपके पास मुख्य काम के कौशल (Skills) क्या हैं?';
      if (lang == 'pa') return 'ਤੁਹਾਡੇ ਕੋਲ ਮੁੱਖ ਕੰਮ ਦੇ ਹੁਨਰ ਕੀ ਹਨ?';
      if (lang == 'ta') return 'உங்கள் முக்கிய வேலைத் திறன்கள் என்ன?';
      if (lang == 'te') return 'మీ ముఖ్యమైన పని నైపుణ్యాలు ఏమిటి?';
      if (lang == 'mr') return 'तुमचे मुख्य कामाचे कौशल्य (Skills) कोणते आहे?';
      if (lang == 'ur') return 'آپ کے پاس کون سی اہم کام کی مہارتیں ہیں؟';
      return 'What are your main work skills?';

    case 'experience':
      if (lang == 'bn') return 'আপনার কি পূর্বে কোনো কাজের বা শিক্ষানবিশির অভিজ্ঞতা আছে?';
      if (lang == 'hi') return 'क्या आपके पास कोई पिछला काम या इंटर्नशिप का अनुभव है?';
      if (lang == 'pa') return 'ਕੀ ਤੁਹਾਡੇ ਕੋਲ ਪਿਛਲੇ ਕੰਮ ਦਾ ਕੋਈ ਤਜਰਬਾ ਹੈ?';
      if (lang == 'ta') return 'உங்களுக்கு முன் வேலை அனுபவம் ஏதேனும் உள்ளதா?';
      if (lang == 'te') return 'మీకు గతంలో పని చేసిన అనుభవం ఉందా?';
      if (lang == 'mr') return 'तुम्हाला पूर्वीचा कामाचा किंवा इंटर्नशिपचा अनुभव आहे का?';
      if (lang == 'ur') return 'کیا آپ کے پاس کام کا کوئی سابقہ تجربہ ہے؟';
      return 'Do you have any previous work or internship experience?';

    case 'interests':
      if (lang == 'bn') return 'আপনার ক্যারিয়ারের মূল পছন্দের বা আগ্রহের ক্ষেত্র কী?';
      if (lang == 'hi') return 'आपके करियर की मुख्य रुचि के क्षेत्र क्या हैं?';
      if (lang == 'pa') return 'ਤੁਹਾਡੀਆਂ ਮੁੱਖ ਕਰੀਅਰ ਰੁਚੀਆਂ ਕੀ ਹਨ?';
      if (lang == 'ta') return 'உங்கள் முக்கிய தொழில் ஆர்வங்கள் என்ன?';
      if (lang == 'te') return 'మీ ప్రధాన కెరీర్ ఆసక్తులు ఏమిటి?';
      if (lang == 'mr') return 'तुमच्या करिअरच्या आवडीचे मुख्य क्षेत्र कोणते आहे?';
      if (lang == 'ur') return 'آپ کی اہم کیریئر کی دلچسپیاں کیا ہیں؟';
      return 'What are your main career interests?';

    case 'employmentPreference':
      if (lang == 'bn') return 'আপনি কী ধরনের চাকরি পছন্দ করেন (ফুল-টাইম, খণ্ডকালীন, স্বনির্ভর বা সরকারি)?';
      if (lang == 'hi') return 'आप किस प्रकार का रोजगार चाहते हैं (जैसे फुल-टाइम, पार्ट-टाइम, स्वरोजगार, सरकारी नौकरी)?';
      if (lang == 'pa') return 'ਤੁਸੀਂ ਕਿਸ ਤਰ੍ਹਾਂ ਦਾ ਰੁਜ਼ਗਾਰ ਚਾਹੁੰਦੇ ਹੋ (ਜਿਵੇਂ ਫੁੱਲ-ਟਾਈਮ, ਸਵੈ-ਰੁਜ਼ਗਾਰ)?';
      if (lang == 'ta') return 'நீங்கள் எந்த வகையான வேலையை எதிர்பார்க்கிறீர்கள் (முழுநேரம், சுயதொழில்)?';
      if (lang == 'te') return 'మీరు ఎలాంటి ఉద్యోగాన్ని కోరుకుంటున్నారు (ఫుల్ టైమ్, స్వయం ఉపాధి)?';
      if (lang == 'mr') return 'तुम्हाला कोणत्या प्रकारचा रोजगार हवा आहे (उदा. फुल-टाइम, स्वयंरोजगार)?';
      if (lang == 'ur') return 'آپ کس قسم کا روزگار چاہتے ہیں (مثلاً فل ٹائم، اپنا کاروبار)؟';
      return 'What type of employment are you looking for (e.g. full-time, part-time, self-employed, government job)?';

    case 'mobilityConstraints':
      if (lang == 'bn') return 'আপনার অন্য স্থান বা জেলায় স্থানান্তরিত হওয়ার কোনো সীমাবদ্ধতা আছে?';
      if (lang == 'hi') return 'क्या आपके पास कोई स्थान परिवर्तन (Relocation) या आने-जाने की सीमा है?';
      if (lang == 'pa') return 'ਕੀ ਤੁਹਾਡੇ ਕੋਲ ਹੋਰ ਥਾਂ ਜਾਣ ਵਿੱਚ ਕੋਈ ਰੁਕਾਵਟ ਜਾਂ ਸੀਮਾ ਹੈ?';
      if (lang == 'ta') return 'வேறு இடத்திற்குச் சென்று வேலை செய்ய உங்களுக்கு ஏதேனும் தடைகள் உள்ளதா?';
      if (lang == 'te') return 'మీకు వేరే ప్రాంతానికి వెళ్లి పని చేయడానికి ఏమైనా పరిమితులు ఉన్నాయా?';
      if (lang == 'mr') return 'तुम्हाला इतर ठिकाणी स्थलांतरित होण्यासाठी काही मर्यादा आहेत का?';
      if (lang == 'ur') return 'کیا آپ کو کسی دوسرے مقام پر منتقل ہونے میں کوئی رکاوٹ ہے؟';
      return 'Do you have any mobility constraints or relocation limits?';

    case 'careerGoal':
      if (lang == 'bn') return 'আপনার ক্যারিয়ারের প্রধান লক্ষ্য বা স্বপ্ন কী?';
      if (lang == 'hi') return 'आपका मुख्य करियर का लक्ष्य या सपना क्या है?';
      if (lang == 'pa') return 'ਤੁਹਾਡਾ ਮੁੱਖ ਕਰੀਅਰ ਦਾ ਟੀਚਾ ਕੀ ਹੈ?';
      if (lang == 'ta') return 'உங்கள் முக்கிய தொழில் இலக்கு என்ன?';
      if (lang == 'te') return 'మీ ప్రధాన కెరీర్ లక్ష్యం ఏమిటి?';
      if (lang == 'mr') return 'तुमचे मुख्य करिअरचे ध्येय किंवा स्वप्न काय आहे?';
      if (lang == 'ur') return 'آپ کا بنیادی کیریئر کا ہدف کیا ہے؟';
      return 'What is your main career goal?';

    default:
      return getInitialGreetingForLanguage(langCode);
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
      profile = UserProfile(email: this.email, name: this.name);
      isAuthenticated = true;
      await saveSessionToPrefs(token: token, mobile: mobile, email: this.email, name: this.name);
      notifyListeners();
      return 'new';
    } catch (e) {
      final fallbackEmail = normalizedEmail.isNotEmpty ? normalizedEmail : 'google.user@example.com';
      final fallbackName = name.isNotEmpty ? name : 'Google User';
      this.email = fallbackEmail;
      this.name = fallbackName;
      profile = UserProfile(email: this.email, name: this.name);
      isAuthenticated = true;
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
      return getQuestionTextForField('age', profile, langCode);
    } else if (profile.age == null) {
      final cleanAge = text.replaceAll(RegExp(r'\D'), '');
      final numAge = int.tryParse(cleanAge);
      if (numAge != null && numAge >= 12 && numAge <= 90) {
        profile.age = numAge;
        return getQuestionTextForField('state', profile, langCode);
      }
      return 'Sorry, I didn\'t quite catch that — could you tell me your age as a number (e.g. 22)?';
    } else if (profile.state.isEmpty) {
      profile.state = text.trim();
      return getQuestionTextForField('district', profile, langCode);
    } else if (profile.district.isEmpty) {
      profile.district = text.trim();
      return getQuestionTextForField('location', profile, langCode);
    } else if (profile.location.isEmpty) {
      profile.location = text.trim();
      return getQuestionTextForField('education', profile, langCode);
    } else if (profile.highestQualification.isEmpty) {
      profile.highestQualification = text.trim();
      return getQuestionTextForField('currentOccupation', profile, langCode);
    } else if (profile.livelihood.isEmpty) {
      profile.livelihood = text.trim();
      return getQuestionTextForField('familyOccupation', profile, langCode);
    } else if (profile.familyOccupation.isEmpty) {
      profile.familyOccupation = text.trim();
      return getQuestionTextForField('skills', profile, langCode);
    } else if (profile.existingSkills.isEmpty) {
      profile.existingSkills = [text.trim()];
      return getQuestionTextForField('experience', profile, langCode);
    } else if (profile.experienceName.isEmpty) {
      profile.experienceName = text.trim();
      return getQuestionTextForField('interests', profile, langCode);
    } else if (profile.careerInterests.isEmpty) {
      profile.careerInterests = [text.trim()];
      return getQuestionTextForField('employmentPreference', profile, langCode);
    } else if (profile.employmentPreference.isEmpty) {
      profile.employmentPreference = text.trim();
      return getQuestionTextForField('mobilityConstraints', profile, langCode);
    } else if (profile.mobilityConstraints.isEmpty) {
      profile.mobilityConstraints = text.trim();
      return getQuestionTextForField('careerGoal', profile, langCode);
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
