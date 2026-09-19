const express = require('express');
const router = express.Router();
const Beneficiary = require('../models/Beneficiary');
const UserProfile = require('../models/UserProfile');

// In-memory profiles fallback for offline DB mode
const inMemoryProfiles = new Map();

/**
 * POST /api/beneficiary/profile
 * Upserts a beneficiary & userprofile record by mobile or email into MongoDB.
 */
router.post('/profile', async (req, res) => {
  try {
    const { mobile, email } = req.body;
    const key = mobile || email;
    if (!key) {
      return res.status(400).json({ error: 'mobile or email is required to save a profile' });
    }

    inMemoryProfiles.set(key, req.body);

    const filter = {
      $or: [
        ...(mobile ? [{ mobile }] : []),
        ...(email ? [{ email }] : []),
        { mobile: key },
        { email: key },
      ],
    };

    // Save to 'beneficiaries' collection
    const beneficiary = await Beneficiary.findOneAndUpdate(
      filter,
      { $set: req.body },
      { new: true, upsert: true, setDefaultsOnInsert: true, runValidators: false }
    );

    // Save to 'userprofiles' collection (matches MongoDB Atlas userprofiles tab)
    try {
      await UserProfile.findOneAndUpdate(
        filter,
        { $set: req.body },
        { new: true, upsert: true, setDefaultsOnInsert: true, runValidators: false }
      );
    } catch (e) {
      console.warn('UserProfile collection upsert warning:', e.message);
    }

    res.json({ message: 'Profile saved', profile: beneficiary });
  } catch (err) {
    console.warn('Profile DB save fallback:', err.message);
    const key = req.body.mobile || req.body.email || 'anonymous';
    inMemoryProfiles.set(key, req.body);
    res.json({ message: 'Profile saved (in-memory)', profile: req.body });
  }
});

/**
 * GET /api/beneficiary/profile/:identifier
 * Looks up a beneficiary by mobile or email.
 */
router.get('/profile/:identifier', async (req, res) => {
  try {
    const key = req.params.identifier;
    if (inMemoryProfiles.has(key)) {
      return res.json(inMemoryProfiles.get(key));
    }

    let profile = await Beneficiary.findOne({
      $or: [{ mobile: key }, { email: key }],
    });

    if (!profile) {
      profile = await UserProfile.findOne({
        $or: [{ mobile: key }, { email: key }],
      });
    }

    if (!profile) {
      return res.status(404).json({ error: 'No profile found for that identifier' });
    }
    res.json(profile);
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
    const beneficiaries = await Beneficiary.find().sort({ createdAt: -1 }).limit(100);
    res.json(beneficiaries);
  } catch (err) {
    res.json(Array.from(inMemoryProfiles.values()));
  }
});

module.exports = router;
