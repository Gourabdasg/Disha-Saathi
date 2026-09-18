/**
 * nlpEngine.js — Disha Saathi Natural Language Processing (NLP) Engine
 * SIH 2026 · PS 26097 · Team: The AI Alchemists
 *
 * Provides multilingual intent classification, entity extraction, and
 * NSQF skill-matching for Hindi (Devanagari & Hinglish), Bengali, and English.
 */

// ---------------------------------------------------------------------------
// 1. Multilingual Skill & Domain Dictionaries
// ---------------------------------------------------------------------------
const SKILL_DICTIONARY = [
  {
    key: 'tailoring',
    keywords: ['सिलाई', 'दर्जी', 'कपड़े', 'कपड़ा', 'tailor', 'tailoring', 'sewing', 'stitching', 'cloth'],
    nsqfRole: 'Self Employed Tailor',
    nsqfLevel: 4,
    duration: '3 months',
    skillsToLearn: ['Pattern Making', 'Machine Operation', 'Garment Fitting', 'Quality Check'],
  },
  {
    key: 'agriculture',
    keywords: ['खेती', 'किसान', 'फसल', 'कृषि', 'farming', 'farmer', 'agriculture', 'crop', 'cultivation'],
    nsqfRole: 'Organic Grower / Micro-Irrigation Technician',
    nsqfLevel: 3,
    duration: '2.5 months',
    skillsToLearn: ['Soil Health Management', 'Organic Fertilizers', 'Drip Irrigation', 'Crop Protection'],
  },
  {
    key: 'computer',
    keywords: ['कंप्यूटर', 'कम्प्यूटर', 'टाइपिंग', 'डाटा', 'data entry', 'computer', 'typing', 'ms office', 'excel', 'word'],
    nsqfRole: 'Domestic Data Entry Operator',
    nsqfLevel: 3,
    duration: '2 months',
    skillsToLearn: ['Speed Typing', 'Data Accuracy', 'MS Excel Basics', 'Internet Operations'],
  },
  {
    key: 'electrical',
    keywords: ['बिजली', 'वायरिंग', 'इलेक्ट्रिशियन', 'electrician', 'electric', 'wiring', 'repair', 'fan repair'],
    nsqfRole: 'Assistant Electrician',
    nsqfLevel: 3,
    duration: '3 months',
    skillsToLearn: ['Electrical Safety', 'House Wiring', 'Circuit Testing', 'Appliance Repair'],
  },
  {
    key: 'driving',
    keywords: ['ड्राइविंग', 'गाड़ी', 'चालक', 'driver', 'driving', 'car', 'vehicle', 'auto'],
    nsqfRole: 'Commercial Taxi / Commercial Driver',
    nsqfLevel: 3,
    duration: '1.5 months',
    skillsToLearn: ['Traffic Regulations', 'Vehicle Maintenance', 'Defensive Driving', 'GPS Navigation'],
  },
  {
    key: 'retail',
    keywords: ['दुकान', 'बिक्री', 'रिटेल', 'कस्टमर', 'retail', 'sales', 'shop', 'store', 'customer service'],
    nsqfRole: 'Retail Sales Associate',
    nsqfLevel: 2,
    duration: '1.5 months',
    skillsToLearn: ['Customer Engagement', 'Product Display', 'POS Operations', 'Inventory Check'],
  },
  {
    key: 'healthcare',
    keywords: ['नर्स', 'अस्पताल', 'मरीज़', 'दवा', 'nursing', 'patient', 'healthcare', 'hospital', 'medical assistant'],
    nsqfRole: 'General Duty Assistant (Healthcare)',
    nsqfLevel: 4,
    duration: '4 months',
    skillsToLearn: ['Patient Hygiene', 'Vital Signs Check', 'First Aid', 'Hospital Infection Control'],
  },
  {
    key: 'construction',
    keywords: ['राजमिस्त्री', 'निर्माण', 'मकान', 'mason', 'construction', 'building', 'plumbing', 'plumber'],
    nsqfRole: 'Plumber / Assistant Mason',
    nsqfLevel: 3,
    duration: '2 months',
    skillsToLearn: ['Pipe Fitting', 'Measurement & Alignment', 'Leakage Repair', 'Safety Standards'],
  },
];

// ---------------------------------------------------------------------------
// 2. Multilingual Intent & Entity Extraction
// ---------------------------------------------------------------------------

/**
 * Parses user text or speech input to extract intents, skills, education,
 * locations, and language.
 */
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

  // Detect language
  let language = 'en';
  if (/[\u0900-\u097F]/.test(raw)) {
    language = 'hi'; // Hindi Devanagari
  } else if (/[\u0980-\u09FF]/.test(raw)) {
    language = 'bn'; // Bengali
  } else if (/\b(mera|meri|naam|karta|kam|hu|rahta|hoon|chahiye|sikhna)\b/i.test(lower)) {
    language = 'hinglish';
  }

  // Detect Intent
  let intent = 'GENERAL';
  if (/^\s*(hi+|hello+|namaste|namaskar|hey)\b/i.test(lower) || /^(नमस्ते|नमस्कार|हेलो)\b/.test(raw)) {
    intent = 'GREETING';
  } else if (/\b(recommend|job|course|skill|work|काउन्सिलिंग|नौकरी|कोर्स)\b/i.test(lower)) {
    intent = 'SKILL_INQUIRY';
  }

  // Extract Skills
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

  // Extract Education Level
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

  // Extract Location / City
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

// ---------------------------------------------------------------------------
// 3. NSQF Skill Matching Algorithm
// ---------------------------------------------------------------------------

/**
 * Matches candidate profile to official NSQF job roles and returns sorted list.
 */
function matchNsqfSkills(profileData) {
  const userSkills = profileData.existingSkills || [];
  const interests = profileData.careerInterests || [];
  const livelihood = profileData.livelihood || '';
  const textQuery = `${userSkills.join(' ')} ${interests.join(' ')} ${livelihood}`.toLowerCase();

  const results = SKILL_DICTIONARY.map((item) => {
    let score = 50; // base score

    // Boost score if keyword matches user's skills or interests
    for (const kw of item.keywords) {
      if (textQuery.includes(kw)) {
        score += 25;
        break;
      }
    }

    // Boost score for education compatibility
    if (profileData.education === '10th Pass' || profileData.education === '12th Pass') {
      score += 10;
    }

    // Cap match score between 65% and 98%
    const matchPercent = Math.min(98, Math.max(65, score));

    return {
      title: item.nsqfRole,
      matchPercent,
      nsqfLevel: item.nsqfLevel,
      duration: item.duration,
      skillsToLearn: item.skillsToLearn,
    };
  });

  // Sort descending by match percentage
  results.sort((a, b) => b.matchPercent - a.matchPercent);

  return results.slice(0, 4); // Top 4 recommendations
}

module.exports = {
  SKILL_DICTIONARY,
  parseNaturalLanguage,
  matchNsqfSkills,
};
