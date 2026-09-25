/**
 * nsqfMatcher.js — Dynamic Matching Engine over 2,814 NSQF Training Records
 * Disha Saathi · SIH 2026 · PS 26097
 */

const nsqfDataset = require('../data/NSQF_Training_Recommendation');

// Domain/Sector Mapping for User Skills & Interests across English, Hindi, and Bengali
const SECTOR_SYNONYMS = {
  computer: ['it-ites', 'electronics & hw', 'telecom', 'digital', 'office administration & facility management'],
  it: ['it-ites', 'electronics & hw', 'telecom'],
  software: ['it-ites', 'electronics & hw'],
  data: ['it-ites', 'office administration & facility management', 'transportation, logistics & warehousing'],
  typing: ['it-ites', 'office administration & facility management'],
  excel: ['it-ites', 'office administration & facility management'],

  healthcare: ['healthcare', 'life sciences', 'beauty & wellness', 'home management and caregiving', 'persons with disability'],
  medical: ['healthcare', 'life sciences'],
  nursing: ['healthcare', 'home management and caregiving'],
  patient: ['healthcare', 'home management and caregiving'],

  agriculture: ['agriculture', 'environmental science', 'food industry/food processing'],
  farming: ['agriculture', 'environmental science'],
  crop: ['agriculture', 'environmental science'],
  farmer: ['agriculture', 'environmental science'],

  tailoring: ['apparel', 'handicrafts & carpets', 'persons with disability'],
  tailor: ['apparel', 'handicrafts & carpets'],
  sewing: ['apparel', 'handicrafts & carpets'],
  stitching: ['apparel', 'handicrafts & carpets'],
  cloth: ['apparel', 'handicrafts & carpets'],

  electrical: ['electronics & hw', 'power', 'capital goods & manufacturing', 'automotive'],
  electrician: ['electronics & hw', 'power'],
  wire: ['electronics & hw', 'power'],
  wiring: ['electronics & hw', 'power'],

  driving: ['transportation, logistics & warehousing', 'automotive'],
  driver: ['transportation, logistics & warehousing', 'automotive'],
  vehicle: ['transportation, logistics & warehousing', 'automotive'],

  retail: ['retail', 'bfsi', 'office administration & facility management'],
  sales: ['retail', 'bfsi', 'office administration & facility management'],
  shop: ['retail'],
  store: ['retail', 'transportation, logistics & warehousing'],

  cooking: ['tourism & hospitality', 'food industry/food processing', 'home management and caregiving'],
  cook: ['tourism & hospitality', 'food industry/food processing', 'home management and caregiving'],
  chef: ['tourism & hospitality'],
  food: ['food industry/food processing', 'tourism & hospitality'],

  construction: ['construction', 'plumbing', 'capital goods & manufacturing', 'infrastructure'],
  mason: ['construction'],
  building: ['construction'],

  plumbing: ['plumbing', 'water supply, sewerage, waste management & remediation activities', 'construction'],
  plumber: ['plumbing'],

  solar: ['environmental science', 'electronics & hw', 'power'],
  green: ['environmental science'],

  beauty: ['beauty & wellness', 'healthcare'],
  salon: ['beauty & wellness'],

  automobile: ['automotive', 'capital goods & manufacturing'],
  mechanic: ['automotive', 'capital goods & manufacturing', 'infrastructure'],

  handicraft: ['handicrafts & carpets', 'apparel'],
  craft: ['handicrafts & carpets'],

  logistics: ['transportation, logistics & warehousing'],
  warehouse: ['transportation, logistics & warehousing'],
  courier: ['transportation, logistics & warehousing'],

  security: ['private security', 'office administration & facility management'],
  guard: ['private security', 'office administration & facility management'],
};

