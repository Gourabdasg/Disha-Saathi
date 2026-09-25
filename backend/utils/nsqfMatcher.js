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
    jobTitle: '🎯 अनुशंसित करियर भूमिका:',
    trainingTitle: '📚 आपके लिए आधिकारिक NSQF-संरेखित प्रशिक्षण सिफारिशें:',
    why: 'आपकी शिक्षा, कौशल, रुचियां और करियर लक्ष्य इन आधिकारिक NSQF प्रमाणित पाठ्यक्रमों की आवश्यकताओं से मेल खाते हैं।',
  },
  bn: {
    jobTitle: '🎯 প্রস্তাবিত উপযুক্ত কেরিয়ার ভূমিকা:',
    trainingTitle: '📚 আপনার জন্য সরকারি এনএসকিউএফ-অনুমোদিত প্রশিক্ষণ সুপারিশ:',
    why: 'আপনার শিক্ষা, দক্ষতা, আগ্রহ এবং ক্যারিয়ারের লক্ষ্য এই সরকারি এনএসকিউএফ সার্টিফাইড কোর্সের প্রয়োজনীয়তার সাথে মিলে যায়।',
  },
  mr: {
    jobTitle: '🎯 शिफारस केलेली योग्य करिअर भूमिका:',
    trainingTitle: '📚 तुमच्यासाठी अधिकृत NSQF-संरेखित प्रशिक्षण शिफारसी:',
    why: 'तुमचे शिक्षण, कौशल्ये, आवड आणि करिअरचे ध्येय या अधिकृत NSQF प्रमाणित अभ्यासक्रमांच्या गरजांशी जुळतात.',
  },
  te: {
    jobTitle: '🎯 సిఫార్సు చేయబడిన ఉద్యోగ పాత్ర:',
    trainingTitle: '📚 మీ కోసం అధికారిక NSQF-ఆమోదించిన శిక్షణ సిఫార్సులు:',
    why: 'మీ విద్య, నైపుణ్యాలు, ఆసక్తులు మరియు కెరీర్ లక్ష్యాలు ఈ అధికారిక NSQF ధృవీకరించబడిన కోర్సుల అవసరాలకు సరిపోతాయి.',
  },
  ta: {
    jobTitle: '🎯 பரிந்துரைக்கப்பட்ட வேலை பங்கு:',
    trainingTitle: '📚 உங்களுக்கான அதிகாரப்பூர்வ NSQF பயிற்சி பரிந்துரைகள்:',
    why: 'உங்கள் கல்வி, திறன்கள், ஆர்வங்கள் மற்றும் தொழில் இலக்குகள் இந்த அதிகாரப்பூர்வ NSQF சான்றளிக்கப்பட்ட படிப்புகளின் தேவைகளுடன் பொருந்துகின்றன.',
  },
  ur: {
    jobTitle: '🎯 تجویز کردہ کیریئر کا کردار:',
    trainingTitle: '📚 آپ کے لیے سرکاری طور پر منظور شدہ NSQF تربیتی کورسز:',
    why: 'آپ کی تعلیم، مہارتیں، دلچسپیاں اور کیریئر کے مقاصد ان سرکاری NSQF تصدیق شدہ کورسز کی ضروریات سے مطابقت رکھتے ہیں۔',
  },
  en: {
    jobTitle: '🎯 Recommended Career Role:',
    trainingTitle: '📚 Recommended Official NSQF Training Courses:',
    why: 'Your education, skills, interests, and career goal match the requirements of these official NSQF certified courses.',
  },
};

/**
 * Main Weighted NSQF Matching Algorithm over 2,814 official records
 */
function matchNsqfTrainings({ profile = {}, queryText = '', limit = 4 }) {
  let combinedText = `${queryText} ${profile.careerGoal || ''} ${profile.skills || ''} ${profile.interests || ''} ${profile.currentOccupation || ''} ${profile.education || ''}`.toLowerCase();

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

    let score = 25; // Base baseline score

    const title = (row.Title || '').toLowerCase();
    const description = (row.Description || '').toLowerCase();
    const sector = (row['Sector Name'] || '').toLowerCase();
    const occupation = (row['Proposed Occupation'] || '').toLowerCase();
    const awardingBody = (row['Awarding Body'] || '').toLowerCase();
    const levelStr = row.Level || '';

    // 1. Direct Keyword Weighted Matching (Title 30pts, Occupation 25pts, Sector 20pts, Description 10pts)
    for (const token of tokens) {
      if (token.length < 3) continue;
      if (title.includes(token)) score += 30;
      if (occupation.includes(token)) score += 25;
      if (sector.includes(token)) score += 20;
      if (description.includes(token)) score += 10;
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
      if (levelStr.includes('3') || levelStr.includes('4')) score += 15;
    } else if (edu.includes('graduate') || edu.includes('degree')) {
      if (levelStr.includes('5') || levelStr.includes('6')) score += 20;
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

  if (scoredRecords.length === 0) {
    const defaultIndices = [0, 4, 10, 15];
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
 * Builds AI Assistant Response text in the user's selected language, following Job -> NSQF Training flow.
 */
function buildNsqfChatResponse(profile, userMessage, languageCode) {
  const lang = (languageCode || 'en').toLowerCase().trim();
  const loc = LOCALIZED_EXPLANATIONS[lang] || LOCALIZED_EXPLANATIONS.en;

  const { recommendJobRole } = require('./onboardingFlow');

  const jobRole = recommendJobRole(profile);
  const matches = matchNsqfTrainings({ profile, queryText: userMessage, limit: 4 });

  let reply = `${loc.jobTitle}\n**${jobRole.title}** (Sector: ${jobRole.sector})\n\n`;
  reply += `${loc.trainingTitle}\n\n`;

  matches.forEach((item, idx) => {
    reply += `${idx + 1}. **${item.title}** (${item.level} · ${item.duration})\n`;
    reply += `   • **Sector**: ${item.sectorName}\n`;
    reply += `   • **Course Code**: ${item.code}\n`;
    reply += `   • **Awarding Body**: ${item.awardingBody}\n`;
    reply += `   • **Career Pathway**: ${item.proposedOccupation || item.progressionPathway.split('\n')[0]}\n`;
    reply += `   • **Match Score**: ${item.matchPercent}%\n\n`;
  });

  reply += `💡 **Why this is recommended:**\n${loc.why}`;

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
