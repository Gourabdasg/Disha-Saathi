/**
 * nlpEngine.js — Disha Saathi Natural Language Processing (NLP) Engine
 * SIH 2026 · PS 26097 · Team: The AI Alchemists
 *
 * Provides multilingual intent classification, entity extraction, and
 * NSQF skill-matching over NSQF_Training_Recommendation.js.
 */

const { matchNsqfTrainings } = require('./nsqfMatcher');

const SKILL_DICTIONARY = [
  { key: 'tailoring', keywords: ['सिलाई', 'दर्जी', 'कपड़े', 'tailor', 'sewing', 'stitching'] },
  { key: 'agriculture', keywords: ['खेती', 'किसान', 'फसल', 'কৃষি', 'farmer', 'crop'] },
  { key: 'computer', keywords: ['कंप्यूटर', 'टाइपिंग', 'data entry', 'excel', 'word'] },
  { key: 'electrical', keywords: ['बिजली', 'वायरिंग', 'electrician', 'wiring'] },
  { key: 'driving', keywords: ['ड्राइविंग', 'गाड़ी', 'चालक', 'driver'] },
  { key: 'retail', keywords: ['दुकान', 'बिक्री', 'retail', 'sales'] },
  { key: 'healthcare', keywords: ['नर्स', 'अस्पताल', 'nursing', 'patient', 'hospital'] },
  { key: 'construction', keywords: ['राजमिस्त्री', 'निर्माण', 'mason', 'construction', 'plumbing'] },
];

function parseNaturalLanguage(text) {
  if (!text || typeof text !== 'string') {
    return {
      text: '',
      language: 'en',
      intent: 'UNKNOWN',
      extractedSkills: [],
      education: null,
      location: null,
      entities: {},
    };
  }

  const raw = text.trim();
  const lower = raw.toLowerCase();

  let language = 'en';
  if (/[\u0900-\u097F]/.test(raw)) {
    language = 'hi';
  } else if (/[\u0980-\u09FF]/.test(raw)) {
    language = 'bn';
  } else if (/\b(mera|meri|naam|karta|kam|hu|rahta|hoon|chahiye|sikhna)\b/i.test(lower)) {
    language = 'hinglish';
  }

  let intent = 'GENERAL';
  if (/^\s*(hi+|hello+|namaste|namaskar|hey)\b/i.test(lower) || /^(नमस्ते|नमस्कार|हेलो)\b/.test(raw)) {
    intent = 'GREETING';
  } else if (/\b(recommend|job|course|skill|work|काउन्सिलिंग|नौकरी|कोर्स)\b/i.test(lower)) {
    intent = 'SKILL_INQUIRY';
  }

  const extractedSkills = [];
  for (const item of SKILL_DICTIONARY) {
    for (const kw of item.keywords) {
      if (lower.includes(kw)) {
        if (!extractedSkills.includes(item.key)) {
          extractedSkills.push(item.key);
        }
        break;
      }
    }
  }

  let education = null;
  if (/\b(10th|class 10|दसवीं|मैट्रिक|ssc)\b/i.test(lower)) {
    education = '10th Pass';
  } else if (/\b(12th|class 12|बारहवीं|inter|hsc)\b/i.test(lower)) {
    education = '12th Pass';
  } else if (/\b(graduate|degree|ba|bsc|bcom|बीए|ग्रेजुएट)\b/i.test(lower)) {
    education = 'Graduate';
  } else if (/\b(8th|eighth|आठवीं)\b/i.test(lower)) {
    education = '8th Pass';
  }

  let location = null;
  const locationMatch = raw.match(/\b(barasat|kolkata|delhi|mumbai|patna|ranchi|lucknow|jaipur|bengal|bihar|up)\b/i);
  if (locationMatch) {
    location = locationMatch[0];
  }

  return {
    text: raw,
    language,
    intent,
    extractedSkills,
    education,
    location,
    entities: {
      skills: extractedSkills,
      education,
      location,
    },
  };
}

function matchNsqfSkills(profileData) {
  return matchNsqfTrainings({ profile: profileData, limit: 4 });
}

module.exports = {
  SKILL_DICTIONARY,
  parseNaturalLanguage,
  matchNsqfSkills,
};