// Multilingual Keyword Mapping
const MULTILINGUAL_KEYWORDS = {
  // Hindi
  'सिलाई': ['tailoring', 'sewing', 'stitching'],
  'दर्जी': ['tailor', 'apparel'],
  'कपड़े': ['cloth', 'apparel'],
  'खेती': ['farming', 'agriculture'],
  'किसान': ['farmer', 'agriculture'],
  'फसल': ['crop', 'agriculture'],
  'कृषि': ['agriculture'],
  'कंप्यूटर': ['computer', 'data'],
  'कम्प्यूटर': ['computer', 'data'],
  'टाइपिंग': ['typing', 'data'],
  'बिजली': ['electrical', 'electrician'],
  'वायरिंग': ['wiring', 'electrical'],
  'इलेक्ट्रिशियन': ['electrician', 'electrical'],
  'ड्राइविंग': ['driving', 'driver'],
  'चालक': ['driver'],
  'गाड़ी': ['vehicle', 'driving'],
  'नर्स': ['nursing', 'healthcare'],
  'अस्पताल': ['hospital', 'healthcare'],
  'मरीज़': ['patient', 'healthcare'],
  'दवा': ['medical', 'healthcare'],
  'रसोइया': ['cooking', 'cook'],
  'खाना': ['food', 'cooking'],
  'दुकान': ['shop', 'retail'],
  'बिक्री': ['sales', 'retail'],
  'राजमिस्त्री': ['mason', 'construction'],
  'निर्माण': ['construction'],
  'मकान': ['building', 'construction'],
  'ब्यूटी': ['beauty', 'salon'],

  // Bengali
  'সেলাই': ['tailoring', 'sewing', 'stitching'],
  'দর্জি': ['tailor', 'apparel'],
  'কাপড়': ['cloth', 'apparel'],
  'চাষ': ['farming', 'agriculture'],
  'কৃষি': ['agriculture'],
  'কৃষক': ['farmer', 'agriculture'],
  'ফসল': ['crop', 'agriculture'],
  'কম্পিউটার': ['computer', 'data'],
  'টাইপিং': ['typing', 'data'],
  'বিদ্যুৎ': ['electrical'],
  'ইলেক্ট্রিশিয়ান': ['electrician', 'electrical'],
  'ড্রাইভার': ['driver', 'driving'],
  'ড্রাইভিং': ['driving'],
  'নার্স': ['nursing', 'healthcare'],
  'হাসপাতাল': ['hospital', 'healthcare'],
  'রোগী': ['patient', 'healthcare'],
  'ওষুধ': ['medical', 'healthcare'],
  'রান্না': ['cooking', 'cook'],
  'বাবুর্চি': ['cook', 'chef'],
  'দোকান': ['shop', 'retail'],
  'বিক্রি': ['sales', 'retail'],
  'নির্মাণ': ['construction'],
  'প্লাম্বার': ['plumber', 'plumbing'],
  'বিউটি': ['beauty', 'salon'],
};

