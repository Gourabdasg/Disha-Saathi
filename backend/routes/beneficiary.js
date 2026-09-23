const express = require('express');
const router = express.Router();
const { query } = require('../db');

// In-memory profiles fallback for offline DB mode
const inMemoryProfiles = new Map();

function mapPgRowToProfile(row) {
  if (!row) return null;
  return {
    mobile: row.mobile || '',
    email: row.email || '',
    name: row.name || '',
    annualIncome: row.annual_income || '',
    category: row.category || 'Scheduled Caste (SC)',
    scCategoryNo: row.sc_category_no || '',
    scCertificateUrl: row.sc_certificate_url || '',
    scCertificateFilename: row.sc_certificate_filename || '',
    district: row.district || '',
    state: row.state || '',
    location: row.location || '',
    highestQualification: row.highest_qualification || '',
    stream: row.stream || '',
    yearOfQualification: row.year_of_qualification || '',
    yearsOfStudy: row.years_of_study || 0,
    experienceName: row.experience_name || '',
    experienceDuration: row.experience_duration || '',
    workExperienceYears: row.work_experience_years || 0,
    livelihood: row.livelihood || '',
    existingSkills: row.existing_skills || [],
    careerInterests: row.career_interests || [],
    preferredLanguage: row.preferred_language || 'en',
    profileCompletionPercent: row.profile_completion_percent || 65,
    journeyPercent: row.journey_percent || 26,
  };
}

/**
 * POST /api/beneficiary/profile
 * Upserts a beneficiary record by mobile or email into PostgreSQL.
 */
router.post('/profile', async (req, res) => {
  try {
    const { mobile, email } = req.body;
    const key = mobile || email;
    if (!key) {
      return res.status(400).json({ error: 'mobile or email is required to save a profile' });
    }

    inMemoryProfiles.set(key, req.body);

    const mobileVal = mobile || (email ? `e_${email}` : '');
    const emailVal = email || '';
    const nameVal = req.body.name || '';
    const incomeVal = req.body.annualIncome || '';
    const categoryVal = req.body.category || 'Scheduled Caste (SC)';
    const scCategoryNoVal = req.body.scCategoryNo || '';
    const scCertUrlVal = req.body.scCertificateUrl || '';
    const scCertFileVal = req.body.scCertificateFilename || '';
    const districtVal = req.body.district || '';
    const stateVal = req.body.state || '';
    const locationVal = req.body.location || '';
    const qualVal = req.body.highestQualification || '';
    const streamVal = req.body.stream || '';
    const yearQualVal = req.body.yearOfQualification || '';
    const yearsStudyVal = parseInt(req.body.yearsOfStudy, 10) || 0;
    const expNameVal = req.body.experienceName || '';
    const expDurVal = req.body.experienceDuration || '';
    const expYearsVal = parseInt(req.body.workExperienceYears, 10) || 0;
    const livelihoodVal = req.body.livelihood || '';
    const skillsVal = Array.isArray(req.body.existingSkills) ? req.body.existingSkills : [];
    const interestsVal = Array.isArray(req.body.careerInterests) ? req.body.careerInterests : [];
    const langVal = req.body.preferredLanguage || 'en';
    const compVal = parseInt(req.body.profileCompletionPercent, 10) || 65;
    const journeyVal = parseInt(req.body.journeyPercent, 10) || 26;

    const sql = `
      INSERT INTO beneficiaries (
        mobile, email, name, annual_income, category, sc_category_no,
        sc_certificate_url, sc_certificate_filename, district, state,
        location, highest_qualification, stream, year_of_qualification,
        years_of_study, experience_name, experience_duration,
        work_experience_years, livelihood, existing_skills,
        career_interests, preferred_language, profile_completion_percent,
        journey_percent, updated_at
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14,
        $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, CURRENT_TIMESTAMP
      )
      ON CONFLICT (mobile) DO UPDATE SET
        email = EXCLUDED.email,
        name = EXCLUDED.name,
        district = EXCLUDED.district,
        state = EXCLUDED.state,
        location = EXCLUDED.location,
        sc_category_no = EXCLUDED.sc_category_no,
        sc_certificate_url = EXCLUDED.sc_certificate_url,
        sc_certificate_filename = EXCLUDED.sc_certificate_filename,
        highest_qualification = EXCLUDED.highest_qualification,
        stream = EXCLUDED.stream,
        year_of_qualification = EXCLUDED.year_of_qualification,
        experience_name = EXCLUDED.experience_name,
        experience_duration = EXCLUDED.experience_duration,
        livelihood = EXCLUDED.livelihood,
        existing_skills = EXCLUDED.existing_skills,
        career_interests = EXCLUDED.career_interests,
        preferred_language = EXCLUDED.preferred_language,
        profile_completion_percent = EXCLUDED.profile_completion_percent,
        journey_percent = EXCLUDED.journey_percent,
        updated_at = CURRENT_TIMESTAMP
      RETURNING *;
    `;

    const values = [
      mobileVal, emailVal, nameVal, incomeVal, categoryVal, scCategoryNoVal,
      scCertUrlVal, scCertFileVal, districtVal, stateVal, locationVal,
      qualVal, streamVal, yearQualVal, yearsStudyVal, expNameVal, expDurVal,
      expYearsVal, livelihoodVal, skillsVal, interestsVal, langVal, compVal,
      journeyVal,
    ];

    const result = await query(sql, values);
    const profile = mapPgRowToProfile(result.rows[0]);

    res.json({ message: 'Profile saved', profile });
  } catch (err) {
    console.warn('Profile PostgreSQL save fallback (in-memory):', err.message);
    const key = req.body.mobile || req.body.email || 'anonymous';
    inMemoryProfiles.set(key, req.body);
    res.json({ message: 'Profile saved', profile: req.body });
  }
});

/**
 * GET /api/beneficiary/profile/:identifier
 * Looks up a beneficiary by mobile or email.
 */
router.get('/profile/:identifier', async (req, res) => {
  try {
    const key = req.params.identifier;

    const result = await query(
      `SELECT * FROM beneficiaries WHERE mobile = $1 OR email = $1 LIMIT 1;`,
      [key]
    );

    if (result.rows && result.rows.length > 0) {
      return res.json(mapPgRowToProfile(result.rows[0]));
    }

    if (inMemoryProfiles.has(key)) {
      return res.json(inMemoryProfiles.get(key));
    }

    return res.status(404).json({ error: 'No profile found for that identifier' });
  } catch (err) {
    const key = req.params.identifier;
    if (inMemoryProfiles.has(key)) {
      return res.json(inMemoryProfiles.get(key));
    }
    res.status(404).json({ error: 'Could not find profile' });
  }
});

/**
 * GET /api/beneficiary
 * Lists all beneficiaries.
 */
router.get('/', async (req, res) => {
  try {
    const result = await query(`SELECT * FROM beneficiaries ORDER BY created_at DESC LIMIT 100;`);
    res.json(result.rows.map(mapPgRowToProfile));
  } catch (err) {
    res.json(Array.from(inMemoryProfiles.values()));
  }
});

module.exports = router;
