const mongoose = require('mongoose');

const userProfileSchema = new mongoose.Schema(
  {
    mobile: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    name: { type: String, default: null },
    age: { type: Number, default: null },
    state: { type: String, default: null },
    district: { type: String, default: null },
    location: { type: String, default: null },
    education: { type: String, default: null },
    currentOccupation: { type: String, default: null },
    familyOccupation: { type: String, default: null },
    skills: { type: String, default: null },
    experience: { type: String, default: null },
    interests: { type: String, default: null },
    employmentPreference: { type: String, default: null },
    mobilityConstraints: { type: String, default: null },
    careerGoal: { type: String, default: null },

    // Onboarding state machine bookkeeping
    onboardingComplete: { type: Boolean, default: false },
    // Index into FIELD_ORDER (see onboardingFlow.js) pointing at the
    // next question to ask. null once onboarding is complete.
    currentStep: { type: Number, default: 0 },
  },
  { timestamps: true }
);

module.exports = mongoose.model('UserProfile', userProfileSchema);