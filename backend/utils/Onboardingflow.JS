/**
 * onboardingFlow.js — Disha Saathi AI Onboarding & Conversation Flow
 * SIH 2026 · PS 26097 · Team: The AI Alchemists
 *
 * Supports native conversational assessment in all 22 Eighth Schedule Indian languages + English.
 */

const { parseNaturalLanguage } = require('./nlpEngine');
const nsqfDataset = require('../data/NSQF_Training_Recommendation');

// ---------------------------------------------------------------------------
// 1. Field definitions (canonical 14-step order)
// ---------------------------------------------------------------------------
const FIELD_ORDER = [
  { key: 'name', label: 'Name', question: () => `Hello! 👋 Welcome to Disha Saathi. May I know your name?` },
  { key: 'age', label: 'Age', question: (p) => p.name ? `Nice to meet you, ${p.name}! What is your age?` : `What is your age?` },
  { key: 'state', label: 'State', question: () => `Which state are you currently from?` },
  { key: 'district', label: 'District', question: () => `Which district are you from?` },
  { key: 'location', label: 'Location', question: () => `What is your current location (city/town/village)?` },
  { key: 'education', label: 'Education', question: () => `What is your highest or current level of education?` },
  { key: 'currentOccupation', label: 'Current Occupation', question: () => `What is your current occupation or livelihood work?` },
  { key: 'familyOccupation', label: 'Family Occupation', question: () => `What is your family's occupation?` },
  { key: 'skills', label: 'Skills', question: () => `What are your main work skills?` },
  { key: 'experience', label: 'Experience', question: () => `Do you have any previous work or internship experience?` },
  { key: 'interests', label: 'Interests', question: () => `What are your main career interests?` },
  { key: 'employmentPreference', label: 'Employment Preference', question: () => `What type of employment are you looking for (e.g. full-time, part-time, self-employed, government job)?` },
  { key: 'mobilityConstraints', label: 'Mobility Constraints', question: () => `Do you have any mobility constraints or relocation limits?` },
  { key: 'careerGoal', label: 'Career Goal', question: () => `What is your main career goal?` },
];

const FIELD_KEYS = FIELD_ORDER.map((f) => f.key);

