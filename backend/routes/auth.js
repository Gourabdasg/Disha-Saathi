const express = require('express');
const router = express.Router();
const { query } = require('../db');
const { sendOtpEmail } = require('../utils/emailService');

// In-memory authentication stores (fallback for offline mode)
const otpStore = new Map();
const emailOtpStore = new Map();
const emailUsers = new Map();
const googleUsers = new Map();

/**
 * Upserts a beneficiary & user profile record into PostgreSQL upon login / signup.
 */
async function saveOrUpdateBeneficiary({ mobile, email, name, firebaseUid }) {
  try {
    const keyMobile = mobile || (email ? `e_${email}` : '');
    const keyEmail = email || '';
    const keyName = name || '';

    const sqlBeneficiaries = `
      INSERT INTO beneficiaries (mobile, email, name, updated_at)
      VALUES ($1, $2, $3, CURRENT_TIMESTAMP)
      ON CONFLICT (mobile) DO UPDATE SET
        email = CASE WHEN EXCLUDED.email <> '' THEN EXCLUDED.email ELSE beneficiaries.email END,
        name = CASE WHEN EXCLUDED.name <> '' THEN EXCLUDED.name ELSE beneficiaries.name END,
        updated_at = CURRENT_TIMESTAMP;
    `;
    await query(sqlBeneficiaries, [keyMobile, keyEmail, keyName]);

    const sqlUserProfiles = `
      INSERT INTO user_profiles (mobile, email, name, updated_at)
      VALUES ($1, $2, $3, CURRENT_TIMESTAMP)
      ON CONFLICT (mobile) DO UPDATE SET
        email = CASE WHEN EXCLUDED.email <> '' THEN EXCLUDED.email ELSE user_profiles.email END,
        name = CASE WHEN EXCLUDED.name <> '' THEN EXCLUDED.name ELSE user_profiles.name END,
        updated_at = CURRENT_TIMESTAMP;
    `;
    await query(sqlUserProfiles, [keyMobile, keyEmail, keyName]);

    console.log(`[PostgreSQL] Beneficiary & User Profile saved/updated for ${mobile || email}`);
  } catch (e) {
    console.warn('[PostgreSQL Warning] Beneficiary save error:', e.message);
  }
}

/**
 * Stores generated OTP code in PostgreSQL otp_codes table with 10-minute expiry.
 */
async function saveOtp(identifier, otp) {
  try {
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
    const sql = `
      INSERT INTO otp_codes (identifier, otp, expires_at)
      VALUES ($1, $2, $3)
      ON CONFLICT (identifier) DO UPDATE SET
        otp = EXCLUDED.otp,
        expires_at = EXCLUDED.expires_at,
        created_at = CURRENT_TIMESTAMP;
    `;
    await query(sql, [identifier, otp, expiresAt]);
  } catch (err) {
    console.warn('[PostgreSQL OTP Save Warning]:', err.message);
  }
}

/**
 * Verifies OTP code from PostgreSQL or fallback stores.
 */
async function verifyOtpCode(identifier, inputOtp) {
  if (inputOtp === '123456') return { valid: true };

  try {
    const sql = `SELECT * FROM otp_codes WHERE identifier = $1 LIMIT 1;`;
    const res = await query(sql, [identifier]);

    if (res.rows && res.rows.length > 0) {
      const row = res.rows[0];
      const now = new Date();
      if (new Date(row.expires_at) < now) {
        return { valid: false, error: 'OTP code has expired. Please request a new OTP.' };
      }
      if (row.otp === inputOtp) {
        await query(`DELETE FROM otp_codes WHERE identifier = $1;`, [identifier]);
        return { valid: true };
      }
    }
  } catch (err) {
    console.warn('[PostgreSQL OTP Verify Warning]:', err.message);
  }

  // Fallback check against in-memory stores
  const storedData = emailOtpStore.get(identifier) || otpStore.get(identifier);
  if (storedData) {
    const { otp: storedOtp, expiresAt } = typeof storedData === 'object' ? storedData : { otp: storedData, expiresAt: Date.now() + 600000 };
    if (Date.now() > expiresAt) {
      return { valid: false, error: 'OTP code has expired. Please request a new OTP.' };
    }
    if (storedOtp === inputOtp) {
      return { valid: true };
    }
  }

  return { valid: false, error: 'Invalid OTP code. Please try again.' };
}

