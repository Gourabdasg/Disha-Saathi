const { query } = require('../db');
const {
  FIELD_ORDER,
  detectGreeting,
  extractFieldsFromMessage,
  getMissingFields,
  getNextField,
  getQuestionFor,
  buildSummary,
} = require('../utils/onboardingFlow');

const inMemoryProfiles = new Map();

/**
 * Safely saves a profile doc to PostgreSQL user_profiles table.
 */
async function safeSaveProfile(profile) {
  try {
    const sql = `
      INSERT INTO user_profiles (
        mobile, name, age, state, district, location, education,
        current_occupation, family_occupation, skills, experience,
        interests, employment_preference, mobility_constraints, career_goal,
        onboarding_complete, current_step, updated_at
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, CURRENT_TIMESTAMP
      )
      ON CONFLICT (mobile) DO UPDATE SET
        name = CASE WHEN EXCLUDED.name <> '' THEN EXCLUDED.name ELSE user_profiles.name END,
        age = COALESCE(EXCLUDED.age, user_profiles.age),
        state = CASE WHEN EXCLUDED.state <> '' THEN EXCLUDED.state ELSE user_profiles.state END,
        district = CASE WHEN EXCLUDED.district <> '' THEN EXCLUDED.district ELSE user_profiles.district END,
        location = CASE WHEN EXCLUDED.location <> '' THEN EXCLUDED.location ELSE user_profiles.location END,
        education = CASE WHEN EXCLUDED.education <> '' THEN EXCLUDED.education ELSE user_profiles.education END,
        current_occupation = CASE WHEN EXCLUDED.current_occupation <> '' THEN EXCLUDED.current_occupation ELSE user_profiles.current_occupation END,
        family_occupation = CASE WHEN EXCLUDED.family_occupation <> '' THEN EXCLUDED.family_occupation ELSE user_profiles.family_occupation END,
        skills = CASE WHEN EXCLUDED.skills <> '' THEN EXCLUDED.skills ELSE user_profiles.skills END,
        experience = CASE WHEN EXCLUDED.experience <> '' THEN EXCLUDED.experience ELSE user_profiles.experience END,
        interests = CASE WHEN EXCLUDED.interests <> '' THEN EXCLUDED.interests ELSE user_profiles.interests END,
        employment_preference = CASE WHEN EXCLUDED.employment_preference <> '' THEN EXCLUDED.employment_preference ELSE user_profiles.employment_preference END,
        mobility_constraints = CASE WHEN EXCLUDED.mobility_constraints <> '' THEN EXCLUDED.mobility_constraints ELSE user_profiles.mobility_constraints END,
        career_goal = CASE WHEN EXCLUDED.career_goal <> '' THEN EXCLUDED.career_goal ELSE user_profiles.career_goal END,
        onboarding_complete = EXCLUDED.onboarding_complete,
        current_step = EXCLUDED.current_step,
        updated_at = CURRENT_TIMESTAMP;
    `;

    const values = [
      profile.mobile, profile.name || '', profile.age || null, profile.state || '',
      profile.district || '', profile.location || '', profile.education || '',
      profile.currentOccupation || '', profile.familyOccupation || '', profile.skills || '',
      profile.experience || '', profile.interests || '', profile.employmentPreference || '',
      profile.mobilityConstraints || '', profile.careerGoal || '',
      profile.onboardingComplete || false, profile.currentStep || 0,
    ];

    await query(sql, values);
  } catch (err) {
    console.warn('Profile save warning (handled):', err.message);
  }
}

/**
 * Resets the onboarding progress for a given mobile number or email in PostgreSQL.
 */
async function resetOnboarding(mobile) {
  const key = mobile || 'anonymous';
  if (inMemoryProfiles.has(key)) {
    inMemoryProfiles.delete(key);
  }
  try {
    await query(
      `UPDATE user_profiles SET onboarding_complete = FALSE, name = '', age = NULL, state = '', district = '', location = '', education = '', current_occupation = '', family_occupation = '', skills = '', experience = '', interests = '', employment_preference = '', mobility_constraints = '', career_goal = '' WHERE mobile = $1;`,
      [key]
    );
  } catch (e) {
    console.warn('DB onboarding reset warning:', e.message);
  }
}

/**
 * Fetches (or creates) the UserProfile doc for a given mobile number.
 */
async function getOrCreateProfile(mobile) {
  try {
    const res = await query(`SELECT * FROM user_profiles WHERE mobile = $1 LIMIT 1;`, [mobile]);
    if (res.rows && res.rows.length > 0) {
      const row = res.rows[0];
      return {
        mobile: row.mobile,
        name: row.name || '',
        age: row.age,
        state: row.state || '',
        district: row.district || '',
        location: row.location || '',
        education: row.education || '',
        currentOccupation: row.current_occupation || '',
        familyOccupation: row.family_occupation || '',
        skills: row.skills || '',
        experience: row.experience || '',
        interests: row.interests || '',
        employmentPreference: row.employment_preference || '',
        mobilityConstraints: row.mobility_constraints || '',
        careerGoal: row.career_goal || '',
        onboardingComplete: row.onboarding_complete || false,
        currentStep: row.current_step || 0,
        save: async function () {
          return safeSaveProfile(this);
        },
      };
    }

    // Create default profile in PostgreSQL
    await query(`INSERT INTO user_profiles (mobile) VALUES ($1) ON CONFLICT (mobile) DO NOTHING;`, [mobile]);
  } catch (e) {
    console.warn('DB profile fetch failed, falling back to in-memory:', e.message);
  }

  // In-memory fallback profile for demo mode / offline DB
  if (!inMemoryProfiles.has(mobile)) {
    inMemoryProfiles.set(mobile, {
      mobile,
      name: '',
      age: null,
      state: '',
      district: '',
      location: '',
      education: '',
      currentOccupation: '',
      familyOccupation: '',
      skills: '',
      experience: '',
      interests: '',
      employmentPreference: '',
      mobilityConstraints: '',
      careerGoal: '',
      onboardingComplete: false,
      currentStep: null,
      save: async function () {
        return safeSaveProfile(this);
      },
    });
  }
  return inMemoryProfiles.get(mobile);
}

