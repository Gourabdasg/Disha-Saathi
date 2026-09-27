import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../models/app_models.dart';
import '../services/api_service.dart';
import '../services/firebase_auth_service.dart';
import '../utils/profanity_filter.dart';

/// Centralized 23-Language Initial Greetings Dictionary for DISHA-AI Chat
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

/// Centralized 23-Language Assessment Questions Dictionary for DISHA-AI Chat.
/// Covers all 13 assessment fields x 23 languages = 299 required translation entries.
final Map<String, Map<String, String>> _assessmentQuestionsDict = {
  'age': {
    'as': 'আপোনাক লগ পাই ভাল লাগিল, {name}! আপোনাৰ বয়স কিমান?',
    'bn': 'আপনার সাথে পরিচিত হয়ে আনন্দিত, {name}! আপনার বয়স কত?',
    'brx': 'नोंथांखौ सिनायनो हायोना गोजोननाय मोन्दों, {name}! नोंथांनि बैसोआ बेसेबां?',
    'doi': 'तुसें गी मिली ते खुशी होई, {name}! तुंदी उमर किन्नी ऐ?',
    'en': 'Nice to meet you, {name}! What is your age?',
    'gu': 'તમને મળીને આનંદ થયો, {name}! તમારી ઉંમર કેટલી છે?',
    'hi': 'आपसे मिलकर खुशी हुई, {name}! आपकी उम्र क्या है?',
    'kn': 'ನಿಮ್ಮನ್ನು ಭೇಟಿಯಾಗಿದ್ದು ಸಂತೋಷವಾಗಿದೆ, {name}! ನಿಮ್ಮ ವಯಸ್ಸು ಎಷ್ಟು?',
    'ks': 'تۆہیہِ سٟتؠ مِلِتھ گٔیی خوشی، {name}! تُہنز عُمَر کِتھ پٲٹھِ چھِ؟',
    'kok': 'तुमकां मेळून आनंद जालो, {name}! तुमचें पिराय कितलें?',
    'mai': 'अहाँ सँ मिलि कऽ प्रसन्नता भेल, {name}! अहाँक उमर कतेक अछि?',
    'ml': 'നിങ്ങളെ കണ്ടുമുട്ടിയതിൽ സന്തോഷം, {name}! നിങ്ങളുടെ വയസ്സ് എത്രയാണ്?',
    'mni': 'নহাকপু উন্নবা ফংজবদা নুংঙাইজরী, {name}! নহাকগী চহী কয়া শুরে?',
    'mr': 'तुम्हाला भेटून आनंद झाला, {name}! तुमचे वय काय आहे?',
    'ne': 'तपाईंलाई भेटेर खुसी लाग्यो, {name}! तपाईंको उमेर कति हो?',
    'or': 'ଆପଣଙ୍କୁ ଭେଟି ଆନନ୍ଦିତ ହେଲୁ, {name}! ଆପଣଙ୍କ ବୟସ କେତେ?',
    'pa': 'ਤੁਹਾਨੂੰ ਮਿਲ ਕੇ ਖੁਸ਼ੀ ਹੋਈ, {name}! ਤੁਹਾਡੀ ਉਮਰ ਕਿੰਨੀ ਹੈ?',
    'sa': 'भवता सह मिलित्वा प्रसन्नाः स्मः, {name}! भवतः आयुः किम् अति?',
    'sat': 'ᱟᱢ ᱥᱟᱶ ᱧᱟᱯᱟᱢ ᱠᱟᱛᱮ ᱨᱟᱹᱥᱠᱟᱹ ᱵᱩᱡᱷᱟᱹᱣᱮᱱᱟ, {name}! ᱟᱢᱟᱜ ᱩᱢᱮᱨ ᱛᱤᱱᱟᱹᱜ?',
    'sd': 'توهان سان ملڻ جي خوشي ٿي، {name}! توهان جي ਉمر ڪيتري آهي؟',
    'ta': 'உங்களை சந்தித்ததில் மகிழ்ச்சி, {name}! உங்கள் வயது என்ன?',
    'te': 'మిమ్మల్ని కలవడం సంతోషంగా ఉంది, {name}! మీ వయస్సు ఎంత?',
    'ur': 'آپ سے مل کر خوشی ہوئی، {name}! آپ کی عمر کیا ہے؟',
  },
  'state': {
    'as': 'আপুনি বৰ্তমান কোনখন ৰাজ্যৰ পৰা আহিছে?',
    'bn': 'আপনি বর্তমানে কোন রাজ্যে থাকেন?',
    'brx': 'नोंथाङा दाथायाव मा राइज्यनिफ्राय फैदों?',
    'doi': 'तुसें थमाह्-बेह् केहड़े राज्य थमां ओ?',
    'en': 'Which state are you currently from?',
    'gu': 'તમે હાલમાં કયા રાજ્યમાંથી છો?',
    'hi': 'आप वर्तमान में किस राज्य से हैं?',
    'kn': 'ನೀವು ಪ್ರಸ್ತುತ ಯಾವ ರಾಜ್ಯದವರು?',
    'ks': 'تۆہؠ کِس ریاستس منٛز چھِ روزان؟',
    'kok': 'तुम्ही सध्या खंयच्या राज्यांतले आहात?',
    'mai': 'अहाँ वर्तमान मे कोन् राज्य सँ छी?',
    'ml': 'നിങ്ങൾ നിലവിൽ ഏത് സംസ്ഥാനത്തു നിന്നുള്ളയാളാണ്?',
    'mni': 'নহাক হৌজিক কৱম্বা রাজ্যদগী লৈরিবনো?',
    'mr': 'तुम्ही सध्या कोणत्या राज्यातील आहात?',
    'ne': 'तपाईं हाल कुन राज्यबाट हुनुहुन्छ?',
    'or': 'ଆପଣ ବର୍ତ୍ତମାନ କେଉଁ ରାଜ୍ୟରୁ ଅଟନ୍ତି?',
    'pa': 'ਤੁਸੀਂ ਫਿਲਹਾਲ ਕਿਸ ਰਾਜ ਤੋਂ ਹੋ?',
    'sa': 'भवान् बर्तमाने कस्य राज्यस्य अस्ति?',
    'sat': 'ᱟᱢ ᱫᱚ ᱱᱤᱛᱚᱜ ᱠᱟᱹᱢᱤ ᱞᱟᱹᱜᱤᱫ ᱚᱠᱟ ᱯᱚᱱᱚᱛ ᱨᱮᱱ ᱠᱟᱱᱟᱢ?',
    'sd': 'توهان حال ۾ ڪهڙي رياست مان آهيو؟',
    'ta': 'நீங்கள் தற்போது எந்த மாநிலத்தைச் சேர்ந்தவர்?',
    'te': 'మీరు ప్రస్తుతం ఏ రాష్ట్రానికి చెందినవారు?',
    'ur': 'آپ فی الحال کس ریاست سے ہیں؟',
  },
  'district': {
    'as': 'আপোনাৰ জিলাৰ নাম কি?',
    'bn': 'আপনার জেলার নাম কী?',
    'brx': 'नोंथांनि জিলानि मुङा मा?',
    'doi': 'तुंदा ज़िला केहड़ा ऐ?',
    'en': 'Which district are you from?',
    'gu': 'તમારો જિલ્લો કયો છે?',
    'hi': 'आपका जिला कौन सा है?',
    'kn': 'ನಿಮ್ಮ ಜಿಲ್ಲೆ ಯಾವುದು?',
    'ks': 'تُہنٛد ضِلعہٕ کُس چھُ؟',
    'kok': 'तुमचो जिल्लो खंयचो?',
    'mai': 'अहाँक जिला कोन थिक?',
    'ml': 'നിങ്ങളുടെ ജില്ല ഏതാണ്?',
    'mni': 'নহাকগী জিলা কৱম্বনো?',
    'mr': 'तुमचा जिल्हा कोणता आहे?',
    'ne': 'तपाईंको जिल्ला कुन हो?',
    'or': 'ଆପଣଙ୍କ ଜିଲ୍ଲାର ନାମ କ’ଣ?',
    'pa': 'ਤੁਹਾਡਾ ਜ਼ਿਲ੍ਹਾ ਕਿਹੜਾ ਹੈ?',
    'sa': 'भवतः जनपद् कः अस्ति?',
    'sat': 'ᱟᱢᱟᱜ ᱡᱤᱞᱟᱹ ᱚᱠᱟᱴᱟᱜ ᱠᱟᱱᱟ?',
    'sd': 'توهان جو ضلعو ڪهڙو آهي؟',
    'ta': 'உங்கள் மாவட்டம் எது?',
    'te': 'మీ జిల్లా ఏది?',
    'ur': 'آپ کا ضلع کون سا ہے؟',
  },
  'location': {
    'as': 'আপোনাৰ বৰ্তমান স্থান বা চহৰৰ নাম কি?',
    'bn': 'আপনার বর্তমান অবস্থান বা শহরের নাম কী?',
    'brx': 'नोंथांनि दाथायनि जायगा (सहर/गामि) मा?',
    'doi': 'तुंदा हुन्नड़ दा ठौर (शहर/गिरां) केहड़ा ऐ?',
    'en': 'What is your current location (city/town/village)?',
    'gu': 'તમારું વર્તમાન સ્થાન (શહેર/ગામ) કયું છે?',
    'hi': 'आपका वर्तमान स्थान (शहर/गांव) क्या है?',
    'kn': 'ನಿಮ್ಮ ಪ್ರಸ್ತುತ ಸ್ಥಳ (ನಗರ/ಗ್ರಾಮ) ಯಾವುದು?',
    'ks': 'تُہنٛد ییٚتِک ځای (شہر/گام) کُس چھُ؟',
    'kok': 'तुमचें सध्याचें ठिकाण (शहर/गांव) खंयचें?',
    'mai': 'अहाँक वर्तमान स्थान (शहर/गाम) की थिक?',
    'ml': 'നിങ്ങളുടെ നിലവിലെ സ്ഥലം (നഗരം/ഗ്രാമം) ഏതാണ്?',
    'mni': 'নহাকগী হৌজিক লৈরিবা মফম (সহর/খুঙ্গং) কাঈদনো?',
    'mr': 'तुमचे सध्याचे स्थान (शहर/गाव) कोणते आहे?',
    'ne': 'तपाईंको हालको स्थान (शहर/गाउँ) कुन हो?',
    'or': 'ଆପଣଙ୍କ ବର୍ତ୍ତମାନର ସ୍ଥାନ (ସହର/ଗ୍ରାମ) କ’ଣ?',
    'pa': 'ਤੁਹਾਡਾ ਮੌਜੂਦਾ ਸਥਾਨ (ਸ਼ਹਿਰ/ਪਿੰਡ) ਕੀ ਹੈ?',
    'sa': 'भवतः वर्तमानस्थानम् (नगरम्/ग्रामः) किम्?',
    'sat': 'ᱟᱢᱟᱜ ᱱᱤᱛᱚᱜᱟᱜ ᱴᱷᱟᱶ (ᱵᱟᱡᱟᱨ/ᱟᱛᱳ) ᱪᱮᱫ ᱠᱟᱱᱟ?',
    'sd': 'توهان جو موجوده هنڌ (شهر/ڳوٺ) ڪهڙو آهي؟',
    'ta': 'உங்கள் தற்போதைய இருப்பிடம் (நகரம்/கிராமம்) எது?',
    'te': 'మీ ప్రస్తుత ప్రాంతం (నగరం/గ్రామం) ఏది?',
    'ur': 'آپ کا موجودہ مقام (شہر/گاؤں) کیا ہے؟',
  },
  'education': {
    'as': 'আপোনাৰ সৰ্বোচ্চ বা বৰ্তমান শিক্ষাগত অর্হতা কি?',
    'bn': 'আপনার সর্বোচ্চ বা বর্তমান শিক্ষাগত যোগ্যতা কী?',
    'brx': 'नोंथांनि गोजौसिन बा दाथायनि सोलोंथाइ मा?',
    'doi': 'तुंदी सबनूं बड्डी या हुन्नड़ दी पढ़ाई किन्नी ऐ?',
    'en': 'What is your highest or current level of education?',
    'gu': 'તમારું સર્વોચ્ચ અથવા વર્તમાન શિક્ષણ સ્તર કયું છે?',
    'hi': 'आपकी उच्चतम या वर्तमान शैक्षणिक योग्यता क्या है?',
    'kn': 'ನಿಮ್ಮ ಅತ್ಯುನ್ನತ ಅಥವಾ ಪ್ರಸ್ತುತ ಶಿಕ್ಷಣದ ಮಟ್ಟ ಯಾವುದು?',
    'ks': 'تُہنٛز اعلیٰ یا ییٚتِچ تٲلیم کِتھ پٲٹھِ چھِ؟',
    'kok': 'तुमची सर्वोच्च वा सध्याची शिकवण कितली?',
    'mai': 'अहाँक उच्चतम वा वर्तमान शैक्षणिक योग्यता की थिक?',
    'ml': 'നിങ്ങളുടെ ഏറ്റവും ഉയർന്ന അല്ലെങ്കിൽ നിലവിലെ വിദ്യാഭ്യാസ യോഗ്യത എന്താണ്?',
    'mni': 'নহাকগী খ্বাইদগী ৱাংবা মহৈ-মশিংগী থাক কাঈদনো?',
    'mr': 'तुमची सर्वोच्च किंवा सध्याची शैक्षणिक पात्रता कोणती आहे?',
    'ne': 'तपाईंको उच्च वा हालको शिक्षाको स्तर के हो?',
    'or': 'ଆପଣଙ୍କର ସର୍ବୋଚ୍ଚ କିମ୍ବା ବର୍ତ୍ତମାନର ଶିକ୍ଷାଗତ ଯୋଗ୍ୟତା କ’ଣ?',
    'pa': 'ਤੁਹਾਡੀ ਉੱਚਤਮ ਜਾਂ ਮੌਜੂਦਾ ਵਿਦਿਅਕ ਯੋਗਤਾ ਕੀ ਹੈ?',
    'sa': 'भवतः उच्चतमम् अथवा वर्तमानं शिक्षणस्तरं किम्?',
    'sat': 'ᱟᱢᱟᱜ ᱡᱚᱛᱚ ᱠᱷᱚᱱ ᱪᱮᱛᱟᱱ ᱥᱮᱪᱮᱫ ᱫᱚ ᱪᱮᱫ ᱠᱟᱱᱟ?',
    'sd': 'توهان جي سڀ کان مٿاهين يا موجوده تعليم ڪهڙي آهي؟',
    'ta': 'உங்கள் மிக உயர்ந்த அல்லது தற்போதைய கல்வித் தகுதி என்ன?',
    'te': 'మీ అత్యున్నత లేదా ప్రస్తుత విద్యార్హత ఏమిటి?',
    'ur': 'آپ کی اعلی ترین یا موجودہ تعلیمی قابلیت کیا ہے؟',
  },
  'currentOccupation': {
    'as': 'আপুনি বৰ্তমান কি বৃত্তি বা কামৰ সৈতে জড়িত?',
    'bn': 'আপনি বর্তমানে কী পেশা বা কাজের সাথে যুক্ত?',
    'brx': 'नोंथाङा दाथायनि समाव मा हाबा बा जिउ बिखानि हाबा मावदों?',
    'doi': 'तुसें हुन्नड़ केहड़ा काम या रोज़गार करदे ओ?',
    'en': 'What is your current occupation or livelihood work?',
    'gu': 'તમારો વર્તમાન વ્યવસાય અથવા આજીવિકાનું કામ શું છે?',
    'hi': 'आपका वर्तमान व्यवसाय या आजीविका का कार्य क्या है?',
    'kn': 'ನಿಮ್ಮ ಪ್ರಸ್ತುತ ವೃತ್ತಿ ಅಥವಾ ಜೀವನೋಪಾಯದ ಕೆಲಸ ಯಾವುದು?',
    'ks': 'تۆہؠ کُس کام یا روزگار چھِ کران؟',
    'kok': 'तुमचो सध्याचो वेवसाय वा कामाचो प्रकार खंयचो?',
    'mai': 'अहाँक वर्तमान व्यवसाय वा आजीविकाक काज की थिक?',
    'ml': 'നിങ്ങളുടെ നിലവിലെ തൊഴിൽ അല്ലെങ്കിൽ ഉപജീവന ജോലി എന്താണ്?',
    'mni': 'নহাক হージュিক কৱম্বা থবক বা ইন্নফি থবক তৌরিগে?',
    'mr': 'तुमचा सध्याचा व्यवसाय किंवा उपजीविकेचे काम काय आहे?',
    'ne': 'तपाईंको हालको पेशा वा आजीविकाको काम के हो?',
    'or': 'ଆପଣଙ୍କ ବର୍ତ୍ତମାନର ବୃତ୍ତି କିମ୍ବା ଜୀବିକା କ’ଣ?',
    'pa': 'ਤੁਹਾਡਾ ਮੌਜੂਦਾ ਕਿੱਤਾ ਜਾਂ ਕੰਮ ਕੀ ਹੈ?',
    'sa': 'भवतः वर्तमानव्यवसायः अथवा उपजीविका कार्यं किम्?',
    'sat': 'ᱟᱢ ᱫᱚ ᱱᱤᱛᱚᱜ ᱪᱮᱫ ᱠᱟᱹᱢᱤ ᱥᱟᱶ ᱡᱚᱲᱟᱣ ᱢᱮᱱᱟᱢᱟ?',
    'sd': 'توهان جو موجوده روزگار يا ڪم ڪهڙو آهي؟',
    'ta': 'உங்கள் தற்போதைய தொழில் அல்லது வாழ்வாதார வேலை என்ன?',
    'te': 'మీ ప్రస్తుత వృత్తి లేదా పని ఏమిటి?',
    'ur': 'آپ کا موجودہ پیشہ یا کام کیا ہے؟',
  },
  'familyOccupation': {
    'as': 'আপোনাৰ পৰিয়ালৰ মূল বৃত্তি বা কাম কি?',
    'bn': 'আপনার পরিবারের মূল পেশা বা কাজ কী?',
    'brx': 'नोंथांनि नखरनि गुबै हाबाया मा?',
    'doi': 'तुंदे टब्बर दा मुख्य काम केहड़ा ऐ?',
    'en': 'What is your family\'s primary occupation?',
    'gu': 'તમારા પરિવારનો મુખ્ય વ્યવસાય શું છે?',
    'hi': 'आपके परिवार का मुख्य व्यवसाय या कार्य क्या है?',
    'kn': 'ನಿಮ್ಮ ಕುಟುಂಬದ ಮುಖ್ಯ ವೃತ್ತಿ ಯಾವುದು?',
    'ks': 'تُہنٛدِ گَرِیوَن کُس اَہَم کام چھِ کران؟',
    'kok': 'तुमच्या कुटुंबाचो मुखेल वेवसाय खंयचो?',
    'mai': 'अहाँक परिवारक मुख्य व्यवसाय की थिक?',
    'ml': 'നിങ്ങളുടെ കുടുംബത്തിന്റെ പ്രധാന തൊഴിൽ എന്താണ്?',
    'mni': 'নহাকগী ইমুংগী মরুওইবা থবক কাঈদনো?',
    'mr': 'तुमच्या कुटुंबाचा मुख्य व्यवसाय कोणता आहे?',
    'ne': 'तपाईंको परिवारको मुख्य पेशा के हो?',
    'or': 'ଆପଣଙ୍କ ପରିବାରର ମୁଖ୍ୟ ବୃତ୍ତି କ’ଣ?',
    'pa': 'ਤੁਹਾਡੇ ਪਰਿਵਾਰ ਦਾ ਮੁੱਖ ਕਿੱਤਾ ਕੀ ਹੈ?',
    'sa': 'भवतः कुटुंबस्य मुख्यव्यवसायः कः?',
    'sat': 'ᱟᱢᱟᱜ ᱜᱷᱟᱨᱚᱸᱡᱽ ᱨᱮᱱᱟᱜ ᱢᱩᱬᱩᱛ ᱠᱟᱹᱢᱤ ᱫᱚ ᱪᱮᱫ ᱠᱟᱱᱟ?',
    'sd': 'توهان جي خاندان جو اصلي ڪم ڪهڙو آهي؟',
    'ta': 'உங்கள் குடும்பத்தின் முக்கிய தொழில் என்ன?',
    'te': 'మీ కుటుంబ ప్రధాన వృత్తి ఏమిటి?',
    'ur': 'آپ کے خاندان کا بنیادی پیشہ کیا ہے؟',
  },
  'skills': {
    'as': 'আপোনাৰ ঘাই কামৰ দক্ষতা বা অভিজ্ঞতাসমূহ কি কি?',
    'bn': 'আপনার প্রধান দক্ষতা বা কাজ করার অভিজ্ঞতা কী কী?',
    'brx': 'नोंथांनाव मा मा हाबानि सोलोंथाइ/गोनोथो दं?',
    'doi': 'तुंदे कोल केहड़े-केहड़े कामे दे हुनर हिन?',
    'en': 'What are your main work skills?',
    'gu': 'તમારા મુખ્ય કાર્ય કૌશલ્યો કયા છે?',
    'hi': 'आपके पास मुख्य काम के कौशल (Skills) क्या हैं?',
    'kn': 'ನಿಮ್ಮ ಮುಖ್ಯ ಕೆಲಸದ ಕೌಶಲ್ಯಗಳು ಯಾವುವು?',
    'ks': 'تُہنٛدین کشرن/ہُنرن ہُنٛد ناں کیاہ چھُ؟',
    'kok': 'तुमचे कडेन कसले मुखेल कौशल्य आसा?',
    'mai': 'अहाँक मुख्य कार्य कौशल की थिक?',
    'ml': 'നിങ്ങളുടെ പ്രധാന തൊഴിൽ കഴിവുകൾ ഏതെല്ലാമാണ്?',
    'mni': 'নহাকগী মরুওইবা হেংশিংবা থবকশিং কাঈদনো?',
    'mr': 'तुमचे मुख्य कामाचे कौशल्य (Skills) कोणते आहे?',
    'ne': 'तपाईंको मुख्य सीपहरू के-के हुन्?',
    'or': 'ଆପଣଙ୍କର ମୁଖ୍ୟ କାର୍ଯ୍ୟ ଦକ୍ଷତା କ’ଣ?',
    'pa': 'ਤੁਹਾਡੇ ਕੋਲ ਮੁੱਖ ਕੰਮ ਦੇ ਹੁਨਰ ਕੀ ਹਨ?',
    'sa': 'भवतः प्रमुखाणि कार्यकौशलानि कानि सन्ति?',
    'sat': 'ᱟᱢ ᱴᱷᱮᱱ ᱪᱮᱫ ᱪᱮᱫ ᱦᱩᱱᱟᱹᱨ (Skills) ᱢᱮᱱᱟᱜᱼᱟ?',
    'sd': 'توهان وٽ ڪهڙيون برتريون مهارتون آهن؟',
    'ta': 'உங்கள் முக்கிய வேலைத் திறன்கள் என்ன?',
    'te': 'మీ ముఖ్యమైన పని నైపుణ్యాలు ఏమిటి?',
    'ur': 'آپ کے پاس کون سی اہم کام کی مہارتیں ہیں؟',
  },
  'experience': {
    'as': 'আপোনাৰ পূৰ্বৰ কিবা কাম বা অভিজ্ঞতা আছে নেকি?',
    'bn': 'আপনার কি পূর্বে কোনো কাজের বা শিক্ষানবিশির অভিজ্ঞতা আছে?',
    'brx': 'नोंथांनाव सिगांनि मावनाय हाबानि रोंगौथि दं नामा?',
    'doi': 'केह् तुसें गी पैह्ले दा कोई कामे दा तजरबा ऐ?',
    'en': 'Do you have any previous work or internship experience?',
    'gu': 'શું તમારી પાસે કોઈ અગાઉનો કામનો અનુભવ છે?',
    'hi': 'क्या आपके पास कोई पिछला काम या इंटर्नशिप का अनुभव है?',
    'kn': 'ನಿಮಗೆ ಯಾವುದೇ পূর্ব ಕೆಲಸದ ಅನುಭವವಿದೆಯೇ?',
    'ks': 'تۆہؠ چھِیاٚ کَنہِ کاشرِ پَتِم تجرُبہٕ؟',
    'kok': 'तुमकां पयलींचो कसलोय कामाचो अणभव आसा?',
    'mai': 'की अहाँक कोनो पूर्व काजक अनुभव अछि?',
    'ml': 'നിങ്ങൾക്ക് മുൻപരിചയം വല്ലതും ഉണ്ടോ?',
    'mni': 'নহাকগী হান্নগী থবক তৌরমবগী ৱারী লৈব্রা?',
    'mr': 'तुम्हाला पूर्वीचा कामाचा किंवा इंटर्नशिपचा अनुभव आहे का?',
    'ne': 'के तपाईंको पहिलेको कुनै कामको अनुभव छ?',
    'or': 'ଆପଣଙ୍କର କୌଣସି ପୂର୍ବ କାର୍ଯ୍ୟ ଅଭିଜ୍ଞତା ଅଛି କି?',
    'pa': 'ਕੀ ਤੁਹਾਡੇ ਕੋਲ ਪਿਛਲੇ ਕੰਮ ਦਾ ਕੋਈ ਤਜਰਬਾ ਹੈ?',
    'sa': 'किं भवतः कश्चन पूर्वकार्यस्य अनुभवः अस्ति?',
    'sat': 'ᱟᱢᱟᱜ ᱪᱮᱫ ᱞᱟᱦᱟ ᱠᱟᱹᱢᱤ ᱨᱮᱱᱟᱜ ᱮᱠᱥᱯᱮᱨᱤᱭᱮᱱᱥ ᱢᱮᱱᱟᱜᱼᱟ?',
    'sd': 'ڇا توهان وٽ اڳوڻي ڪم جو تجربو آهي؟',
    'ta': 'உங்களுக்கு முன் வேலை அனுபவம் ஏதேனும் உள்ளதா?',
    'te': 'మీకు గతంలో పని చేసిన అనుభవం ఉందా?',
    'ur': 'کیا آپ کے پاس کام کا کوئی سابقہ تجربہ ہے؟',
  },
  'interests': {
    'as': 'আপোনাৰ কেৰিয়াৰৰ প্ৰধান পচন্দ বা আগ্ৰহৰ ক্ষেত্ৰ কি?',
    'bn': 'আপনার ক্যারিয়ারের মূল পছন্দের বা আগ্রহের ক্ষেত্র কী?',
    'brx': 'नोंथांनि करियारनि गुबै गोसो गुदुं जायगाया मा?',
    'doi': 'तुंदे करियार दी पसंद दी जगह केहड़ी ऐ?',
    'en': 'What are your main career interests?',
    'gu': 'તમારા મુખ્ય કારકિર્દીના રસના ક્ષેત્રો કયા છે?',
    'hi': 'आपके करियर की मुख्य रुचि के क्षेत्र क्या हैं?',
    'kn': 'ನಿಮ್ಮ ಪ್ರಮುಖ ವೃತ್ತಿಪರ ಆಸಕ್ತಿಗಳು ಯಾವುವು?',
    'ks': 'تُہنٛزین کیریئر شوقن ہُنٛد ناں کیاہ چھُ؟',
    'kok': 'तुमचे करीअराचे मुखेल आवडीचे विशय कसले?',
    'mai': 'अहाँक करियरक मुख्य रुचि कोन क्षेत्र मे अछि?',
    'ml': 'നിങ്ങളുടെ പ്രധാന കരിയർ താൽപ്പര്യങ്ങൾ ഏതെല്ലാമാണ്?',
    'mni': 'নহাকগী ক্যারেরগী থৌদাং কৱম্বা অপাম্বা লৈরিগে?',
    'mr': 'तुमच्या करिअरच्या आवडीचे मुख्य क्षेत्र कोणते आहे?',
    'ne': 'तपाईंको मुख्य करियर रुचिहरू के हुन्?',
    'or': 'ଆପଣଙ୍କର ମୁଖ୍ୟ କ୍ୟାରିଅର୍ ଆଗ୍ରହ କ’ଣ?',
    'pa': 'ਤੁਹਾਡੀਆਂ ਮੁੱਖ ਕਰੀਅਰ ਰੁਚੀਆਂ ਕੀ ਹਨ?',
    'sa': 'भवतः आजीविकायाः मुख्यानुरागाः के सन्ति?',
    'sat': 'ᱟᱢᱟᱜ ᱢᱩᱬᱩᱛ ᱠᱟᱹᱢᱤ ᱟᱥᱟ ᱫᱚ ᱪᱮᱫ ᱠᱟᱱᱟ?',
    'sd': 'توهان جا اصلي ڪيريئر جا شوق ڪهڙا آهن؟',
    'ta': 'உங்கள் முக்கிய தொழில் ஆர்வங்கள் என்ன?',
    'te': 'మీ ప్రధాన కెరీర్ ఆసక్తులు ఏమిటి?',
    'ur': 'آپ کی اہم کیریئر کی دلچسپیاں کیا ہیں؟',
  },
  'employmentPreference': {
    'as': 'আপুনি কেনেকুৱা ধৰণৰ সংস্থাপন পচন্দ কৰে (ফুল-টাইম, স্ব-নিয়োজিত ইত্যাদি)?',
    'bn': 'আপনি কী ধরনের চাকরি পছন্দ করেন (ফুল-টাইম, খণ্ডকালীন, স্বনির্ভর বা সরকারি)?',
    'brx': 'नोंथाङा माबादि हाबा हास्थायो (फुल्-ताइम, गाव-हाबा)?',
    'doi': 'तुसें केहड़े चाल्ली दा काम चाहंदे ओ (फुल-टाइम, खुद दा)?',
    'en': 'What type of employment are you looking for (full-time, part-time, self-employed)?',
    'gu': 'તમે કયા પ્રકારની રોજગારી પસંદ કરો છો (ફુલ-ટાઇમ, સ્વ-રોજગાર)?',
    'hi': 'आप किस प्रकार का रोजगार चाहते हैं (जैसे फुल-टाइम, पार्ट-टाइम, स्वरोजगार)?',
    'kn': 'ನೀವು ಯಾವ ರೀತಿಯ ಉದ್ಯೋಗವನ್ನು ಬಯಸುತ್ತೀರಿ (ಫುಲ್-ಟೈಮ್, ಸ್ವಯಂ ಉದ್ಯೋಗ)?',
    'ks': 'تۆہؠ کِس قِسمُک روزگار چھِ یَچھان (فُل ٹائِم، پانۄن)؟',
    'kok': 'तुमकां कसल्या प्रकारचो रोजगार जाय (फुल-टायम, स्व-रोजगार)?',
    'mai': 'अहाँ कोन प्रकारक रोजगार चाहैत छी (फुल-टाइम, स्वरोजगार)?',
    'ml': 'ഏതുതരം തൊഴിലാണ് നിങ്ങൾ ആഗ്രഹിക്കുന്നത് (ഫുൾ-ടൈം, സ്വയം തൊഴിൽ)?',
    'mni': 'নহাক কৱম্বা থবক অমসুং ইন্নফি পাম্বগে (ফুল-টাইম, মশাগী থবক)?',
    'mr': 'तुम्हाला कोणत्या प्रकारचा रोजगार हवा आहे (उदा. फुल-टाइम, स्वयंरोजगार)?',
    'ne': 'तपाईं कस्तो प्रकारको रोजगार चाहनुहुन्छ (फुल-टाइम, स्वरोजगार)?',
    'or': 'ଆପଣ କେଉଁ ପ୍ରକାରର ରୋଜଗାର ଚାହାଁନ୍ତି (ଫୁଲ୍-ଟାଇମ୍, ସ୍ୱ-ରୋଜଗାର)?',
    'pa': 'ਤੁਸੀਂ ਕਿਸ ਤਰ੍ਹਾਂ ਦਾ ਰੁਜ਼ਗਾਰ ਚਾਹੁੰਦੇ ਹੋ (ਜਿਵੇਂ ਫੁੱਲ-ਟਾਈਮ, ਸਵੈ-ਰੁਜ਼ਗਾਰ)?',
    'sa': 'भवान् कीदृशं रोजगारम् इच्छति (पूर्णकालिकम्, स्वरोजगारम्)?',
    'sat': 'ᱟᱢ ᱫᱚ ᱪᱮᱫ ᱞᱮᱠᱟᱱ ᱠᱟᱹᱢᱤ ᱟᱥᱟᱭᱮᱫᱟᱢ (Full-time, ᱱᱤᱡᱮᱨᱟᱜ)?',
    'sd': 'توهان ڪهڙي قسم جو روزگار چاهيو ٿا (فل ٽائيم، پنهنجو ڪم)؟',
    'ta': 'நீங்கள் எந்த வகையான வேலையை எதிர்பார்க்கிறீர்கள் (முழுநேரம், சுயதொழில்)?',
    'te': 'మీరు ఎలాంటి ఉద్యోగాన్ని కోరుకుంటున్నారు (ఫుల్ టైమ్, స్వయం ఉపాధి)?',
    'ur': 'آپ کس قسم کا روزگار چاہتے ہیں (مثلاً فل ٹائم، اپنا کاروبار)؟',
  },
  'mobilityConstraints': {
    'as': 'আপোনাৰ স্থানান্তৰ বা ভ্ৰমণৰ কিবা সীমাবদ্ধতা আছে নেকি?',
    'bn': 'আপনার অন্য স্থান বা জেলায় স্থানান্তরিত হওয়ার কোনো সীমাবদ্ধতা আছে?',
    'brx': 'नोंथांनाव गुबुन जायगायाव थांनो बा हाबा माव्नो हाबायाव हेंथा दं नामा?',
    'doi': 'केह् तुसें गी बाहर जाई ते काम करने च कोई रुकावट ऐ?',
    'en': 'Do you have any mobility constraints or relocation limits?',
    'gu': 'શું તમારી પાસે સ્થાનાંતરણ (Relocation) માટે કોઈ મર્યાદા છે?',
    'hi': 'क्या आपके पास कोई स्थान परिवर्तन (Relocation) या आने-जाने की सीमा है?',
    'kn': 'ನಿಮಗೆ ಸ್ಥಳಾಂತರಗೊಳ್ಳಲು ಯಾವುದೇ ಮಿತಿಗಳಿವೆಯೇ?',
    'ks': 'تۆہؠ چھِیاٚ بیٚیِس جایِس گَژھنَس منٛز کاںہہ رُکاوَٹ؟',
    'kok': 'तुमकां दुसऱ्या सुवातेर वचून काम करपाक कांय आडखळ आसा?',
    'mai': 'की अहाँक आन ठाम जाय मे कोनो बाधा अछि?',
    'ml': 'മറ്റൊരു സ്ഥലത്തേക്ക് മാറുന്നതിന് നിങ്ങൾക്ക് വല്ല തടസ്സവുമുണ്ടോ?',
    'mni': 'নহাক অতোপ্পা মফমদা চৎতুনা থবক তৌবদা অপনব লৈব্রা?',
    'mr': 'तुम्हाला इतर ठिकाणी स्थलांतरित होण्यासाठी काही मर्यादा आहेत का?',
    'ne': 'के तपाईंलाई अर्को ठाउँमा सारेर काम गर्न कुनै सीमा छ?',
    'or': 'ଆପଣଙ୍କର ଅନ୍ୟ ସ୍ଥାନକୁ ଯିବାରେ କୌଣସି ପ୍ରତିବନ୍ଧକ ଅଛି କି?',
    'pa': 'ਕੀ ਤੁਹਾਡੇ ਕੋਲ ਹੋਰ ਥਾਂ ਜਾਣ ਵਿੱਚ ਕੋਈ ਰੁਕਾਵਟ ਜਾਂ ਸੀਮਾ ਹੈ?',
    'sa': 'किं भवतः अन्यात्र गमने काचित् सीमा अस्ति?',
    'sat': 'ᱟᱢ ᱫᱚ ᱮᱴᱟᱜ ᱴᱷᱟᱶ ᱪᱟᱞᱟᱣ ᱠᱟᱛᱮ ᱠᱟᱹᱢᱤ ᱨᱮ ᱪᱮᱫ ᱮᱴᱠᱮᱴᱚṬᱮ ᱢᱮᱱᱟᱜᱼᱟ?',
    'sd': 'ڇا توهان کي ٻئي هنڌ منتقل ٿيڻ ۾ ڪا رڪاوٽ آهي؟',
    'ta': 'வேறு இடத்திற்குச் சென்று வேலை செய்ய உங்களுக்கு ஏதேனும் தடைகள் உள்ளதா?',
    'te': 'మీకు వేరే ప్రాంతానికి వెళ్లి పని చేయడానికి ఏమైనా పరిమితులు ఉన్నాయా?',
    'ur': 'کیا آپ کو کسی دوسرے مقام پر منتقل ہونے میں کوئی رکاوٹ ہے؟',
  },
  'careerGoal': {
    'as': 'আপোনাৰ কেৰিয়াৰৰ প্ৰধান লক্ষ্য বা সপোন কি?',
    'bn': 'আপনার ক্যারিয়ারের প্রধান লক্ষ্য বা স্বপ্ন কী?',
    'brx': 'नोंथांनि करियारनि गुबै थांखिया मा?',
    'doi': 'तुंदा करियार दा मुख्य सपना केहड़ा ऐ?',
    'en': 'What is your main career goal?',
    'gu': 'તમારું મુખ્ય કારકિર્દીનું લક્ષ્ય શું છે?',
    'hi': 'आपका मुख्य करियर का लक्ष्य या सपना क्या है?',
    'kn': 'ನಿಮ್ಮ ಮುಖ್ಯ ವೃತ್ತಿಜೀವನದ ಗುರಿ ಏನು?',
    'ks': 'تُہنٛد اَہَم کیریئر لَچھ کیاہ چھُ؟',
    'kok': 'तुमचें करीअराचें मुखेल ध्येय कसले?',
    'mai': 'अहाँक मुख्य करियरक लक्ष्य की थिक?',
    'ml': 'നിങ്ങളുടെ പ്രധാന കരിയർ ലക്ഷ്യം എന്താണ്?',
    'mni': 'নহাকগী ক্যারেরগী মরুওইবা পান্দম কাঈদনো?',
    'mr': 'तुमचे मुख्य करिअरचे ध्येय किंवा स्वप्न काय आहे?',
    'ne': 'तपाईंको मुख्य करियरको लक्ष्य के हो?',
    'or': 'ଆପଣଙ୍କର ମୁଖ୍ୟ କ୍ୟାରିଅର୍ ଲକ୍ଷ୍ୟ କ’ଣ?',
    'pa': 'ਤੁਹਾਡਾ ਮੁੱਖ ਕਰੀਅਰ ਦਾ ਟੀਚਾ ਕੀ ਹੈ?',
    'sa': 'भवतः मुख्यम् आजीविकालक्ष्यं किम् अस्ति?',
    'sat': 'ᱟᱢᱟᱜ ᱢᱩᱬᱩᱛ ᱠᱟᱹᱢᱤ ᱡᱚᱥ ᱫᱚ ᱪᱮᱫ ᱠᱟᱱᱟ?',
    'sd': 'توهان جو اصلي ڪيريئر جو مقصد ڪهڙو آهي؟',
    'ta': 'உங்கள் முக்கிய தொழில் இலக்கு என்ன?',
    'te': 'మీ ప్రధాన కెరీర్ లక్ష్యం ఏమిటి?',
    'ur': 'آپ کا بنیادی کیریئر کا ہدف کیا ہے؟',
  },
};