// ---------------------------------------------------------------------------
// 2. Multilingual Assessment Questions Dictionary for All 22 Indian Languages + English
// ---------------------------------------------------------------------------
const MULTILINGUAL_QUESTIONS = {
  name: {
    as: () => `নমস্কাৰ! 👋 দিশা সাথীলৈ স্বাগতম। আপোনাৰ নামটো জানিব পাৰোঁনে?`,
    bn: () => `নমস্কার! 👋 দিশা সাথীতে আপনাকে স্বাগতম। আপনার নাম জানতে পারি?`,
    brx: () => `खुलुमबाय! 👋 दिशा साथियांव नोंथांखौ सिनायनो हायोगोना?`,
    doi: () => `नमस्ते! 👋 दिशा साथी च तुंदा स्वागत ऐ। तुंदा नां केह ऐ?`,
    en: () => `Hello! 👋 Welcome to Disha Saathi. May I know your name?`,
    gu: () => `નમસ્તે! 👋 દિશા સાથીમાં આપનું સ્વાગત છે. શું હું તમારું નામ જાણી શકું?`,
    hi: () => `नमस्ते! 👋 दिशा साथी में आपका स्वागत है। क्या मैं आपका नाम जान सकता हूँ?`,
    kn: () => `ನಮಸ್ಕಾರ! 👋 ದಿಶಾ ಸಾಥಿಗೆ ಸುಸ್ವಾಗತ. ನಿಮ್ಮ ಹೆಸರು ತಿಳಿಯಬಹುದೇ?`,
    ks: () => `سلام! 👋 دِشا ساتھی منٛز تُہند سواتَگتھ۔ تُہند ناڤ کیاہ چھُ؟`,
    kok: () => `नमस्कार! 👋 दिशा साथींत तुमचें स्वागत. तुमचें नांव कळूं येता?`,
    mai: () => `नमस्कार! 👋 दिशा साथी मे अहाँक स्वागत अछि। अहाँक नाम की थिक?`,
    ml: () => `നമസ്കാരം! 👋 ദിശാ സാഥിയിലേക്ക് സ്വാഗതം. നിങ്ങളുടെ പേര് അറിയാമോ?`,
    mni: () => `খুরুমজরী! 👋 দিশা সাথীদা তরাম্না ওকচরী। নহাকগী মমিং পাম্বীয়ু?`,
    mr: () => `नमस्कार! 👋 दिशा साथी मध्ये तुमचे स्वागत आहे. तुमचे नाव काय आहे?`,
    ne: () => `नमस्ते! 👋 दिशा साथीमा तपाईंलाई स्वागत छ। तपाईंको नाम थाहा पाउन सकिन्छ?`,
    or: () => `ନମସ୍କାର! 👋 ଦିଶା ସାଥୀକୁ ଆପଣଙ୍କୁ ସ୍ୱାଗତ। ଆପଣଙ୍କ ନାମ ଜାଣିପାରେ କି?`,
    pa: () => `ਸਤਿ ਸ਼੍ਰੀ ਅਕਾਲ! 👋 ਦਿਸ਼ਾ ਸਾਥੀ ਵਿੱਚ ਤੁਹਾਡਾ ਸਵਾਗਤ ਹੈ। ਕੀ ਮੈਂ ਤੁਹਾਡਾ ਨਾਮ ਜਾਣ ਸਕਦਾ ਹਾਂ?`,
    sa: () => `नमो नमः! 👋 दिशा साथी इत्यत्र भवतः स्वागतम्। भवतः नाम किम्?`,
    sat: () => `ᱡᱚᱦᱟᱨ! 👋 ᱫᱤᱥᱟᱹ ᱥᱟᱛᱷᱤ ᱨᱮ ᱟᱢᱟᱜ ᱥᱟᱹᱜᱩᱱ ᱫᱟᱨᱟᱢ᱾ ᱟᱢᱟᱜ ᱧᱩᱛᱩᱢ ᱪᱮᱫ?`,
    sd: () => `سلام! 👋 دشا ساٿي ۾ ڀلي ڪري آيا. توهان جو نالو ڇا آهي؟`,
    ta: () => `வணக்கம்! 👋 திஷா சாதிக்கு வரவேற்கிறோம். உங்கள் பெயர் என்ன?`,
    te: () => `నమస్కారం! 👋 దిశా సాథీకి స్వాగతం. మీ పేరు తెలుసుకోవచ్చా?`,
    ur: () => `السلام علیکم! 👋 دِشا ساتھی میں آپ کا خیرمقدم ہے۔ کیا میں آپ کا نام جان سکتا ہوں؟`,
  },

  age: {
    as: (p) => p.name ? `আপোনাক লগ পাই ভাল লাগিল, ${p.name}! আপোনাৰ বয়স কিমান?` : `আপোনাৰ বয়স কিমান?`,
    bn: (p) => p.name ? `আপনার সাথে পরিচিত হয়ে আনন্দিত, ${p.name}! আপনার বয়স কত?` : `আপনার বয়স কত?`,
    brx: (p) => p.name ? `नोंथांखौ सिनायनानै गोजोननाय मोन्नाय, ${p.name}! नोंथांनि बैसा बेसेबां?` : `नोंथांनि बैसा बेसेबां?`,
    doi: (p) => p.name ? `तुंदे कने मिली ते खुशी होई, ${p.name}! तुंदी उमरा केह ऐ?` : `तुंदी उमरा केह ऐ?`,
    en: (p) => p.name ? `Nice to meet you, ${p.name}! What is your age?` : `What is your age?`,
    gu: (p) => p.name ? `તમને મળીને આનંદ થયો, ${p.name}! તમારી ઉંમર કેટલી છે?` : `તમારી ઉંમર કેટલી છે?`,
    hi: (p) => p.name ? `आपसे मिलकर खुशी हुई, ${p.name}! आपकी उम्र क्या है?` : `आपकी उम्र क्या है?`,
    kn: (p) => p.name ? `ನಿಮ್ಮನ್ನು ಭೇಟಿಯಾಗಿದ್ದು ಸಂತೋಷವಾಯಿತು, ${p.name}! ನಿಮ್ಮ ವಯಸ್ಸು ಎಷ್ಟು?` : `ನಿಮ್ಮ ವಯಸ್ಸು ಎಷ್ಟು?`,
    ks: (p) => p.name ? `تُہیہِ سٟتؠ مِلِتھ گئؠ خُشی، ${p.name}! تُہنز عُمر کیاہ چھِ؟` : `تُہنز عُمر کیاہ چھِ؟`,
    kok: (p) => p.name ? `तुका मेळून खोशी जाली, ${p.name}! तुमचें पिराय कितलें?` : `तुमचें पिराय कितलें?`,
    mai: (p) => p.name ? `अहाँ सँ मिलि कऽ प्रसन्नता भेल, ${p.name}! अहाँक उमर कतेक अछि?` : `अहाँक उमर कतेक अछि?`,
    ml: (p) => p.name ? `നിങ്ങളെ കണ്ടുമുട്ടിയതിൽ സന്തോഷം, ${p.name}! നിങ്ങളുടെ പ്രായം എത്രയാണ്?` : `നിങ്ങളുടെ പ്രായം എത്രയാണ്?`,
    mni: (p) => p.name ? `নহাকপু উন্নবদা নুংঙাইরে, ${p.name}! নহাকগী চহি কায়াম সুরগে?` : `নহাকগী চহি কায়াম সুরগে?`,
    mr: (p) => p.name ? `तुम्हाला भेटून आनंद झाला, ${p.name}! तुमचे वय काय आहे?` : `तुमचे वय काय आहे?`,
    ne: (p) => p.name ? `तपाईंलाई भेटेर खुसी लाग्यो, ${p.name}! तपाईंको उमेर कति हो?` : `तपाईंको उमेर कति हो?`,
    or: (p) => p.name ? `ଆପଣଙ୍କୁ ଭେଟି ବହୁତ ଖୁସି ଲାଗିଲା, ${p.name}! ଆପଣଙ୍କ ବୟସ କେତେ?` : `ଆପଣଙ୍କ ବୟସ କେତେ?`,
    pa: (p) => p.name ? `ਤੁਹਾਨੂੰ ਮਿਲ ਕੇ ਖੁਸ਼ੀ ਹੋਈ, ${p.name}! ਤੁਹਾਡੀ ਉਮਰ ਕਿੰਨੀ ਹੈ?` : `ਤੁਹਾਡੀ ਉਮਰ ਕਿੰਨੀ ਹੈ?`,
    sa: (p) => p.name ? `भवता सह मिलित्वा आनन्दः जातः, ${p.name}! भवतः वयः किम्?` : `भवतः वयः किम्?`,
    sat: (p) => p.name ? `ᱟᱢ ᱥᱟᱶ ᱧᱟᱯᱟᱢ ᱠᱟᱛᱮ ᱨᱟᱹᱥᱠᱟᱹ ᱵᱩᱡᱷᱟᱹᱣᱮᱱᱟ, ${p.name}! ᱟᱢᱟᱜ ᱩᱢᱮᱨ ᱛᱤᱱᱟᱹᱜ?` : `ᱟᱢᱟᱜ ᱩᱢᱮᱨ ᱛᱤᱱᱟᱹᱜ?`,
    sd: (p) => p.name ? `توهان سان ملي خوشي ٿي، ${p.name}! توهان جي عمر ڪيتري آهي؟` : `توهان جي عمر ڪيتري آهي؟`,
    ta: (p) => p.name ? `உங்களை சந்தித்ததில் மகிழ்ச்சி, ${p.name}! உங்கள் வயது என்ன?` : `உங்கள் வயது என்ன?`,
    te: (p) => p.name ? `మిమ్మల్ని కలవడం సంతోషంగా ఉంది, ${p.name}! మీ వయస్సు ఎంత?` : `మీ వయస్సు ఎంత?`,
    ur: (p) => p.name ? `آپ سے مل کر خوشی ہوئی، ${p.name}! آپ کی عمر کیا ہے؟` : `آپ کی عمر کیا ہے؟`,
  },

  state: {
    as: () => `আপুনি বৰ্তমান কোনখন ৰাজ্যৰ?`,
    bn: () => `আপনি বর্তমানে কোন রাজ্যে থাকেন?`,
    brx: () => `नोंथाङा दाथायाव मा राइज्यनिफाय?`,
    doi: () => `तसुआ कुसडी रियासत थमां ओ?`,
    en: () => `Which state are you currently from?`,
    gu: () => `તમે હાલમાં કયા રાજ્યના છો?`,
    hi: () => `आप वर्तमान में किस राज्य से हैं?`,
    kn: () => `ನೀವು ಪ್ರಸ್ತುತ ಯಾವ ರಾಜ್ಯದವರು?`,
    ks: () => `تُہیہِ کَس رِیاسَتہٕ مَنٛز چھِ روزان؟`,
    kok: () => `तुम्ही सध्या खंयच्या राज्यांतले?`,
    mai: () => `अहाँ वर्तमान मे कतय सँ छी (कोन राज्य)?`,
    ml: () => `നിങ്ങൾ നിലവിൽ ഏത് സംസ്ഥാനത്തു നിന്നുള്ളയാളാണ്?`,
    mni: () => `নহাক হージュিক করম্বা রাজ্যদগী লৈরিবনো?`,
    mr: () => `तुम्ही सध्या कोणत्या राज्यातील आहात?`,
    ne: () => `तपाईं हाल कुन राज्यबाट हुनुहुन्छ?`,
    or: () => `ଆପଣ ବର୍ତ୍ତମାନ କେଉଁ ରାଜ୍ୟରୁ ଅଟନ୍ତି?`,
    pa: () => `ਤੁਸੀਂ ਫਿਲਹਾਲ ਕਿਸ ਰਾਜ ਤੋਂ ਹੋ?`,
    sa: () => `भवान् / भवती कस्य राज्यस्य निवासी अस्ति?`,
    sat: () => `ᱟᱢ ᱫᱚ ᱱᱤᱛᱚᱜ ᱚᱠᱟ ᱯᱚᱱᱚᱛ ᱨᱮᱱ ᱠᱟᱱᱟᱢ?`,
    sd: () => `توهان هن وقت ڪهڙي رياست مان آهيو؟`,
    ta: () => `நீங்கள் தற்போது எந்த மாநிலத்தைச் சேர்ந்தவர்?`,
    te: () => `మీరు ప్రస్తుతం ఏ రాష్ట్రానికి చెందినవారు?`,
    ur: () => `آپ فی الحال کس ریاست سے ہیں؟`,
  },

  district: {
    as: () => `আপোনাৰ জিলা কি?`,
    bn: () => `আপনার জেলার নাম কী?`,
    brx: () => `नोंथांनि जिलानि मुङा मा?`,
    doi: () => `तुंदा जिला केह ऐ?`,
    en: () => `Which district are you from?`,
    gu: () => `તમારો જિલ્લો કયો છે?`,
    hi: () => `आपका जिला कौन सा है?`,
    kn: () => `ನಿಮ್ಮ ಜಿಲ್ಲೆ ಯಾವುದು?`,
    ks: () => `تُہند ضِلعہٕ کیاہ چھُ؟`,
    kok: () => `तुमचो जिल्लो खंयचो?`,
    mai: () => `अहाँक जिला कोन थिक?`,
    ml: () => `നിങ്ങളുടെ ജില്ല ഏതാണ്?`,
    mni: () => `নহাকগী জিলা করম্বনো?`,
    mr: () => `तुमचा जिल्हा कोणता आहे?`,
    ne: () => `तपाईं कुन जिल्लाबाट हुनुहुन्छ?`,
    or: () => `ଆପଣଙ୍କର ଜିଲ୍ଲା କେଉଁଟି?`,
    pa: () => `ਤੁਹਾਡਾ ਜ਼ਿਲ੍ਹਾ ਕਿਹੜਾ ਹੈ?`,
    sa: () => `भवतः मण्डलम् (District) किम्?`,
    sat: () => `ᱟᱢᱟᱜ ᱡᱤᱞᱟᱹ ᱫᱚ ᱚᱠᱟᱴᱟᱜ?`,
    sd: () => `توهان جو ضلعو ڪهڙو آهي؟`,
    ta: () => `உங்கள் மாவட்டம் எது?`,
    te: () => `మీ జిల్లా ఏది?`,
    ur: () => `آپ کا ضلع کون سا ہے؟`,
  },

  location: {
    as: () => `আপোনাৰ বৰ্তমান স্থান (নগৰ/গাওঁ) কি?`,
    bn: () => `আপনার বর্তমান অবস্থান বা শহরের নাম কী?`,
    brx: () => `नोंथांनि दासिमनि जायগानि मुङा मा?`,
    doi: () => `तुंदा मौजूदा बसेवा कुसडा ऐ?`,
    en: () => `What is your current location (city/town/village)?`,
    gu: () => `તમારું વર્તમાન સરનામું/સ્થળ કયું છે?`,
    hi: () => `आपका वर्तमान स्थान (शहर/गांव) क्या है?`,
    kn: () => `ನಿಮ್ಮ ಪ್ರಸ್ತುತ ಸ್ಥಳ (ನಗರ/ಗ್ರಾಮ) ಯಾವುದು?`,
    ks: () => `تُہند موجودہ جائے کۄس چھِ؟`,
    kok: () => `तुमचें सध्याचें ठिकाण खंयचें?`,
    mai: () => `अहाँक वर्तमान स्थान (शहर/गाँव) की थिक?`,
    ml: () => `നിങ്ങളുടെ നിലവിലെ സ്ഥലം (നഗരം/ഗ്രാമം) ഏതാണ്?`,
    mni: () => `নহাকগী হৌজিক লৈরিবা মফম অদুগী মমিং কিবগে?`,
    mr: () => `तुमचे सध्याचे स्थान (शहर/गाव) कोणते आहे?`,
    ne: () => `तपाईंको हालको स्थान (शहर/गाउँ) कुन हो?`,
    or: () => `ଆପଣଙ୍କର ବର୍ତ୍ତମାନର ସ୍ଥାନ (ସହର/ଗ୍ରାମ) କେଉଁଟି?`,
    pa: () => `ਤੁਹਾਡਾ ਮੌਜੂਦਾ ਸਥਾਨ (ਸ਼ਹਿਰ/ਪਿੰਡ) ਕੀ ਹੈ?`,
    sa: () => `भवतः वर्तमानं स्थानम् (नगरम्/ग्रामः) किम्?`,
    sat: () => `ᱟᱢᱟᱜ ᱱᱤᱛᱚᱜᱟᱜ ᱴᱷᱟᱶ (ᱟᱹᱛᱩ/ᱵᱟᱡᱟᱨ) ᱫᱚ ᱚᱠᱟ?`,
    sd: () => `توهان جي موجوده جڳهه (شهر/ڳوٺ) ڪهڙي آهي؟`,
    ta: () => `உங்கள் தற்போதைய இருப்பிடம் (நகரம்/கிராமம்) எது?`,
    te: () => `మీ ప్రస్తుత ప్రాంతం (నగరం/గ్రామం) ఏది?`,
    ur: () => `آپ کا موجودہ مقام (شہر/گاؤں) کیا ہے؟`,
  },

  education: {
    as: () => `আপোনাৰ সৰ্বোচ্চ বা বৰ্তমান শিক্ষাগত অৰ্হতা কি?`,
    bn: () => `আপনার সর্বোচ্চ বা বর্তমান শিক্ষাগত যোগ্যতা কী?`,
    brx: () => `नोंथांनि सोलोंथाइनि थाखोआ मा?`,
    doi: () => `तुंदी पढ़ाई कन्ने योग्यता केह ऐ?`,
    en: () => `What is your highest or current level of education?`,
    gu: () => `તમારી સર્વોચ્ચ શૈક્ષણિક લાયકાત કઈ છે?`,
    hi: () => `आपकी उच्चतम या वर्तमान शैक्षणिक योग्यता क्या है?`,
    kn: () => `ನಿಮ್ಮ ಅತ್ಯುನ್ನತ ಅಥವಾ ಪ್ರಸ್ತುತ ಶಿಕ್ಷಣ ಮಟ್ಟ ಯಾವುದು?`,
    ks: () => `تُہنز اعلٰی یا موجودہ تٲلیم کیاہ چھِ؟`,
    kok: () => `तुमचें सर्वोच्च शिक्षण कितलें जालां?`,
    mai: () => `अहाँक उच्चतम वा वर्तमान शैक्षणिक योग्यता की अछि?`,
    ml: () => `നിങ്ങളുടെ ഉയർന്ന അല്ലെങ്കിൽ നിലവിലെ വിദ്യാഭ്യാസ യോഗ്യത എന്താണ്?`,
    mni: () => `নহাকগী খ্বাইদগী ৱাংবা মহৈ-মশিংগী থাক অদুবু কিবগে?`,
    mr: () => `तुमची सर्वोच्च किंवा सध्याची शैक्षणिक पात्रता कोणती आहे?`,
    ne: () => `तपाईंको सर्वोच्च वा हालको शैक्षिक योग्यता के हो?`,
    or: () => `ଆପଣଙ୍କର ସର୍ବୋଚ୍ଚ କିମ୍ବା ବର୍ତ୍ତମାନର ଶିକ୍ଷାଗତ ଯୋଗ୍ୟତା କ’ଣ?`,
    pa: () => `ਤੁਹਾਡੀ ਉੱਚਤਮ ਜਾਂ ਮੌਜੂਦਾ ਵਿਦਿਅਕ ਯੋਗਤਾ ਕੀ ਹੈ?`,
    sa: () => `भवतः उच्चतमम् अथवा वर्तमानं शैक्षणिकयोग्यता किम्?`,
    sat: () => `ᱟᱢᱟᱜ ᱡᱚᱛᱚ ᱠᱷᱚᱱ ᱪᱮᱛᱟᱱ ᱥᱮᱪᱮᱫ ᱫᱚ ᱛᱤᱱᱟᱹᱜ?`,
    sd: () => `توهان جي اعليٰ يا موجوده تعليمي قابليت ڪهڙي آهي؟`,
    ta: () => `உங்கள் மிக உயர்ந்த அல்லது தற்போதைய கல்வித் தகுதி என்ன?`,
    te: () => `మీ అత్యున్నత లేదా ప్రస్తుత విద్యార్హత ఏమిటి?`,
    ur: () => `آپ کی اعلی ترین یا موجودہ تعلیمی قابلیت کیا ہے؟`,
  },

  currentOccupation: {
    as: () => `আপুনি বৰ্তমান কি কাম বা ব্যৱসায় কৰে?`,
    bn: () => `আপনি বর্তমানে কী পেশা বা কাজের সাথে যুক্ত?`,
    brx: () => `नोंथाङा दा मा हाबा मावो?`,
    doi: () => `तुक़्श आज-कल केह काम करदे ओ?`,
    en: () => `What is your current occupation or livelihood work?`,
    gu: () => `તમે હાલમાં કયો વ્યવસાય કે કામ કરો છો?`,
    hi: () => `आपका वर्तमान व्यवसाय या आजीविका का कार्य क्या है?`,
    kn: () => `ನಿಮ್ಮ ಪ್ರಸ್ತುತ ಉದ್ಯೋಗ ಅಥವಾ ಕೆಲಸ ಯಾವುದು?`,
    ks: () => `تُہیہِ کیاہ کام چھِ کران؟`,
    kok: () => `तुम्ही सध्या कितें काम करतात?`,
    mai: () => `अहाँ वर्तमान मे कोन काज वा व्यवसाय करैत छी?`,
    ml: () => `നിങ്ങൾ നിലവിൽ ചെയ്യുന്ന ജോലി അല്ലെങ്കിൽ ഉപജീവന മാർഗം എന്താണ്?`,
    mni: () => `নহাক হৌজিক করম্বা থবক-থৌরম তৌরিবগে?`,
    mr: () => `तुमचा सध्याचा व्यवसाय किंवा उपजीविकेचे काम काय आहे?`,
    ne: () => `तपाईंको हालको पेशा वा काम के हो?`,
    or: () => `ଆପଣଙ୍କର ବର୍ତ୍ତମାନର ବୃତ୍ତି କିମ୍ବା କାର୍ଯ୍ୟ କ’ଣ?`,
    pa: () => `ਤੁਹਾਡਾ ਮੌਜੂਦਾ ਕਿੱਤਾ ਜਾਂ ਕੰਮ ਕੀ ਹੈ?`,
    sa: () => `भवतः वर्तमानः व्यवसायः अथवा कार्यं किम्?`,
    sat: () => `ᱟᱢ ᱫᱚ ᱱᱤᱛᱚᱜ ᱪᱮᱫ ᱠᱟᱹᱢᱤ ᱮᱫᱟᱢ?`,
    sd: () => `توهان جو هن وقت ڪهڙو روزگار يا ڪم آهي؟`,
    ta: () => `உங்கள் தற்போதைய தொழில் அல்லது வாழ்வாதார வேலை என்ன?`,
    te: () => `మీ ప్రస్తుత వృత్తి లేదా పని ఏమిటి?`,
    ur: () => `آپ کا موجودہ پیشہ یا کام کیا ہے؟`,
  },

  familyOccupation: {
    as: () => `আপোনাৰ পৰিয়ালৰ মুখ্য জীৱিকা বা কাম কি?`,
    bn: () => `আপনার পরিবারের মূল পেশা বা কাজ কী?`,
    brx: () => `नोंथांनि नखरनि गुबै हाबाया मा?`,
    doi: () => `तुंदे परिवार दा केह काम ऐ?`,
    en: () => `What is your family's occupation?`,
    gu: () => `તમારા પરિવારનો મુખ્ય વ્યવસાય કયો છે?`,
    hi: () => `आपके परिवार का मुख्य व्यवसाय या कार्य क्या है?`,
    kn: () => `ನಿಮ್ಮ ಕುಟುಂಬದ ವೃತ್ತಿ ಯಾವುದು?`,
    ks: () => `تُہندِس خانَدانَس کیاہ کام چھِ؟`,
    kok: () => `तुमच्या कुटुंबाचो व्यवसाय कितें?`,
    mai: () => `अहाँक परिवारक मुख्य काज की अछि?`,
    ml: () => `നിങ്ങളുടെ കുടുംബത്തിന്റെ പ്രധാന തൊഴിൽ എന്താണ്?`,
    mni: () => `নহাকগী ইমুং-মনুংগী প্রধান থবক অদুবু কিবগে?`,
    mr: () => `तुमच्या कुटुंबाचा मुख्य व्यवसाय कोणता आहे?`,
    ne: () => `तपाईंको परिवारको मुख्य पेशा के हो?`,
    or: () => `ଆପଣଙ୍କ ପରିବାରର ମୁଖ୍ୟ ବୃତ୍ତି କ’ଣ?`,
    pa: () => `ਤੁਹਾਡੇ ਪਰਿਵਾਰ ਦਾ ਮੁੱਖ ਕਿੱਤਾ ਕੀ ਹੈ?`,
    sa: () => `भवतः परिवारस्य मुख्यः व्यवसायः कः?`,
    sat: () => `ᱟᱢᱟᱜ ᱜᱷᱟᱸᱨᱚᱸᱡᱽ ᱨᱮᱱᱟᱜ ᱢᱩᱬᱩᱛ ᱠᱟᱹᱢᱤ ᱫᱚ ᱪᱮᱫ?`,
    sd: () => `توهان جي خاندان جو ڪهڙو ڪم آهي؟`,
    ta: () => `உங்கள் குடும்பத்தின் தொழில் என்ன?`,
    te: () => `మీ కుటుంబ వృత్తి ఏమిటి?`,
    ur: () => `آپ کے خاندان کا پیشہ کیا ہے؟`,
  },

  skills: {
    as: () => `আপোনাৰ প্ৰধান দক্ষতা বা কামৰ অভিজ্ঞতা কি কি?`,
    bn: () => `আপনার প্রধান দক্ষতা বা কাজ করার অভিজ্ঞতা কী কী?`,
    brx: () => `नोंथांनि रोंगोथिआ मा मा?`,
    doi: () => `तुंदे च केह हुनर ऐ?`,
    en: () => `What are your main work skills?`,
    gu: () => `તમારામાં કયા મુખ્ય કૌશલ્યો કે આવડત છે?`,
    hi: () => `आपके पास मुख्य काम के कौशल (Skills) क्या हैं?`,
    kn: () => `ನಿಮ್ಮ ಮುಖ್ಯ ಉದ್ಯೋಗ ಕೌಶಲ್ಯಗಳು ಯಾವುವು?`,
    ks: () => `تُہندِ پاسہِ کۄس کۄس ہُنر چھِ؟`,
    kok: () => `तुमच्यो मुखेल हुशारक्यो खंयच्यो?`,
    mai: () => `अहाँक मुख्य कार्य कौशल (Skills) की अछि?`,
    ml: () => `നിങ്ങളുടെ പ്രധാന തൊഴിൽ കഴിവുകൾ എന്തൊക്കെയാണ്?`,
    mni: () => `নহাকগী প্রধান হেবা-শিংবা থবকশিং অদুবু কিবগে?`,
    mr: () => `तुमचे मुख्य कामाचे कौशल्य (Skills) कोणते आहे?`,
    ne: () => `तपाईंको मुख्य कामको सीपहरू के-के हुन्?`,
    or: () => `ଆପଣଙ୍କର ମୁଖ୍ୟ କାର୍ଯ୍ୟ ଦକ୍ଷତା କ’ଣ?`,
    pa: () => `ਤੁਹਾਡੇ ਕੋਲ ਮੁੱਖ ਕੰਮ ਦੇ ਹੁਨਰ ਕੀ ਹਨ?`,
    sa: () => `भवतः मुख्यानि कार्यकौशलानि कानि सन्ति?`,
    sat: () => `ᱟᱢ ᱴᱷᱮᱱ ᱪᱮᱫ ᱪᱮᱫ ᱦᱩᱱᱟᱹᱨ (Skills) ᱢᱮᱱᱟᱜᱼᱟ?`,
    sd: () => `توهان وٽ ڪهڙيون اهم مهارتون آهن؟`,
    ta: () => `உங்கள் முக்கிய வேலைத் திறன்கள் என்ன?`,
    te: () => `మీ ముఖ్యమైన పని నైపుణ్యాలు ఏమిటి?`,
    ur: () => `آپ کے پاس کون سی اہم کام کی مہارتیں ہیں؟`,
  },

  experience: {
    as: () => `আপোনাৰ পূৰ্বৰ কাম বা ইণ্টাৰ্নশ্বিপৰ অভিজ্ঞতা আছে নেকি?`,
    bn: () => `আপনার কি পূর্বে কোনো কাজের বা শিক্ষানবিশির অভিজ্ঞতা আছে?`,
    brx: () => `नोंथांनि सिगांनि हाबानि सिनायथि दं नामा?`,
    doi: () => `तुंदे कोल पहलां दा केह तजरबा ऐ?`,
    en: () => `Do you have any previous work or internship experience?`,
    gu: () => `શું તમારી પાસે અગાઉના કામનો કે અનુભવ છે?`,
    hi: () => `क्या आपके पास कोई पिछला काम या इंटर्नशिप का अनुभव है?`,
    kn: () => `ನಿಮಗೆ ಯಾವುದೇ ಪೂರ್ವ ಕೆಲಸದ ಅನುಭವ ಇದೆಯೇ?`,
    ks: () => `تُہیہِ پاسہِ گوڈنیُوک کامِہ ہُند تجرُبہٕ چھا؟`,
    kok: () => `तुमकां आदलो कितें कामाचो अनुभव आसा?`,
    mai: () => `की अहाँक लग पूर्व काज वा अनुभव अछि?`,
    ml: () => `നിങ്ങൾക്ക് മുൻപരിചയമോ ഇന്റേൺഷിപ്പ് പരിചയമോ ഉണ്ടോ?`,
    mni: () => `নহাকগী মমাংগী থবক তৌরমবগী অভিজ্ঞতা লৈব্রা?`,
    mr: () => `तुम्हाला पूर्वीचा कामाचा किंवा इंटर्नशिपचा अनुभव आहे का?`,
    ne: () => `के तपाईंसँग कुनै अघिल्लो काम वा अनुभव छ?`,
    or: () => `ଆପଣଙ୍କର କୌଣସି ପୂର୍ବ କାର୍ଯ୍ୟ ଅଭିଜ୍ଞତା ଅଛି କି?`,
    pa: () => `ਕੀ ਤੁਹਾਡੇ ਕੋਲ ਪਿਛਲੇ ਕੰਮ ਦਾ ਕੋਈ ਤਜਰਬਾ ਹੈ?`,
    sa: () => `किं भवतः पूर्वकार्यस्य अनुभवः अस्ति?`,
    sat: () => `ᱟᱢᱟᱜ ᱪᱮᱫ ᱞᱟᱦᱟ ᱛᱮᱱᱟᱜ ᱠᱟᱹᱢᱤ ᱨᱮᱱᱟᱜ ᱮᱠᱥᱯᱮᱨᱤᱭᱮᱱᱥ ᱢᱮᱱᱟᱜᱼᱟ?`,
    sd: () => `ڇا توهان وٽ اڳوڻو ڪم جو تجربو آهي؟`,
    ta: () => `உங்களுக்கு முன் வேலை அனுபவம் ஏதேனும் உள்ளதா?`,
    te: () => `మీకు గతంలో పని చేసిన అనుభవం ఉందా?`,
    ur: () => `کیا آپ کے پاس کام کا کوئی سابقہ تجربہ ہے؟`,
  },

  interests: {
    as: () => `আপোনাৰ কেৰিয়াৰৰ মুখ্য আগ্ৰহৰ ক্ষেত্ৰ কি?`,
    bn: () => `আপনার ক্যারিয়ারের মূল পছন্দের বা আগ্রহের ক্ষেত্র কী?`,
    brx: () => `नोंथांनि करियारनि गोसो गुदुं जायगाया मा?`,
    doi: () => `तुंदा कुसडे काम च शौंक ऐ?`,
    en: () => `What are your main career interests?`,
    gu: () => `તમારા કરિયરના રસના ક્ષેત્રો કયા છે?`,
    hi: () => `आपके करियर की मुख्य रुचि के क्षेत्र क्या हैं?`,
    kn: () => `ನಿಮ್ಮ ಮುಖ್ಯ ವೃತ್ತಿಜೀವನದ ಆಸಕ್ತಿಗಳು ಯಾವುವು?`,
    ks: () => `تُہیہِ کَس کامِہ منٛز شۄق چھُ؟`,
    kok: () => `तुमच्या आवडीचें काम खंयचें?`,
    mai: () => `अहाँक करियरक मुख्य रुचि कोन क्षेत्र मे अछि?`,
    ml: () => `നിങ്ങളുടെ പ്രധാന കരിയർ താൽപ്പര്യങ്ങൾ എന്തൊക്കെയാണ്?`,
    mni: () => `নহাকগী অপাম্বা ক্যারেরগী লমহেল অদুবু কিবগে?`,
    mr: () => `तुमच्या करिअरच्या आवडीचे मुख्य क्षेत्र कोणते आहे?`,
    ne: () => `तपाईंको मुख्य करियर रुचिहरू के के हुन्?`,
    or: () => `ଆପଣଙ୍କର ମୁଖ୍ୟ ଆଗ୍ରହ କେଉଁ କ୍ଷେତ୍ରରେ?`,
    pa: () => `ਤੁਹਾਡੀਆਂ ਮੁੱਖ ਕਰੀਅਰ ਰੁਚੀਆਂ ਕੀ ਹਨ?`,
    sa: () => `भवतः आजीविकारुचेः मुख्यानि क्षेत्राणि कानि?`,
    sat: () => `ᱟᱢᱟᱜ ᱠᱩᱥᱤᱭᱟᱜ ᱠᱟᱹᱢᱤ ᱫᱚ ᱪᱮᱫ?`,
    sd: () => `توهان جون اهم ڪيريئر دلچسپيون ڪهڙيون آهن؟`,
    ta: () => `உங்கள் முக்கிய தொழில் ஆர்வங்கள் என்ன?`,
    te: () => `మీ ప్రధాన కెరీర్ ఆసక్తులు ఏమిటి?`,
    ur: () => `آپ کی اہم کیریئر کی دلچسپیاں کیا ہیں؟`,
  },

  employmentPreference: {
    as: () => `আপুনি কেনেধৰণৰ নিযুক্তি বিচাৰিছে (ফুল-টাইম, স্ব-নিয়োজিত, বা চৰকাৰী)?`,
    bn: () => `আপনি কী ধরনের চাকরি পছন্দ করেন (ফুল-টাইম, খণ্ডকালীন, স্বনির্ভর বা সরকারি)?`,
    brx: () => `नोंथाङा माबायदि चाखरि नागिरदों (फुल-टायम एबा स'निर्भोर)?`,
    doi: () => `तुक़्श फुल-टाइम काम चोहंदे ओ या स्वरोजगार?`,
    en: () => `What type of employment are you looking for (e.g. full-time, part-time, self-employed, government job)?`,
    gu: () => `તમે કેવા પ્રકારની નોકરી કે રોજગારી ઈચ્છો છો (ફુલ-ટાઈમ, સ્વરોજગાર વગેરે)?`,
    hi: () => `आप किस प्रकार का रोजगार चाहते हैं (जैसे फुल-टाइम, पार्ट-टाइम, स्वरोजगार, सरकारी नौकरी)?`,
    kn: () => `ನೀವು ಎಂತಹ ಉದ್ಯೋಗವನ್ನು ಬಯಸುತ್ತೀರಿ (ಉದಾ: ಪೂರ್ಣಾವಧಿ, ಸ್ವಯಂ ಉದ್ಯೋಗ)?`,
    ks: () => `تُہیہِ کۄس نوکری چھِٚو چاہان (فُل ٹائم، پانہِ کام یا سرکٲری)؟`,
    kok: () => `तुमकां खंयच्या प्रकाराची नोकरी जाय (फुल-टायम, स्वयंरोजगार)?`,
    mai: () => `अहाँ कोन प्रकारक रोजगार चाहैत छी (फुल-टाइम, स्वरोजगार आदि)?`,
    ml: () => `ഏതുതരം ജോലിയാണ് നിങ്ങൾ നോക്കുന്നത് (ഫുൾടൈം, സ്വയംതൊഴിൽ മുതലായവ)?`,
    mni: () => `নহাক করম্বা মখালগী থবক পাম্বগে (ফুল-টাইম, মশাগী থবক)?`,
    mr: () => `तुम्हाला कोणत्या प्रकारचा रोजगार हवा आहे (उदा. फुल-टाइम, स्वयंरोजगार)?`,
    ne: () => `तपाईं कुन प्रकारको रोजगार खोज्दै हुनुहुन्छ (फुल-टाइम, स्वरोजगार)?`,
    or: () => `ଆପଣ କେଉଁ ପ୍ରକାରର ଚାକିରି ଚାହୁଁଛନ୍ତି (ଫୁଲ-ଟାଇମ୍, ସ୍ୱନିଯୁକ୍ତି)?`,
    pa: () => `ਤੁਸੀਂ ਕਿਸ ਤਰ੍ਹਾਂ ਦਾ ਰੁਜ਼ਗਾਰ ਚਾਹੁੰਦੇ ਹੋ (ਜਿਵੇਂ ਫੁੱਲ-ਟਾਈਮ, ਸਵੈ-ਰੁਜ਼ਗਾਰ)?`,
    sa: () => `भवान् कीदृशं रोजगारम् इच्छति (पूर्णकालिकम्, स्वरोजगारम्)?`,
    sat: () => `ᱟᱢ ᱫᱚ ᱚᱠᱟ ᱞᱮᱠᱟᱱ ᱪᱟᱹᱠᱨᱤ ᱠᱩᱥᱤᱭᱟᱜᱼᱟᱢ (ᱯᱩᱨᱟᱹ ᱚᱠᱛᱚ/ᱱᱤᱡᱮ ᱠᱟᱹᱢᱤ)?`,
    sd: () => `توهان ڪهڙي قسم جو روزگار چاهيو ٿا (فل ٽائيم، پنهنجو ڪم)؟`,
    ta: () => `நீங்கள் எந்த வகையான வேலையை எதிர்பார்க்கிறீர்கள் (முழுநேரம், சுயதொழில்)?`,
    te: () => `మీరు ఎలాంటి ఉద్యోగాన్ని కోరుకుంటున్నారు (ఫుల్ టైమ్, స్వయం ఉపాధి)?`,
    ur: () => `آپ کس قسم کا روزگار چاہتے ہیں (مثلاً فل ٹائم، اپنا کاروبار)؟`,
  },

  mobilityConstraints: {
    as: () => `আপোনাৰ অন্য ঠাইলৈ যোৱাৰ বা স্থানান্তৰৰ কোনো বাধা আছে নেকি?`,
    bn: () => `আপনার অন্য স্থান বা জেলায় স্থানান্তরিত হওয়ার কোনো সীমাবদ্ধতা আছে?`,
    brx: () => `नोंथांनि गुबुन जायगायाव थांनो हेंथा दं नामा?`,
    doi: () => `तुक़्श बहार जाई ते काम करी सकदे ओ?`,
    en: () => `Do you have any mobility constraints or relocation limits?`,
    gu: () => `શું તમને અન્ય સ્થળે સ્થળાંતર કરવા માટે કોઈ મર્યાદા છે?`,
    hi: () => `क्या आपके पास कोई स्थान परिवर्तन (Relocation) या आने-जाने की सीमा है?`,
    kn: () => `ನಿಮಗೆ ಬೇರೆ ಸ್ಥಳಕ್ಕೆ ಸ್ಥಳಾಂತರಗೊಳ್ಳಲು ಯಾವುದೇ ಮಿತಿಗಳಿವೆಯೇ?`,
    ks: () => `تُہیہِ بییِس جائس پؠٹھ گژھنَس منٛز کانٛہہ رُکاوٹ چھا؟`,
    kok: () => `तुमकां दुसऱ्या शारांत वचून काम करपाक जायगी?`,
    mai: () => `की अहाँक अन्य स्थान पर जाए मे कोनो समस्या अछि?`,
    ml: () => `നിങ്ങൾക്ക് മറ്റ് സ്ഥലങ്ങളിലേക്ക് മാറുന്നതിന് എന്തെങ്കിലും പരിമിതികളുണ്ടോ?`,
    mni: () => `নহাক মফম অতোপ্পদা চৎতুনা থবক তৌবদা খুদোংচাদবা লৈব্রা?`,
    mr: () => `तुम्हाला इतर ठिकाणी स्थलांतरित होण्यासाठी काही मर्यादा आहेत का?`,
    ne: () => `के तपाईंलाई अन्य स्थानमा सर्न कुनै सीमा वा कठिनाइ छ?`,
    or: () => `ଆପଣଙ୍କର ଅନ୍ୟ ସ୍ଥାନକୁ ଯିବା ପାଇଁ କୌଣସି ପ୍ରତିବନ୍ଧକ ଅଛି କି?`,
    pa: () => `ਕੀ ਤੁਹਾਡੇ ਕੋਲ ਹੋਰ ਥਾਂ ਜਾਣ ਵਿੱਚ ਕੋਈ ਰੁਕਾਵਟ ਜਾਂ ਸੀਮਾ ਹੈ?`,
    sa: () => `किं भवतः अन्यत्र गत्वा कार्यकरणे कापि सीमा अस्ति?`,
    sat: () => `ᱟᱢ ᱫᱚ ᱮᱴᱟᱜ ᱴᱷᱟᱶ ᱪᱟᱞᱟᱣ ᱠᱟᱛᱮ ᱠᱟᱹᱢᱤ ᱨᱮ ᱪᱮᱫ ᱮᱴᱠᱮᱴᱚᱬᱮ ᱢᱮᱱᱟᱜᱼᱟ?`,
    sd: () => `ڇا توهان کي ٻئي هنڌ وڃي ڪم ڪرڻ ۾ ڪا رڪاوٽ آهي؟`,
    ta: () => `வேறு இடத்திற்குச் சென்று வேலை செய்ய உங்களுக்கு ஏதேனும் தடைகள் உள்ளதா?`,
    te: () => `మీకు వేరే ప్రాంతానికి వెళ్లి పని చేయడానికి ఏమైనా పరిమితులు ఉన్నాయా?`,
    ur: () => `کیا آپ کو کسی دوسرے مقام پر منتقل ہونے میں کوئی رکاوٹ ہے؟`,
  },

  careerGoal: {
    as: () => `আপোনাৰ মুখ্য কেৰিয়াৰৰ লক্ষ্য বা সপোন কি?`,
    bn: () => `আপনার ক্যারিয়ারের প্রধান লক্ষ্য বা স্বপ্ন কী?`,
    brx: () => `नोंथांनि करियारनि गुबै थांखिया मा?`,
    doi: () => `तुंदा करियार दा मक्कसद केह ऐ?`,
    en: () => `What is your main career goal?`,
    gu: () => `તમારું મુખ્ય કરિયરનું લક્ષ્ય કે સ્વપ્ન શું છે?`,
    hi: () => `आपका मुख्य करियर का लक्ष्य या सपना क्या है?`,
    kn: () => `ನಿಮ್ಮ ಮುಖ್ಯ ವೃತ್ತಿಜೀವನದ ಗುರಿ ಏನು?`,
    ks: () => `تُہندِ کیریئرُک اصل مَقصد کیاہ چھُ؟`,
    kok: () => `तुमचें करियराचें मुखेल ध्येय कितें?`,
    mai: () => `अहाँक मुख्य करियर लक्ष्य वा सपना की अछि?`,
    ml: () => `നിങ്ങളുടെ പ്രധാന കരിയർ ലക്ഷ്യം എന്താണ്?`,
    mni: () => `নহাকগী ক্যারেরগী প্রধান পান্দম অদুবু কিবগে?`,
    mr: () => `तुमचे मुख्य करिअरचे ध्येय किंवा स्वप्न काय आहे?`,
    ne: () => `तपाईंको मुख्य करियरको लक्ष्य वा सपना के हो?`,
    or: () => `ଆପଣଙ୍କର ମୁଖ୍ୟ କ୍ୟାରିଅର୍ ଲକ୍ଷ୍ୟ କ’ଣ?`,
    pa: () => `ਤੁਹਾਡਾ ਮੁੱਖ ਕਰੀਅਰ ਦਾ ਟੀਚਾ ਕੀ ਹੈ?`,
    sa: () => `भवतः मुख्यम् आजीविकालक्ष्यं किम् अस्ति?`,
    sat: () => `ᱟᱢᱟᱜ ᱢᱩᱬᱩᱛ ᱠᱟᱹᱢᱤ ᱨᱮᱱᱟᱜ ᱡᱚᱥ (Goal) ᱫᱚ ᱪᱮᱫ?`,
    sd: () => `توهان جو اهم ڪيريئر جومقصد ڇا آهي؟`,
    ta: () => `உங்கள் முக்கிய தொழில் இலக்கு என்ன?`,
    te: () => `మీ ప్రధాన కెరీర్ లక్ష్యం ఏమిటి?`,
    ur: () => `آپ کا بنیادی کیریئر کا ہدف کیا ہے؟`,
  },
};