// Multilingual Prompt Explanations
const LOCALIZED_EXPLANATIONS = {
  hi: {
    title: 'आपके लिए आधिकारिक NSQF-संरेखित प्रशिक्षण सिफारिशें:',
    why: 'यह पाठ्यक्रम आपकी प्रोफ़ाइल, कौशल, रुचि और शैक्षिक योग्यता के आधार पर चुना गया है।',
    noMatch: 'आपकी वर्तमान खोज के लिए कोई सटीक NSQF पाठ्यक्रम नहीं मिला। यहाँ कुछ निकटतम उपलब्ध विकल्प दिए गए हैं:',
  },
  bn: {
    title: 'আপনার জন্য সরকারি এনএসকিউএফ-অনুমোদিত প্রশিক্ষণ সুপারিশ:',
    why: 'এই কোর্সটি আপনার প্রোফাইল, দক্ষতা, আগ্রহ এবং শিক্ষাগত যোগ্যতার ওপর ভিত্তি করে নির্বাচন করা হয়েছে।',
    noMatch: 'আপনার প্রশ্নের সাথে হুবহু মিলে যাওয়া এনএসকিউএফ কোর্স পাওয়া যায়নি। নিচে উপলব্ধ নিকটতম বিকল্পগুলি দেওয়া হলো:',
  },
  mr: {
    title: 'तुमच्यासाठी अधिकृत NSQF-संरेखित प्रशिक्षण शिफारसी:',
    why: 'हा कोर्स तुमच्या प्रोफाइल, कौशल्ये, आवड आणि शैक्षणिक पात्रतेवर आधारित निवडला गेला आहे.',
    noMatch: 'तुमच्या शोधानुसार कोणताही अचूक NSQF कोर्स सापडला नाही. खाली उपलब्ध जवळचे पर्याय दिले आहेत:',
  },
  te: {
    title: 'మీ కోసం అధికారిక NSQF-ఆమోదించిన శిక్షణ సిఫార్సులు:',
    why: 'మీ ప్రొఫైల్, నైపుణ్యాలు, ఆసక్తులు మరియు విద్యా అర్హత ఆధారంగా ఈ కోర్సు ఎంపిక చేయబడింది.',
    noMatch: 'మీ శోధనకు తగిన సరిగ్గా సరిపోయే NSQF కోర్సు కనుగొనబడలేదు. కొన్ని సమీప ప్రత్యామ్నాయాలు ఇక్కడ ఉన్నాయి:',
  },
  ta: {
    title: 'உங்களுக்கான அதிகாரப்பூர்வ NSQF பயிற்சி பரிந்துரைகள்:',
    why: 'உங்கள் சுயவிவரம், திறன்கள், ஆர்வங்கள் மற்றும் கல்வித் தகுதியின் அடிப்படையில் இந்த பாடநெறி தேர்ந்தெடுக்கப்பட்டது.',
    noMatch: 'உங்கள் தேடலுக்கு சரியான NSQF பயிற்சி கிடைக்கவில்லை. இதோ சில சிறந்த மாற்று தேர்வுகள்:',
  },
  ur: {
    title: 'آپ کے لیے سرکاری طور پر منظور شدہ NSQF تربیتی کورسز:',
    why: 'یہ کورس آپ کے پروفائل، مہارتوں، دلچسپیوں اور تعلیمی قابلیت کی بنیاد پر منتخب کیا گیا ہے۔',
    noMatch: 'آپ کی تلاش سے بالکل مماثل کوئی NSQF کورس نہیں ملا۔ یہاں چند بہترین متبادل کورسز موجود ہیں:',
  },
  en: {
    title: 'Recommended Official NSQF Training Courses For You:',
    why: 'This course matches your profile, skills, career goals, and educational qualification pathway.',
    noMatch: 'No exact NSQF training matches found for this specific query. Here are the closest available official NSQF alternatives:',
  },
};

/**
 * Main NSQF Matching Algorithm
 */
