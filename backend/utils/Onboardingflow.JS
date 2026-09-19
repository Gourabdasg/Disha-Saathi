/**
 * onboardingFlow.js — Disha Saathi AI Onboarding & Conversation Flow
 * SIH 2026 · PS 26097 · Team: The AI Alchemists
 */

const { parseNaturalLanguage } = require('./nlpEngine');
const nsqfDataset = require('../data/NSQF_Training_Recommendation');

// ---------------------------------------------------------------------------
// 1. Field definitions (canonical order)
// ---------------------------------------------------------------------------
const FIELD_ORDER = [
  {
    key: 'name',
    label: 'Name',
    question: () => `Hello! 👋 Welcome. May I know your name?`,
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
    question: () => `What are your main work skills or interests?`,
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
// 3. Smart NLP Entity & Field Extractor
// ---------------------------------------------------------------------------

function ruleBasedExtract(message, expectedKey) {
  const result = {};
  const text = (message || '').trim();
  if (!text) return result;

  const nlp = parseNaturalLanguage(text);

  // Volunteer Extraction across all fields
  if (nlp.education) result.education = nlp.education;
  if (nlp.location) result.location = nlp.location;
  if (nlp.extractedSkills && nlp.extractedSkills.length > 0) {
    result.skills = nlp.extractedSkills.join(', ');
    result.currentOccupation = text;
  }

  // Strict handling for expected field
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
    const ageMatch = cleanTextForAge.match(/\b(\d{2})\b/);
    if (ageMatch) {
      const num = parseInt(ageMatch[1], 10);
      if (num >= 15 && num <= 80) {
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
// 5. NSQF Dataset Matcher & Final Summary
// ---------------------------------------------------------------------------

function searchNsqfRecommendations(profile, limit = 3) {
  if (!Array.isArray(nsqfDataset) || nsqfDataset.length === 0) return [];

  const queryTerms = [
    profile.careerGoal,
    profile.skills,
    profile.education,
    profile.currentOccupation,
    profile.interests,
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

  // If top items scored 0 (no specific term matched), pick 3 diverse popular Level 3/4 courses
  if (scored.length > 0 && scored[0].score === 0) {
    return [nsqfDataset[0], nsqfDataset[1], nsqfDataset[4]];
  }

  return scored.slice(0, limit).map((s) => s.item);
}

function buildSummary(profile) {
  const parts = [];
  const displayName = profile.name || 'Friend';

  if (profile.education) parts.push(profile.education);
  if (profile.skills) parts.push(`skilled in ${profile.skills}`);
  if (profile.currentOccupation) parts.push(`with experience in ${profile.currentOccupation}`);

  let descriptor = parts.length
    ? `You are ${parts.join(', ')}`
    : `I've noted your profile information`;

  let responseText = `Thanks, ${displayName}! I've captured your career profile. ${descriptor}.\n\n`;

  const topNsqf = searchNsqfRecommendations(profile, 3);
  if (topNsqf && topNsqf.length > 0) {
    responseText += `🎯 Recommended NSQF Skill Training Options for You:\n\n`;
    topNsqf.forEach((rec, idx) => {
      responseText += `${idx + 1}. ${rec.Title} (${rec.Level || 'NSQF'})\n`;
      responseText += `   • Sector: ${rec['Sector Name'] || 'Skill Development'}\n`;
      responseText += `   • Duration: ${rec['Minimum Notational Hours'] || rec['Maximum Notational Hours'] || '300 Hours'}\n`;
      if (rec['Proposed Occupation']) {
        responseText += `   • Career: ${rec['Proposed Occupation']}\n`;
      }
      responseText += `\n`;
    });
  }

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
  buildSummary,
  searchNsqfRecommendations,
};