// ---------------------------------------------------------------------------
// 3. Greeting detection
// ---------------------------------------------------------------------------
const GREETING_REGEX =
  /^\s*(hi+|hello+|hey+|hii+|yo|namaste|namaskar|good\s*morning|good\s*afternoon|good\s*evening|নমস্কাৰ|নমস্কার|খুলুমबाय|नमस्ते|નમસ્તે|નમસ્કાર|ನಮಸ್ಕಾರ|سلام|नमस्कार|नमस्कारः|جوهار|வணக்கம்|నమస్కారం)\s*[!.,]*\s*$/i;

function detectGreeting(message) {
  if (!message) return false;
  return GREETING_REGEX.test(message.trim());
}

// ---------------------------------------------------------------------------
// 4. Smart Field Extractor
// ---------------------------------------------------------------------------

function convertNativeDigitsToAscii(str) {
  if (!str) return '';
  const nativeDigits = {
    '०':0,'१':1,'२':2,'३':3,'४':4,'५':5,'६':6,'७':7,'८':8,'९':9,
    '০':0,'১':1,'২':2,'৩':3,'৪':4,'৫':5,'৬':6,'৭':7,'৮':8,'৯':9,
    '੦':0,'੧':1,'੨':2,'੩':3,'੪':4,'੫':5,'੬':6,'੭':7,'੮':8,'੯':9,
    '૦':0,'૧':1,'૨':2,'૩':3,'૪':4,'૫':5,'૬':6,'૭':7,'૮':8,'૯':9,
    '೦':0,'೧':1,'೨':2,'೩':3,'೪':4,'೫':5,'೬':6,'೭':7,'೮':8,'೯':9,
    '൦':0,'<ctrl42>':1,'൨':2,'൩':3,'൪':4,'<ctrl42>':5,'൬':6,'<ctrl42>':7,'<ctrl42>':8,'<ctrl42>':9,
    '୦':0,'୧':1,'୨':2,'୩':3,'୪':4,'୫':5,'୬':6,'୭':7,'୮':8,'୯':9,
    '௦':0,'௧':1,'௨':2,'௪':4,'௫':5,'௬':6,'<ctrl42>':7,'<ctrl42>':8,'<ctrl42>':9,
    '౦':0,'౧':1,'౨':2,'౩':3,'౪':4,'౫':5,'౬':6,'౭':7,'౮':8,'౯':9
  };
  return str.replace(/[०-९০-৯੦-੯૦-૯೦-೯൦-൯୦-୯௦-௯౦-౯]/g, (d) => nativeDigits[d] !== undefined ? nativeDigits[d] : d);
}

