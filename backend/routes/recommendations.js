const express = require('express');
const router = express.Router();
const { matchNsqfTrainings } = require('../utils/nsqfMatcher');
const { query } = require('../db');

/**
 * GET /api/recommendations/:beneficiaryId
 * Returns personalized NSQF course recommendations computed dynamically from NSQF_Training_Recommendation.js.
 */
router.get('/:beneficiaryId', async (req, res) => {
  try {
    let profileData = {};
    if (req.params.beneficiaryId) {
      try {
        const result = await query(
          `SELECT * FROM user_profiles WHERE mobile = $1 OR email = $1 LIMIT 1;`,
          [req.params.beneficiaryId]
        );
        if (result.rows && result.rows.length > 0) profileData = result.rows[0];
      } catch (_) {}
    }

    const recommendations = matchNsqfTrainings({ profile: profileData, limit: 5 });
    res.json(recommendations);
  } catch (err) {
    console.error('Recommendations route error:', err);
    const recommendations = matchNsqfTrainings({ profile: {}, limit: 4 });
    res.json(recommendations);
  }
});

module.exports = router;