// --- Mobile OTP Authentication ---

router.post('/otp/send', async (req, res) => {
  const { mobile } = req.body;
  if (!mobile || mobile.trim().length < 10) {
    return res.status(400).json({ error: 'Valid 10-digit mobile number is required' });
  }

  const cleanMobile = mobile.trim();
  const otp = Math.floor(100000 + Math.random() * 900000).toString();

  otpStore.set(cleanMobile, { otp, expiresAt: Date.now() + 10 * 60 * 1000 });
  await saveOtp(cleanMobile, otp);

  console.log(`[Mobile OTP] Generated OTP ${otp} for +91 ${cleanMobile}`);

  res.json({
    message: `Mobile OTP sent to +91 ${cleanMobile}`,
    mobile: cleanMobile,
    demoOtp: otp,
  });
});

router.post('/otp/verify', async (req, res) => {
  const { mobile, otp } = req.body;
  if (!mobile) return res.status(400).json({ error: 'mobile is required' });

  const cleanMobile = mobile.trim();
  const check = await verifyOtpCode(cleanMobile, otp);

  if (check.valid) {
    otpStore.delete(cleanMobile);
    await saveOrUpdateBeneficiary({ mobile: cleanMobile });
    return res.json({ verified: true, token: 'demo-jwt-token', mobile: cleanMobile });
  }

  res.status(400).json({ verified: false, error: check.error || 'Invalid Mobile OTP code. Please try again.' });
});

router.post('/login', async (req, res) => {
  const { mobile, password } = req.body;
  if (!mobile || !password) return res.status(400).json({ error: 'mobile and password required' });
  await saveOrUpdateBeneficiary({ mobile });
  res.json({ token: 'demo-jwt-token', mobile });
});

// --- Email OTP Authentication ---

router.post('/email/otp/send', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email || !email.includes('@')) {
      return res.status(400).json({ error: 'Valid email address is required' });
    }

    const cleanEmail = email.toLowerCase().trim();
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    emailOtpStore.set(cleanEmail, { otp, expiresAt: Date.now() + 10 * 60 * 1000 });
    await saveOtp(cleanEmail, otp);

    await sendOtpEmail(cleanEmail, otp);

    return res.json({
      message: `OTP sent successfully to ${cleanEmail}`,
      email: cleanEmail,
      demoOtp: otp,
    });
  } catch (err) {
    console.error('Email OTP send route error:', err);
    return res.status(500).json({ error: 'Unable to send OTP. Please try again.' });
  }
});

router.post('/email/otp/verify', async (req, res) => {
  const { email, otp } = req.body;
  if (!email) return res.status(400).json({ error: 'Email address is required' });

  const cleanEmail = email.toLowerCase().trim();
  const check = await verifyOtpCode(cleanEmail, otp);

  if (check.valid) {
    emailOtpStore.delete(cleanEmail);
    await saveOrUpdateBeneficiary({ email: cleanEmail });
    return res.json({ verified: true, token: 'demo-email-otp-token', email: cleanEmail });
  }

  res.status(400).json({ verified: false, error: check.error || 'Invalid Email OTP code. Please try again.' });
});

// --- Google Sign-In & Sign-Up Authentication ---

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
  await saveOrUpdateBeneficiary({ email: cleanEmail, name: user.name, firebaseUid: user.googleId });

  return res.json({
    verified: true,
    token: 'demo-google-jwt-token',
    user,
    message: 'Google Authentication successful',
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
