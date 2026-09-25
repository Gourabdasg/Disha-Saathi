const express = require('express');
const router = express.Router();
const { query } = require('../db');

// In-memory profiles fallback for offline DB mode
const inMemoryProfiles = new Map();

function calculateDynamicCompletion(row) {
  let filled = 0;
  const totalFields = 14;

  const name = row.name || '';
  const age = row.age;
  const state = row.state || '';
  const district = row.district || '';
  const location = row.location || '';
  const edu = row.education || row.highest_qualification || '';
  const currOcc = row.current_occupation || row.livelihood || '';
  const famOcc = row.family_occupation || '';
  const skills = row.skills || row.existing_skills || [];
  const exp = row.experience || row.experience_name || '';
  const interests = row.interests || row.career_interests || [];
  const empPref = row.employment_preference || '';
  const mobCon = row.mobility_constraints || '';
  const goal = row.career_goal || '';

  if (name && name.trim().length > 0) filled++;
  if (age !== null && age !== undefined && Number(age) > 0) filled++;
  if (state && state.trim().length > 0) filled++;
  if (district && district.trim().length > 0) filled++;
  if (location && location.trim().length > 0) filled++;
  if (edu && edu.trim().length > 0) filled++;
  if (currOcc && currOcc.trim().length > 0) filled++;
  if (famOcc && famOcc.trim().length > 0) filled++;
  if ((Array.isArray(skills) && skills.length > 0) || (typeof skills === 'string' && skills.trim().length > 0)) filled++;
  if (exp && exp.trim().length > 0) filled++;
  if ((Array.isArray(interests) && interests.length > 0) || (typeof interests === 'string' && interests.trim().length > 0)) filled++;
  if (empPref && empPref.trim().length > 0) filled++;
  if (mobCon && mobCon.trim().length > 0) filled++;
  if (goal && goal.trim().length > 0) filled++;

  if (row.onboarding_complete) return 100;
  const pct = Math.round((filled / totalFields) * 100);
  return pct > 100 ? 100 : pct;
}

function mapPgRowToProfile(row) {
  if (!row) return null;

  const skillsList = Array.isArray(row.existing_skills)
    ? row.existing_skills
    : (typeof row.skills === 'string' && row.skills ? row.skills.split(',').map(s => s.trim()) : []);

  const interestsList = Array.isArray(row.career_interests)
    ? row.career_interests
    : (typeof row.interests === 'string' && row.interests ? row.interests.split(',').map(s => s.trim()) : []);

  const completionPercent = calculateDynamicCompletion(row);

  return {
    mobile: row.mobile || '',
    email: row.email || '',
    name: row.name || 'Rahul Kumar',
    age: row.age || null,
    district: row.district || '',
    state: row.state || '',
    location: row.location || '',
    highestQualification: row.highest_qualification || row.education || '',
    education: row.education || row.highest_qualification || '',
    currentOccupation: row.current_occupation || row.livelihood || '',
    livelihood: row.livelihood || row.current_occupation || '',
    familyOccupation: row.family_occupation || '',
    experienceName: row.experience_name || row.experience || '',
    experience: row.experience || row.experience_name || '',
    skills: Array.isArray(skillsList) ? skillsList.join(', ') : (skillsList || ''),
    existingSkills: skillsList,
    interests: Array.isArray(interestsList) ? interestsList.join(', ') : (interestsList || ''),
    careerInterests: interestsList,
    employmentPreference: row.employment_preference || '',
    mobilityConstraints: row.mobility_constraints || '',
    careerGoal: row.career_goal || '',
    onboardingComplete: row.onboarding_complete || false,
    preferredLanguage: row.preferred_language || 'en',
    profileCompletionPercent: completionPercent,
    journeyPercent: Math.min(100, Math.max(26, completionPercent)),
  };
}

/**
 * POST /api/beneficiary/profile
 * Upserts a beneficiary record by mobile or email into PostgreSQL.
 */