function ruleBasedExtract(message, expectedKey) {
  const result = {};
  const text = convertNativeDigitsToAscii((message || '').trim());
  if (!text) return result;

  if (expectedKey === 'name') {
    const explicitNameMatch = text.match(/\b(?:my name is|i am|mera naam|naam|আমার নাম|আমার নাম|নাম|नाम)\s+([a-zA-Z\u0900-\u097F. ]{2,25})\b/i);
    if (explicitNameMatch && explicitNameMatch[1]) {
      result.name = explicitNameMatch[1].trim();
    } else {
      const looksLikeWorkOrSkill = /\b(काम|खेती|सिलाई|दूकान|pass|know|working|job|study|10th|12th|কাজ|চাষ)\b/i.test(text);
      if (!looksLikeWorkOrSkill && text.length <= 30 && !/\d/.test(text)) {
        result.name = text;
      }
    }
  } else if (expectedKey === 'age') {
    const cleanTextForAge = text.replace(/\b(10th|12th|8th)\b/gi, '');
    const ageMatch = cleanTextForAge.match(/\b(\d{1,2})\b/);
    if (ageMatch) {
      const num = parseInt(ageMatch[1], 10);
      if (num >= 12 && num <= 90) {
        result.age = num;
      }
    }
  } else if (expectedKey) {
    result[expectedKey] = text;
  }

  return result;
}

