const express = require('express');
const router = express.Router();
const Beneficiary = require('../models/Beneficiary');

/**
 * POST /api/beneficiary/profile
 * Upserts a beneficiary record by mobile number. Called after registration
 * (Steps 1-4 in the Flutter app) or whenever the profile is edited.
 * Requires a MongoDB connection — if the DB is down this returns a 503
 * rather than silently pretending to save (unlike the old stub).
 */
router.post('/profile', async (req, res) => {
  try {
    const { mobile } = req.body;
    if (!mobile) {
      return res.status(400).json({ error: 'mobile is required to save a profile' });
    }

    const beneficiary = await Beneficiary.findOneAndUpdate(
      { mobile },
      { $set: req.body },
      { new: true, upsert: true, setDefaultsOnInsert: true, runValidators: true }
    );

    res.json({ message: 'Profile saved', profile: beneficiary });
  } catch (err) {
    res.status(503).json({
      error: 'Could not save profile — is MongoDB connected?',
      details: err.message,
    });
  }
});

/**
 * GET /api/beneficiary/profile/:mobile
 * Looks up a beneficiary by mobile number (matches how the app logs in).
 */
router.get('/profile/:mobile', async (req, res) => {
  try {
    const beneficiary = await Beneficiary.findOne({ mobile: req.params.mobile });
    if (!beneficiary) {
      return res.status(404).json({ error: 'No beneficiary found for that mobile number' });
    }
    res.json(beneficiary);
  } catch (err) {
    res.status(503).json({
      error: 'Could not read profile — is MongoDB connected?',
      details: err.message,
    });
  }
});

/**
 * GET /api/beneficiary
 * Lists all beneficiaries (demo/admin use — add auth before production).
 */
router.get('/', async (req, res) => {
  try {
    const beneficiaries = await Beneficiary.find().sort({ createdAt: -1 }).limit(100);
    res.json(beneficiaries);
  } catch (err) {
    res.status(503).json({
      error: 'Could not list beneficiaries — is MongoDB connected?',
      details: err.message,
    });
  }
});

module.exports = router;