/// Returns localized assessment question for [fieldKey] in [langCode], guaranteed across all 23 languages.
String getQuestionTextForField(String fieldKey, UserProfile profile, String langCode) {
  final lang = langCode.toLowerCase().trim();
  final displayName = profile.name.isNotEmpty ? profile.name : 'Beneficiary';

  final fieldMap = _assessmentQuestionsDict[fieldKey];
  if (fieldMap != null) {
    String? rawQuestion = fieldMap[lang] ?? fieldMap['en'];
    if (rawQuestion != null) {
      return rawQuestion.replaceAll('{name}', displayName);
    }
  }

  return getInitialGreetingForLanguage(langCode);
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

    // Reusable Moderation Layer: Profanity & Foul-Language Filter
    if (ProfanityFilter.hasProfanity(text)) {
      final warningMsg = tr('profanity_warning');
      chatMessages.add(ChatMessage(warningMsg, true));
      notifyListeners();
      return; // Do NOT call AI backend or process original abusive question!
    }

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

      // Update local state immediately for instant UI refresh
      profile = updatedProfile;
      if (updatedProfile.name.isNotEmpty) name = updatedProfile.name;
      if (updatedProfile.email.isNotEmpty) email = updatedProfile.email;
      if (updatedProfile.mobile.isNotEmpty) mobile = updatedProfile.mobile;

      await saveSessionToPrefs(mobile: profile.mobile, email: profile.email, name: profile.name);

      // Save to backend & PostgreSQL asynchronously
      try {
        final saved = await ApiService.saveProfile(updatedProfile);
        profile = saved;
      } catch (e) {
        print('[updateUserProfile Backend Warning]: $e');
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      profile = updatedProfile;
      isLoading = false;
      notifyListeners();
      return true;
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
