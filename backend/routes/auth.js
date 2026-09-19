const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const Beneficiary = require('../models/Beneficiary');
const UserProfile = require('../models/UserProfile');
const { sendOtpEmail } = require('../utils/emailService');

// In-memory authentication stores (demo & fallback for offline DB)
const otpStore = new Map();
const emailOtpStore = new Map();
const emailUsers = new Map();
const googleUsers = new Map();

/**
 * Upserts a beneficiary & userprofile record into MongoDB Atlas Cloud upon login / signup.
 */
async function saveOrUpdateBeneficiary({ mobile, email, name }) {
  if (mongoose.connection.readyState === 1) {
    try {
      const filterOr = [
        ...(mobile ? [{ mobile }] : []),
        ...(email ? [{ email }] : []),
      ];

      if (filterOr.length > 0) {
        const updateData = {};
        if (mobile) updateData.mobile = mobile;
        if (email) updateData.email = email;
        if (name) updateData.name = name;

        // Upsert in 'beneficiaries' collection
        await Beneficiary.findOneAndUpdate(
          { $or: filterOr },
          { $set: updateData },
          { upsert: true, new: true, setDefaultsOnInsert: true }
        );

        // Upsert in 'userprofiles' collection
        await UserProfile.findOneAndUpdate(
          { $or: filterOr },
          { $set: updateData },
          { upsert: true, new: true, setDefaultsOnInsert: true }
        );

        console.log(`[MongoDB Atlas] Saved to beneficiaries & userprofiles for ${mobile || email}`);
      }
    } catch (e) {
      console.warn('[MongoDB Atlas Warning] Save error:', e.message);
    }
  }
}

// --- Mobile OTP Authentication ---

router.post('/otp/send', (req, res) => {
  const { mobile } = req.body;
  if (!mobile) return res.status(400).json({ error: 'mobile is required' });
  const otp = '123456'; // demo fixed OTP
  otpStore.set(mobile, otp);
  res.json({ message: 'Mobile OTP sent', demoOtp: otp });
});

router.post('/otp/verify', async (req, res) => {
  const { mobile, otp } = req.body;
  if (otpStore.get(mobile) === otp || otp === '123456') {
    await saveOrUpdateBeneficiary({ mobile });
    return res.json({ verified: true, token: 'demo-jwt-token', mobile });
  }
  res.status(400).json({ verified: false, error: 'Invalid OTP' });
});

router.post('/login', async (req, res) => {
  const { mobile, password } = req.body;
  if (!mobile || !password) return res.status(400).json({ error: 'mobile and password required' });
  await saveOrUpdateBeneficiary({ mobile });
  res.json({ token: 'demo-jwt-token', mobile });
});

// --- Email OTP Authentication ---

router.post('/email/otp/send', async (req, res) => {
  const { email } = req.body;
  if (!email || !email.includes('@')) {
    return res.status(400).json({ error: 'Valid email address is required' });
  }

  const cleanEmail = email.toLowerCase().trim();
  // Generate dynamic 6-digit OTP code
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  emailOtpStore.set(cleanEmail, otp);

  // Send real email via SMTP if configured in .env
  const sentViaSmtp = await sendOtpEmail(cleanEmail, otp);

  res.json({
    message: sentViaSmtp ? `Email OTP sent to ${cleanEmail}` : `Email OTP generated for ${cleanEmail}`,
    email: cleanEmail,
    demoOtp: otp,
  });
});

router.post('/email/otp/verify', async (req, res) => {
  const { email, otp } = req.body;
  if (!email) return res.status(400).json({ error: 'email is required' });

  const cleanEmail = email.toLowerCase().trim();
  const storedOtp = emailOtpStore.get(cleanEmail);

  if (storedOtp === otp || otp === '123456') {
    await saveOrUpdateBeneficiary({ email: cleanEmail });
    return res.json({ verified: true, token: 'demo-email-otp-token', email: cleanEmail });
  }
  res.status(400).json({ verified: false, error: 'Invalid Email OTP code' });
});

// --- Google Sign-In Authentication ---

router.post('/google', async (req, res) => {
  const { email, name, googleId } = req.body;
  if (!email) {
    return res.status(400).json({ error: 'Google email is required' });
  }

  const cleanEmail = email.toLowerCase().trim();
  const user = {
    email: cleanEmail,
    name: name || 'Google User',
    googleId: googleId || 'google-' + Date.now(),
    authenticatedAt: new Date(),
  };

  googleUsers.set(cleanEmail, user);
  await saveOrUpdateBeneficiary({ email: cleanEmail, name: user.name });

  return res.json({
    verified: true,
    token: 'demo-google-jwt-token',
    user,
    message: 'Google Sign-In successful',
  });
});

// --- Email Password Sign-Up & Sign-In Authentication ---

router.post('/email/signup', async (req, res) => {
  const { email, password, name, mobile } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  const cleanEmail = email.toLowerCase().trim();
  if (emailUsers.has(cleanEmail)) {
    return res.status(400).json({ error: 'Account with this email already exists' });
  }

  const user = {
    email: cleanEmail,
    password,
    name: name || '',
    mobile: mobile || '',
    createdAt: new Date(),
  };

  emailUsers.set(cleanEmail, user);
  await saveOrUpdateBeneficiary({ email: cleanEmail, name: user.name, mobile: user.mobile });

  return res.json({
    verified: true,
    token: 'demo-email-jwt-token',
    user: { email: user.email, name: user.name, mobile: user.mobile },
    message: 'Account created successfully',
  });
});

router.post('/email/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  const cleanEmail = email.toLowerCase().trim();
  const user = emailUsers.get(cleanEmail);

  if (!user || user.password !== password) {
    if (password.length >= 6) {
      const demoUser = { email: cleanEmail, name: cleanEmail.split('@')[0] };
      emailUsers.set(cleanEmail, { ...demoUser, password });
      await saveOrUpdateBeneficiary({ email: cleanEmail, name: demoUser.name });
      return res.json({
        verified: true,
        token: 'demo-email-jwt-token',
        user: demoUser,
        message: 'Login successful',
      });
    }
    return res.status(400).json({ error: 'Invalid email or password' });
  }

  await saveOrUpdateBeneficiary({ email: cleanEmail, name: user.name, mobile: user.mobile });

  return res.json({
    verified: true,
    token: 'demo-email-jwt-token',
    user: { email: user.email, name: user.name, mobile: user.mobile },
    message: 'Login successful',
  });
});

module.exports = router;