async function extractFieldsFromMessage(message, expectedKey, missingFields, llmClient = null) {
  return ruleBasedExtract(message, expectedKey);
}

// ---------------------------------------------------------------------------
// 5. Step helpers
// ---------------------------------------------------------------------------

function getMissingFields(profile) {
  return FIELD_KEYS.filter((key) => {
    const val = profile[key];
    return val === null || val === undefined || val === '';
  });
}

function getNextField(profile) {
  for (const field of FIELD_ORDER) {
    const val = profile[field.key];
    if (val === null || val === undefined || val === '') {
      return field;
    }
  }
  return null;
}

function getQuestionFor(field, profile, languageCode = 'en') {
  const lang = (languageCode || 'en').toLowerCase().trim();
  const qDict = MULTILINGUAL_QUESTIONS[field.key];
  if (qDict) {
    const qFunc = qDict[lang] || qDict.en || field.question;
    return qFunc(profile);
  }
  return field.question(profile);
}

// ---------------------------------------------------------------------------
// 6. Job Recommendation & NSQF Training Matching Decision Engine
// ---------------------------------------------------------------------------

function recommendJobRole(profile) {
  const goalAndInterests = `${profile.careerGoal || ''} ${profile.interests || ''}`.toLowerCase();
  const allText = `${goalAndInterests} ${profile.skills || ''} ${profile.currentOccupation || ''}`.toLowerCase();

  const matchDomain = (str) => {
    if (str.includes('tailor') || str.includes('sew') || str.includes('stitch') || str.includes('cloth') || str.includes('सिलाई') || str.includes('সেলাই') || str.includes('দর্জি')) {
      return { title: 'Self Employed Tailor / Garment Technician', sector: 'Apparel & Textiles' };
    }
    if (str.includes('farm') || str.includes('crop') || str.includes('agri') || str.includes('खेती') || str.includes('কৃষি') || str.includes('organic')) {
      return { title: 'Organic Farmer / Agri Crop Cultivator', sector: 'Agriculture' };
    }
    if (str.includes('data analyst') || str.includes('data entry') || str.includes('coding') || str.includes('computer') || str.includes('office') || str.includes('excel') || str.includes('typing')) {
      return { title: 'Data Entry Operator / Office Assistant', sector: 'IT-ITeS' };
    }
    if (str.includes('electric') || str.includes('wire') || str.includes('power') || str.includes('बिजली') || str.includes('বিদ্যুৎ')) {
      return { title: 'Assistant Electrician / Wiring Technician', sector: 'Electronics & HW / Power' };
    }
    if (str.includes('health') || str.includes('nurse') || str.includes('patient') || str.includes('medical') || str.includes('अस्पताल') || str.includes('হাসপাতাল')) {
      return { title: 'General Duty Assistant / Healthcare Associate', sector: 'Healthcare' };
    }
    if (str.includes('drive') || str.includes('driver') || str.includes('vehicle') || str.includes('चालक') || str.includes('ড্রাইভার')) {
      return { title: 'Commercial Vehicle Driver / Logistics Operator', sector: 'Transportation, Logistics & Warehousing' };
    }
    if (str.includes('sales') || str.includes('retail') || str.includes('shop') || str.includes('store') || str.includes('दुकान') || str.includes('দোকান')) {
      return { title: 'Retail Sales Associate / Store Executive', sector: 'Retail' };
    }
    if (str.includes('cook') || str.includes('food') || str.includes('chef') || str.includes('hotel') || str.includes('खाना') || str.includes('রান্না')) {
      return { title: 'Food Production Technician / Cook', sector: 'Tourism & Hospitality / Food Processing' };
    }
    if (str.includes('solar') || str.includes('green') || str.includes('clean')) {
      return { title: 'Solar LED / Rooftop Solar Technician', sector: 'Environmental Science & Green Jobs' };
    }
    return null;
  };

  const primaryMatch = matchDomain(goalAndInterests);
  if (primaryMatch) return primaryMatch;

  const secondaryMatch = matchDomain(allText);
  if (secondaryMatch) return secondaryMatch;

  const fallbackJob = profile.careerGoal || profile.interests || profile.skills || profile.currentOccupation || 'General Skilled Associate';
  return { title: fallbackJob, sector: 'Skill Development' };
}

