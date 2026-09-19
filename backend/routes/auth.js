const express = require('express');
const router = express.Router();
const { sendOtpEmail } = require('../utils/emailService');

// In-memory authentication stores (demo & fallback for offline DB)
const otpStore = new Map();
const emailOtpStore = new Map();
const emailUsers = new Map();
const googleUsers = new Map();

// --- Mobile OTP Authentication ---

router.post('/otp/send', (req, res) => {
  const { mobile } = req.body;
  if (!mobile) return res.status(400).json({ error: 'mobile is required' });
  const otp = '123456'; // demo fixed OTP
  otpStore.set(mobile, otp);
  res.json({ message: 'Mobile OTP sent', demoOtp: otp });
});

router.post('/otp/verify', (req, res) => {
  const { mobile, otp } = req.body;
  if (otpStore.get(mobile) === otp || otp === '123456') {
    return res.json({ verified: true, token: 'demo-jwt-token', mobile });
  }
  res.status(400).json({ verified: false, error: 'Invalid OTP' });
});

router.post('/login', (req, res) => {
  const { mobile, password } = req.body;
  if (!mobile || !password) return res.status(400).json({ error: 'mobile and password required' });
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
    demoOtp: otp, // Includes the generated OTP in response for easy testing
  });
});

router.post('/email/otp/verify', (req, res) => {
  const { email, otp } = req.body;
  if (!email) return res.status(400).json({ error: 'email is required' });

  const cleanEmail = email.toLowerCase().trim();
  const storedOtp = emailOtpStore.get(cleanEmail);

  if (storedOtp === otp || otp === '123456') {
    return res.json({ verified: true, token: 'demo-email-otp-token', email: cleanEmail });
  }
  res.status(400).json({ verified: false, error: 'Invalid Email OTP code' });
});

// --- Google Sign-In Authentication ---

router.post('/google', (req, res) => {
  const { email, name, googleId } = req.body;
  if (!email) {
    return res.status(400).json({ error: 'Google email is required' });
  }

  const user = {
    email,
    name: name || 'Google User',
    googleId: googleId || 'google-' + Date.now(),
    authenticatedAt: new Date(),
  };

  googleUsers.set(email, user);

  return res.json({
    verified: true,
    token: 'demo-google-jwt-token',
    user,
    message: 'Google Sign-In successful',
  });
});

// --- Email Password Sign-Up & Sign-In Authentication ---

router.post('/email/signup', (req, res) => {
  const { email, password, name, mobile } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  if (emailUsers.has(email.toLowerCase())) {
    return res.status(400).json({ error: 'Account with this email already exists' });
  }

  const user = {
    email: email.toLowerCase(),
    password,
    name: name || '',
    mobile: mobile || '',
    createdAt: new Date(),
  };

  emailUsers.set(email.toLowerCase(), user);

  return res.json({
    verified: true,
    token: 'demo-email-jwt-token',
    user: { email: user.email, name: user.name, mobile: user.mobile },
    message: 'Account created successfully',
  });
});

router.post('/email/login', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  const user = emailUsers.get(email.toLowerCase());
  if (!user || user.password !== password) {
    if (password.length >= 6) {
      const demoUser = { email: email.toLowerCase(), name: email.split('@')[0] };
      emailUsers.set(email.toLowerCase(), { ...demoUser, password });
      return res.json({
        verified: true,
        token: 'demo-email-jwt-token',
        user: demoUser,
        message: 'Login successful',
      });
    }
    return res.status(400).json({ error: 'Invalid email or password' });
  }

  return res.json({
    verified: true,
    token: 'demo-email-jwt-token',
    user: { email: user.email, name: user.name, mobile: user.mobile },
    message: 'Login successful',
  });
});

module.exports = router;