router.post('/profile', async (req, res) => {
  try {
    const rawMobile = req.body.mobile ? req.body.mobile.trim() : '';
    const rawEmail = req.body.email ? req.body.email.trim().toLowerCase() : '';
    const key = rawMobile || rawEmail;

    if (!key) {
      return res.status(400).json({ error: 'mobile or email is required to save a profile' });
    }

    inMemoryProfiles.set(key, req.body);
    if (rawEmail) inMemoryProfiles.set(rawEmail, req.body);

    const mobileVal = rawMobile || (rawEmail ? `e_${rawEmail}` : '');
    const emailVal = rawEmail;
    const nameVal = req.body.name || '';
    const ageVal = parseInt(req.body.age, 10) || null;
    const incomeVal = req.body.annualIncome || '';
    const categoryVal = req.body.category || 'Scheduled Caste (SC)';
    const scCategoryNoVal = req.body.scCategoryNo || '';
    const scCertUrlVal = req.body.scCertificateUrl || '';
    const scCertFileVal = req.body.scCertificateFilename || '';
    const districtVal = req.body.district || '';
    const stateVal = req.body.state || '';
    const locationVal = req.body.location || '';
    const qualVal = req.body.highestQualification || req.body.education || '';
    const streamVal = req.body.stream || '';
    const yearQualVal = req.body.yearOfQualification || '';
    const yearsStudyVal = parseInt(req.body.yearsOfStudy, 10) || 0;
    const expNameVal = req.body.experienceName || req.body.experience || '';
    const expDurVal = req.body.experienceDuration || '';
    const expYearsVal = parseInt(req.body.workExperienceYears, 10) || 0;
    const livelihoodVal = req.body.livelihood || req.body.currentOccupation || '';
    const familyOccupationVal = req.body.familyOccupation || '';
    const skillsVal = Array.isArray(req.body.existingSkills) ? req.body.existingSkills : (req.body.skills ? [req.body.skills] : []);
    const interestsVal = Array.isArray(req.body.careerInterests) ? req.body.careerInterests : (req.body.interests ? [req.body.interests] : []);
    const empPrefVal = req.body.employmentPreference || '';
    const mobConVal = req.body.mobilityConstraints || '';
    const goalVal = req.body.careerGoal || '';
    const langVal = req.body.preferredLanguage || 'en';

    const sqlUserProfiles = `
      INSERT INTO user_profiles (
        mobile, name, age, state, district, location, education,
        current_occupation, family_occupation, skills, experience,
        interests, employment_preference, mobility_constraints, career_goal,
        onboarding_complete, updated_at
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, CURRENT_TIMESTAMP
      )
      ON CONFLICT (mobile) DO UPDATE SET
        name = EXCLUDED.name,
        age = COALESCE(EXCLUDED.age, user_profiles.age),
        state = EXCLUDED.state,
        district = EXCLUDED.district,
        location = EXCLUDED.location,
        education = EXCLUDED.education,
        current_occupation = EXCLUDED.current_occupation,
        family_occupation = EXCLUDED.family_occupation,
        skills = EXCLUDED.skills,
        experience = EXCLUDED.experience,
        interests = EXCLUDED.interests,
        employment_preference = EXCLUDED.employment_preference,
        mobility_constraints = EXCLUDED.mobility_constraints,
        career_goal = EXCLUDED.career_goal,
        onboarding_complete = EXCLUDED.onboarding_complete,
        updated_at = CURRENT_TIMESTAMP
      RETURNING *;
    `;

    const skillsStr = Array.isArray(skillsVal) ? skillsVal.join(', ') : (skillsVal || '');
    const interestsStr = Array.isArray(interestsVal) ? interestsVal.join(', ') : (interestsVal || '');

    const result = await query(sqlUserProfiles, [
      mobileVal, nameVal, ageVal, stateVal, districtVal, locationVal, qualVal,
      livelihoodVal, familyOccupationVal, skillsStr, expNameVal, interestsStr,
      empPrefVal, mobConVal, goalVal, req.body.onboardingComplete || false,
    ]);

    const profile = mapPgRowToProfile(result.rows[0]);
    res.json({ message: 'Profile saved', profile });
  } catch (err) {
    console.warn('Profile PostgreSQL save fallback:', err.message);
    const key = req.body.mobile || (req.body.email ? req.body.email.trim().toLowerCase() : 'anonymous');
    inMemoryProfiles.set(key, req.body);
    res.json({ message: 'Profile saved', profile: req.body });
  }
});

/**
 * GET /api/beneficiary/profile/:identifier
 * Looks up a beneficiary profile in user_profiles or beneficiaries table.
 */
router.get('/profile/:identifier', async (req, res) => {
  try {
    const rawKey = req.params.identifier ? req.params.identifier.trim() : '';
    const key = rawKey.includes('@') ? rawKey.toLowerCase() : rawKey;

    let result = await query(
      `SELECT * FROM user_profiles WHERE mobile = $1 LIMIT 1;`,
      [key]
    );

    if (result.rows && result.rows.length > 0) {
      return res.json(mapPgRowToProfile(result.rows[0]));
    }

    result = await query(
      `SELECT * FROM beneficiaries WHERE mobile = $1 OR LOWER(email) = LOWER($1) LIMIT 1;`,
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
    const rawKey = req.params.identifier ? req.params.identifier.trim() : '';
    const key = rawKey.includes('@') ? rawKey.toLowerCase() : rawKey;

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
    const result = await query(`SELECT * FROM user_profiles ORDER BY updated_at DESC LIMIT 100;`);
    res.json(result.rows.map(mapPgRowToProfile));
  } catch (err) {
    res.json(Array.from(inMemoryProfiles.values()));
  }
});

module.exports = router;