function searchNsqfRecommendations(profile, limit = 4) {
  if (!Array.isArray(nsqfDataset) || nsqfDataset.length === 0) return [];

  const queryTerms = [
    profile.careerGoal,
    profile.interests,
    profile.skills,
    profile.education,
    profile.currentOccupation,
  ]
    .filter(Boolean)
    .join(' ')
    .toLowerCase();

  const words = queryTerms.split(/\s+/).filter((w) => w.length >= 3);

  const scored = nsqfDataset.map((item) => {
    let score = 0;
    const title = (item.Title || '').toLowerCase();
    const sector = (item['Sector Name'] || '').toLowerCase();
    const desc = (item.Description || '').toLowerCase();
    const occupation = (item['Proposed Occupation'] || '').toLowerCase();

    for (const word of words) {
      if (title.includes(word)) score += 15;
      if (occupation.includes(word)) score += 10;
      if (sector.includes(word)) score += 5;
      if (desc.includes(word)) score += 2;
    }

    return { item, score };
  });

  scored.sort((a, b) => b.score - a.score);

  if (scored.length > 0 && scored[0].score === 0) {
    return [nsqfDataset[0], nsqfDataset[4], nsqfDataset[10], nsqfDataset[15]].slice(0, limit);
  }

  return scored.slice(0, limit).map((s) => s.item);
}

