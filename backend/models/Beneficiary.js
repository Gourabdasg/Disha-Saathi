const mongoose = require('mongoose');

const beneficiarySchema = new mongoose.Schema(
  {
    mobile: { type: String, default: '', trim: true },
    email: { type: String, default: '', trim: true },

    // Step 1 — Personal Info
    name: { type: String, default: '' },
    annualIncome: { type: String, default: '' },
    category: { type: String, default: 'Scheduled Caste (SC)' },
    scCategoryNo: { type: String, default: '' },
    district: { type: String, default: '' },
    state: { type: String, default: '' },
    location: { type: String, default: '' },

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

    // Derived / tracked separately
    profileCompletionPercent: { type: Number, default: 65 },
    journeyPercent: { type: Number, default: 26 },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Beneficiary', beneficiarySchema);
