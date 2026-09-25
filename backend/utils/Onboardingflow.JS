/**
 * onboardingFlow.js — Disha Saathi AI Onboarding & Conversation Flow
 * SIH 2026 · PS 26097 · Team: The AI Alchemists
 */

const { parseNaturalLanguage } = require('./nlpEngine');
const nsqfDataset = require('../data/NSQF_Training_Recommendation');

// ---------------------------------------------------------------------------
// 1. Field definitions (canonical 14-step order)
// ---------------------------------------------------------------------------
const FIELD_ORDER = [
  {
    key: 'name',
    label: 'Name',
    question: () => `Hello! 👋 Welcome to Disha Saathi. May I know your name?`,
  },
  {
    key: 'age',
    label: 'Age',
    question: (p) =>
      p.name
        ? `Nice to meet you, ${p.name}! What is your age?`
        : `What is your age?`,
  },
  {
    key: 'state',
    label: 'State',
    question: () => `Which state are you currently from?`,
  },
  {
    key: 'district',
    label: 'District',
    question: () => `Which district are you from?`,
  },
  {
    key: 'location',
    label: 'Location',
    question: () => `What is your current location (city/town/village)?`,
  },
  {
    key: 'education',
    label: 'Education',
    question: () => `What is your highest or current level of education?`,
  },
  {
    key: 'currentOccupation',
    label: 'Current Occupation',
    question: () => `What is your current occupation or livelihood work?`,
  },
  {
    key: 'familyOccupation',
    label: 'Family Occupation',
    question: () => `What is your family's occupation?`,
  },
  {
    key: 'skills',
    label: 'Skills',
    question: () => `What are your main work skills?`,
  },
  {
    key: 'experience',
    label: 'Experience',
    question: () => `Do you have any previous work or internship experience?`,
  },
  {
    key: 'interests',
    label: 'Interests',
    question: () => `What are your main career interests?`,
  },
  {
    key: 'employmentPreference',
    label: 'Employment Preference',
    question: () => `What type of employment are you looking for (e.g. full-time, part-time, self-employed, government job)?`,
  },
  {
    key: 'mobilityConstraints',
    label: 'Mobility Constraints',
    question: () => `Do you have any mobility constraints or relocation limits?`,
  },
  {
    key: 'careerGoal',
    label: 'Career Goal',
    question: () => `What is your main career goal?`,
  },
];

const FIELD_KEYS = FIELD_ORDER.map((f) => f.key);

// ---------------------------------------------------------------------------
// 2. Greeting detection
// ---------------------------------------------------------------------------
const GREETING_REGEX =
  /^\s*(hi+|hello+|hey+|hii+|yo|namaste|namaskar|good\s*morning|good\s*afternoon|good\s*evening)\s*[!.,]*\s*$/i;

function detectGreeting(message) {
  if (!message) return false;
  return GREETING_REGEX.test(message.trim());
}

// ---------------------------------------------------------------------------
// 3. Smart Field Extractor
// ---------------------------------------------------------------------------

function ruleBasedExtract(message, expectedKey) {
  const result = {};
  const text = (message || '').trim();
  if (!text) return result;

  // Strict handling for expected field currently being asked
  if (expectedKey === 'name') {
    const explicitNameMatch = text.match(/\b(?:my name is|i am|mera naam|naam)\s+([a-zA-Z\u0900-\u097F. ]{2,25})\b/i);
    if (explicitNameMatch && explicitNameMatch[1]) {
      result.name = explicitNameMatch[1].trim();
    } else {
      const looksLikeWorkOrSkill = /\b(काम|खेती|सिलाई|दूकान|pass|know|working|job|study|10th|12th)\b/i.test(text);
      if (!looksLikeWorkOrSkill && text.length <= 25 && !/\d/.test(text)) {
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
// 4. Step helpers
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

function getQuestionFor(field, profile) {
  return field.question(profile);
}

// ---------------------------------------------------------------------------
// 5. Job Recommendation & NSQF Training Matching Decision Engine
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

function buildSummary(profile) {
  const displayName = profile.name || 'Friend';
  const jobRole = recommendJobRole(profile);

  let responseText = `Thank you, ${displayName}! 🎉 I have completed your profile assessment.\n\n`;

  responseText += `🎯 **Recommended Career Role:**\n`;
  responseText += `**${jobRole.title}** (Sector: ${jobRole.sector})\n\n`;

  responseText += `📚 **Recommended Official NSQF Training Courses:**\n\n`;

  const topNsqf = searchNsqfRecommendations(profile, 4);
  topNsqf.forEach((rec, idx) => {
    responseText += `${idx + 1}. **${rec.Title}** (${rec.Level || 'NSQF Level 3'})\n`;
    responseText += `   • **Sector**: ${rec['Sector Name'] || 'Skill Development'}\n`;
    responseText += `   • **Course Code**: ${rec.Code || 'NSQF-GOV-COURSE'}\n`;
    responseText += `   • **Duration**: ${rec['Minimum Notational Hours'] || rec['Maximum Notational Hours'] || '300 Hours'}\n`;
    responseText += `   • **Awarding Body**: ${rec['Awarding Body'] || 'NSDC'}\n`;
    if (rec['Proposed Occupation']) {
      responseText += `   • **Career Pathway**: ${rec['Proposed Occupation']}\n`;
    }
    responseText += `\n`;
  });

  responseText += `💡 **Reason for Recommendation:**\n`;
  responseText += `Your education (${profile.education || '10th/12th'}), skills (${profile.skills || 'practical'}), interests (${profile.interests || 'vocational'}), and career goal (${profile.careerGoal || jobRole.title}) match the requirements of these official NSQF certified training courses.`;

  return responseText.trim();
}

module.exports = {
  FIELD_ORDER,
  FIELD_KEYS,
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
