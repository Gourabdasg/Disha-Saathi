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
// 5. NSQF Dataset Matcher & Final Summary
// ---------------------------------------------------------------------------

function searchNsqfRecommendations(profile, limit = 4) {
  if (!Array.isArray(nsqfDataset) || nsqfDataset.length === 0) return [];

  const queryTerms = [
    profile.careerGoal,
    profile.skills,
    profile.interests,
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
  const parts = [];
  const displayName = profile.name || 'Friend';

  if (profile.education) parts.push(profile.education);
  if (profile.skills) parts.push(`skilled in ${profile.skills}`);
  if (profile.currentOccupation) parts.push(`working as ${profile.currentOccupation}`);
  if (profile.careerGoal) parts.push(`aiming for ${profile.careerGoal}`);

  let descriptor = parts.length
    ? `You are ${parts.join(', ')}`
    : `I've recorded your profile information`;

  let responseText = `Thank you, ${displayName}! 🎉 I have completed your profile assessment.\n${descriptor}.\n\n`;

  const topNsqf = searchNsqfRecommendations(profile, 4);
  if (topNsqf && topNsqf.length > 0) {
    responseText += `🎯 Recommended Official NSQF Training Courses For You:\n\n`;
    topNsqf.forEach((rec, idx) => {
      responseText += `${idx + 1}. **${rec.Title}** (${rec.Level || 'NSQF Level 3'})\n`;
      responseText += `   • **Sector**: ${rec['Sector Name'] || 'Skill Development'}\n`;
      responseText += `   • **Duration**: ${rec['Minimum Notational Hours'] || rec['Maximum Notational Hours'] || '300 Hours'}\n`;
      if (rec['Proposed Occupation']) {
        responseText += `   • **Career**: ${rec['Proposed Occupation']}\n`;
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
