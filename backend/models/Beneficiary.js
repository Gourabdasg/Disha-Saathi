const mongoose = require('mongoose');

/**
 * Beneficiary schema — mirrors the fields collected in the Flutter app's
 * 4-step registration flow (Personal Info, Education, Livelihood, Skills)
 * plus the AI-generated NSQF profile fields.
 *
 * `mobile` is the natural unique key: beneficiaries log in by mobile + OTP,
 * so we upsert on it rather than requiring the client to track a Mongo _id.
 */
const beneficiarySchema = new mongoose.Schema(
  {
    mobile: { type: String, required: true, unique: true, trim: true },

    // Step 1 — Personal Info
    name: { type: String, default: '' },
    fatherName: { type: String, default: '' },
    motherName: { type: String, default: '' },
    aadhaar: { type: String, default: '' },
    annualIncome: { type: String, default: '' },
    category: { type: String, default: 'Scheduled Caste (SC)' },
    district: { type: String, default: '' },
    state: { type: String, default: '' },

    // Step 2 — Education
    highestQualification: { type: String, default: '' },
    stream: { type: String, default: '' },
    yearsOfStudy: { type: Number, default: 0 },
    workExperienceYears: { type: Number, default: 0 },

    // Step 3 — Livelihood
    livelihood: { type: String, default: '' },

    // Step 4 — Skills
    existingSkills: { type: [String], default: [] },
    careerInterests: { type: [String], default: [] },

    // Derived / tracked separately from the AI service
    profileCompletionPercent: { type: Number, default: 0 },
    journeyPercent: { type: Number, default: 0 },
  },
  { timestamps: true } // adds createdAt / updatedAt automatically
);

module.exports = mongoose.model('Beneficiary', beneficiarySchema);