function buildSummary(profile, languageCode = 'en') {
  const { buildNsqfChatResponse } = require('./nsqfMatcher');
  const nsqfResult = buildNsqfChatResponse(profile, '', languageCode);
  const displayName = profile.name || 'Friend';

  const introGreeting = {
    as: `ধন্যবাদ, ${displayName}! 🎉 মই আপোনাৰ প্ৰফাইল মূল্যায়ন সম্পন্ন কৰিলোঁ।\n\n`,
    bn: `ধন্যবাদ, ${displayName}! 🎉 আমি আপনার প্রোফাইল অ্যাসেসমেন্ট সম্পন্ন করেছি।\n\n`,
    brx: `गोजोननाय, ${displayName}! 🎉 आं नोंथांनि प्रफाइल बिजिरनायखौ फोजोबबाय।\n\n`,
    doi: `धन्यवाद, ${displayName}! 🎉 में तुंदा प्रोफाइल मूल्यांकन पूरा करी लेता ऐ।\n\n`,
    gu: `આભાર, ${displayName}! 🎉 મેં તમારું પ્રોફાઇલ મૂલ્યાંકન પૂર્ણ કર્યું છે.\n\n`,
    hi: `धन्यवाद, ${displayName}! 🎉 मैंने आपका प्रोफ़ाइल मूल्यांकन पूरा कर लिया है।\n\n`,
    kn: `ಧನ್ಯವಾದಗಳು, ${displayName}! 🎉 ನಾನು ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಮೌಲ್ಯಮಾಪನವನ್ನು ಪೂರ್ಣಗೊಳಿಸಿದ್ದೇನೆ.\n\n`,
    ks: `شُکریہ، ${displayName}! 🎉 مےٚ کۆر تُہند پروفائل اِسیستمینٹ پُورٕ۔\n\n`,
    kok: `देव बरे करूं, ${displayName}! 🎉 हांवें तुमचें प्रोफाइल मूल्यमापन पुराय केलां.\n\n`,
    mai: `धन्यवाद, ${displayName}! 🎉 हम अहाँक प्रोफाइल मूल्यांकन पूरा कऽ लेलहुँ।\n\n`,
    ml: `നന്ദി, ${displayName}! 🎉 ഞാൻ നിങ്ങളുടെ പ്രൊഫൈൽ വിലയിരുത്തൽ പൂർത്തിയാക്കി.\n\n`,
    mni: `থাগৎচরী, ${displayName}! 🎉 ইশানা নহাকগী প্রোফাইল কুপ্না য়েংশিনখ্রে।\n\n`,
    mr: `धन्यवाद, ${displayName}! 🎉 मी तुमचे प्रोफाईल मूल्यमापन पूर्ण केले आहे.\n\n`,
    ne: `धन्यवाद, ${displayName}! 🎉 मैंने तपाईंको प्रोफाइल मूल्यांकन पूरा गरिसकें।\n\n`,
    or: `ଧନ୍ୟବାଦ, ${displayName}! 🎉 ମୁଁ ଆପଣଙ୍କର ପ୍ରୋଫାଇଲ୍ ମୂଲ୍ୟାଙ୍କନ ସମ୍ପୂର୍ଣ୍ଣ କରିଛି।\n\n`,
    pa: `ਧੰਨਵਾਦ, ${displayName}! 🎉 ਮੈਂ ਤੁਹਾਡਾ ਪ੍ਰੋਫਾਈਲ ਮੁਲਾਂਕਣ ਪੂਰਾ ਕਰ ਲਿਆ ਹੈ।\n\n`,
    sa: `धन्यवादः, ${displayName}! 🎉 मया भवतः वृत्तचित्रमूल्यांकनम् पूर्णं कृतम्।\n\n`,
    sat: `ᱥᱟᱨᱦᱟᱣ, ${displayName}! 🎉 ᱤᱧ ᱟᱢᱟᱜ ᱯᱨᱚᱯᱷᱟᱭᱤᱞ ᱵᱤᱪᱟᱹᱨ ᱯᱩᱨᱟᱹᱣ ᱠᱮᱫᱟᱹᱧ᱾\n\n`,
    sd: `مهرباني، ${displayName}! 🎉 مون توهان جي پروفائل جي تشخيص مڪمل ڪري ورتي آهي.\n\n`,
    ta: `நன்றி, ${displayName}! 🎉 உங்கள் சுயவிவர மதிப்பீட்டை நான் முடித்துவிட்டேன்.\n\n`,
    te: `ధన్యవాదాలు, ${displayName}! 🎉 నేను మీ ప్రొఫైల్ మూల్యాంకనాన్ని పూర్తి చేసాను.\n\n`,
    ur: `شکریہ، ${displayName}! 🎉 میں نے آپ کا پروفائل اسسمنٹ مکمل کر لیا ہے۔\n\n`,
    en: `Thank you, ${displayName}! 🎉 I have completed your profile assessment.\n\n`,
  };

  const lang = (languageCode || 'en').toLowerCase().trim();
  const greetingText = introGreeting[lang] || introGreeting.en;

  return (greetingText + nsqfResult.reply).trim();
}

module.exports = {
  FIELD_ORDER,
  FIELD_KEYS,
  MULTILINGUAL_QUESTIONS,
  detectGreeting,
  extractFieldsFromMessage,
  ruleBasedExtract,
  getMissingFields,
  getNextField,
  getQuestionFor,
  recommendJobRole,
  buildSummary,
  searchNsqfRecommendations,
};