/**
 * Main entry point for conversational onboarding assessment.
 * Ensures questions are asked one by one in the user's selected language.
 */
async function handleOnboardingMessage(mobile, message, languageCode = 'en', llmClient = null) {
  const profile = await getOrCreateProfile(mobile);
  const lang = (languageCode || 'en').toLowerCase().trim();

  const trimmed = (message || '').trim();
  const lower = trimmed.toLowerCase();

  const explicitCourseQuery =
    lower.includes('which course') ||
    lower.includes('which training') ||
    lower.includes('recommend training') ||
    lower.includes('recommend course') ||
    lower.includes('show nsqf') ||
    lower.includes('कौन सा कोर्स') ||
    lower.includes('कोर्स दिखाओ') ||
    lower.includes('কোন কোর্স');

  if (profile.onboardingComplete || explicitCourseQuery) {
    return { handled: false, reply: null, profileComplete: true, profile };
  }

  // --- Case A: Greeting ---
  if (!profile.name && detectGreeting(trimmed)) {
    const firstField = FIELD_ORDER[0];
    const reply = getQuestionFor(firstField, profile, lang);
    return { handled: true, reply, profileComplete: false, profile };
  }

  // --- Case B: Name response ---
  if (!profile.name && !detectGreeting(trimmed)) {
    const extracted = await extractFieldsFromMessage(trimmed, 'name', getMissingFields(profile), llmClient);
    Object.assign(profile, extracted);
    await safeSaveProfile(profile);

    const next = getNextField(profile);
    if (next) {
      const reply = getQuestionFor(next, profile, lang);
      return { handled: true, reply, profileComplete: false, profile };
    }
  }

  // --- Case C: Onboarding assessment in progress ---
  const currentField = getNextField(profile);
  if (currentField) {
    const missingBefore = getMissingFields(profile);
    const extracted = await extractFieldsFromMessage(trimmed, currentField.key, missingBefore, llmClient);

    // Age validation
    if (currentField.key === 'age' && (extracted.age === undefined || Number.isNaN(extracted.age))) {
      const ageErrMsg = {
        as: `ক্ষমা কৰিব — আপোনাৰ বয়স সংখ্যাত কওক (যেনে ২২)।`,
        bn: `দুঃখিত — অনুগ্রহ করে আপনার বয়স সংখ্যায় লিখুন (যেমন ২২)।`,
        hi: `क्षमा करें — कृपया अपनी उम्र संख्या में बताएं (जैसे 22)।`,
        pa: `ਮਾਫ਼ ਕਰਨਾ — ਕਿਰਪਾ ਕਰਕੇ ਆਪਣੀ ਉਮਰ ਨੰਬਰ ਵਿੱਚ ਦੱਸੋ (ਜਿਵੇਂ 22)।`,
        ta: `மன்னிக்கவும் — தயவுசெய்து உங்கள் வயதை எண்ணாக குறிப்பிடவும் (எ.கா. 22).`,
        te: `క్షమించండి — దయచేసి మీ వయస్సును సంఖ్యగా చెప్పండి (ఉదా. 22).`,
        mr: `क्षमस्व — कृपया तुमचे वय क्रमांकात सांगा (उदा. 22).`,
        ur: `معذرت — براہ کرم اپنی عمر نمبر میں بتائیں (جیسے 22)۔`,
        en: `Sorry, I didn't quite catch that — could you tell me your age as a number (e.g. 22)?`,
      };
      return {
        handled: true,
        reply: ageErrMsg[lang] || ageErrMsg.en,
        profileComplete: false,
        profile,
      };
    }

    Object.assign(profile, extracted);
    await safeSaveProfile(profile);

    const next = getNextField(profile);
    if (next) {
      const reply = getQuestionFor(next, profile, lang);
      return { handled: true, reply, profileComplete: false, profile };
    }

    // All 14 fields collected -> finalize & show summary + recommendations in user's active language
    profile.onboardingComplete = true;
    profile.currentStep = null;
    await safeSaveProfile(profile);

    const summary = buildSummary(profile, lang);
    return { handled: true, reply: summary, profileComplete: true, profile };
  }

  // Fallback
  profile.onboardingComplete = true;
  await safeSaveProfile(profile);
  return { handled: true, reply: buildSummary(profile, lang), profileComplete: true, profile };
}

module.exports = {
  handleOnboardingMessage,
  getOrCreateProfile,
  resetOnboarding,
};
