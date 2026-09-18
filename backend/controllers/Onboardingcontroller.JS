const UserProfile = require('../models/UserProfile');
const mongoose = require('mongoose');
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
 * Safely saves a profile doc without throwing if DB is offline/failing.
 */
async function safeSaveProfile(profile) {
  try {
    if (profile && typeof profile.save === 'function') {
      await profile.save();
    }
  } catch (err) {
    console.warn('Profile save warning (handled):', err.message);
  }
}

/**
 * Fetches (or creates) the UserProfile doc for a given mobile number.
 */
async function getOrCreateProfile(mobile) {
  if (mongoose.connection.readyState === 1) {
    try {
      let profile = await UserProfile.findOne({ mobile });
      if (!profile) {
        profile = await UserProfile.create({ mobile });
      }
      return profile;
    } catch (e) {
      console.warn('DB profile fetch failed, falling back to in-memory:', e.message);
    }
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
        return this;
      },
    });
  }
  return inMemoryProfiles.get(mobile);
}

/**
 * Main entry point. Call this from your chat route BEFORE falling through
 * to general AI/voice-assistant handling.
 */
async function handleOnboardingMessage(mobile, message, llmClient = null) {
  const profile = await getOrCreateProfile(mobile);

  // Onboarding already finished — let the normal AI chat flow handle this message.
  if (profile.onboardingComplete) {
    return { handled: false, reply: null, profileComplete: true, profile };
  }

  const trimmed = (message || '').trim();

  // --- Case A: onboarding hasn't started yet (no name captured) and the
  //     user just sent a greeting -> kick off with the first question. ---
  if (!profile.name && detectGreeting(trimmed)) {
    const firstField = FIELD_ORDER[0];
    const reply = getQuestionFor(firstField, profile);
    return { handled: true, reply, profileComplete: false, profile };
  }

  // --- Case B: onboarding hasn't started, and the message ISN'T a greeting either. ---
  if (!profile.name && !detectGreeting(trimmed)) {
    const extracted = await extractFieldsFromMessage(trimmed, 'name', getMissingFields(profile), llmClient);
    Object.assign(profile, extracted);
    await safeSaveProfile(profile);

    const next = getNextField(profile);
    if (next) {
      const reply = `Hello! 👋 Welcome to Disha Saathi. ${getQuestionFor(next, profile)}`;
      return { handled: true, reply, profileComplete: false, profile };
    }
  }

  // --- Case C: onboarding is in progress ---
  const currentField = getNextField(profile);
  if (currentField) {
    const missingBefore = getMissingFields(profile);
    const extracted = await extractFieldsFromMessage(trimmed, currentField.key, missingBefore, llmClient);

    // Basic validation for age
    if (currentField.key === 'age' && (extracted.age === undefined || Number.isNaN(extracted.age))) {
      return {
        handled: true,
        reply: `Sorry, I didn't quite catch that — could you tell me your age as a number (e.g. 22)?`,
        profileComplete: false,
        profile,
      };
    }

    Object.assign(profile, extracted);
    await safeSaveProfile(profile);

    const next = getNextField(profile);
    if (next) {
      const reply = getQuestionFor(next, profile);
      return { handled: true, reply, profileComplete: false, profile };
    }

    // All fields collected -> finalize.
    profile.onboardingComplete = true;
    profile.currentStep = null;
    await safeSaveProfile(profile);

    const summary = buildSummary(profile);
    return { handled: true, reply: summary, profileComplete: true, profile };
  }

  // Fallback
  profile.onboardingComplete = true;
  await safeSaveProfile(profile);
  return { handled: true, reply: buildSummary(profile), profileComplete: true, profile };
}

module.exports = {
  handleOnboardingMessage,
  getOrCreateProfile,
};