function matchNsqfTrainings({ profile = {}, queryText = '', limit = 4 }) {
  let combinedText = `${queryText} ${profile.skills || ''} ${profile.interests || ''} ${profile.currentOccupation || ''} ${profile.livelihood || ''} ${profile.careerGoal || ''} ${profile.education || ''}`.toLowerCase();

  // Translate multilingual keywords to English search keys
  for (const [nativeKey, englishKeys] of Object.entries(MULTILINGUAL_KEYWORDS)) {
    if (combinedText.includes(nativeKey)) {
      combinedText += ' ' + englishKeys.join(' ');
    }
  }

  const tokens = combinedText.match(/[a-z0-9]+/g) || [];
  const stateLoc = (profile.state || '').toLowerCase();
  const districtLoc = (profile.district || '').toLowerCase();

  const scoredRecords = [];

  for (const row of nsqfDataset) {
    if (!row || !row.Title) continue;

    let score = 25; // base score

    const title = (row.Title || '').toLowerCase();
    const description = (row.Description || '').toLowerCase();
    const sector = (row['Sector Name'] || '').toLowerCase();
    const occupation = (row['Proposed Occupation'] || '').toLowerCase();
    const awardingBody = (row['Awarding Body'] || '').toLowerCase();
    const levelStr = row.Level || '';

    // 1. Direct Keyword Matching (Title 20pts, Occupation 15pts, Sector 12pts, Description 5pts)
    for (const token of tokens) {
      if (token.length < 3) continue;
      if (title.includes(token)) score += 20;
      if (occupation.includes(token)) score += 15;
      if (sector.includes(token)) score += 12;
      if (description.includes(token)) score += 5;
    }

    // 2. Sector Synonym Boost (25pts)
    for (const [key, mappedSectors] of Object.entries(SECTOR_SYNONYMS)) {
      if (combinedText.includes(key)) {
        for (const sec of mappedSectors) {
          if (sector.includes(sec)) score += 25;
        }
      }
    }

    // 3. Education / NSQF Level Alignment
    const edu = (profile.education || profile.highestQualification || '').toLowerCase();
    if (edu.includes('10th') || edu.includes('12th')) {
      if (levelStr.includes('3') || levelStr.includes('4')) score += 12;
    } else if (edu.includes('graduate') || edu.includes('degree')) {
      if (levelStr.includes('5') || levelStr.includes('6')) score += 15;
    } else if (edu.includes('8th') || edu.includes('below')) {
      if (levelStr.includes('2') || levelStr.includes('3')) score += 10;
    }

    // 4. Location / Board Alignment
    if (stateLoc.includes('bengal') && (awardingBody.includes('west bengal') || description.includes('bengal'))) score += 15;
    if (stateLoc.includes('kerala') && awardingBody.includes('kerala')) score += 15;
    if (stateLoc.includes('haryana') && awardingBody.includes('hartron')) score += 15;
    if (districtLoc && description.includes(districtLoc)) score += 10;

    // Normalize final match percentage between 68% and 98%
    const matchPercent = Math.min(98, Math.max(68, Math.round(score)));

    if (score > 32) {
      scoredRecords.push({
        sNo: row['S No.'],
        title: row.Title,
        code: row.Code || 'NSQF-GOV-COURSE',
        description: row.Description || '',
        sectorName: row['Sector Name'] || 'Skill Development',
        level: row.Level || 'Level 3',
        nsqfLevel: parseInt((row.Level || '3').replace(/\D/g, '')) || 3,
        duration: row['Maximum Notational Hours'] || row['Minimum Notational Hours'] || '300 Hours',
        awardingBody: row['Awarding Body'] || 'National Skill Development Corporation',
        certifyingBodies: row['Certifying Bodies'] || 'NSDC',
        proposedOccupation: row['Proposed Occupation'] || row.Title,
        progressionPathway: row['Progression Pathway'] || 'Career Advancement',
        matchPercent,
      });
    }
  }

  // Sort descending by match percentage
  scoredRecords.sort((a, b) => b.matchPercent - a.matchPercent);

  // If no specific match found, return top 4 diverse high-quality NSQF courses as default options
  if (scoredRecords.length === 0) {
    const defaultIndices = [0, 4, 10, 15]; // Diverse default records from dataset
    return defaultIndices.map((i) => {
      const row = nsqfDataset[i];
      return {
        sNo: row['S No.'],
        title: row.Title,
        code: row.Code || 'NSQF-GOV-COURSE',
        description: row.Description || '',
        sectorName: row['Sector Name'] || 'Skill Development',
        level: row.Level || 'Level 3',
        nsqfLevel: parseInt((row.Level || '3').replace(/\D/g, '')) || 3,
        duration: row['Maximum Notational Hours'] || '300 Hours',
        awardingBody: row['Awarding Body'] || 'NSDC',
        certifyingBodies: row['Certifying Bodies'] || 'NSDC',
        proposedOccupation: row['Proposed Occupation'] || row.Title,
        progressionPathway: row['Progression Pathway'] || 'Career Growth',
        matchPercent: 75,
      };
    });
  }

  return scoredRecords.slice(0, limit);
}

/**
 * Builds AI Assistant Response text in the user's selected language, incorporating exact NSQF records.
 */
function buildNsqfChatResponse(profile, userMessage, languageCode) {
  const lang = (languageCode || 'en').toLowerCase().trim();
  const text = (userMessage || '').toLowerCase();

  const matches = matchNsqfTrainings({ profile, queryText: userMessage, limit: 4 });

  const loc = LOCALIZED_EXPLANATIONS[lang] || LOCALIZED_EXPLANATIONS.en;
  let reply = `${loc.title}\n\n`;

  matches.forEach((item, idx) => {
    reply += `${idx + 1}. **${item.title}** (${item.level} · ${item.duration})\n`;
    reply += `   • **Sector**: ${item.sectorName}\n`;
    reply += `   • **Awarding Body**: ${item.awardingBody}\n`;
    reply += `   • **Pathway**: ${item.progressionPathway.split('\n')[0]}\n`;
    reply += `   • **Match**: ${item.matchPercent}%\n\n`;
  });

  reply += `${loc.why}`;

  return {
    reply: reply.trim(),
    matchedTrainings: matches,
  };
}

module.exports = {
  nsqfDataset,
  matchNsqfTrainings,
  buildNsqfChatResponse,
};
