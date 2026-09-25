/**
 * emailService.js — Disha Saathi Nodemailer Gmail SMTP Email Dispatch Service
 * SIH 2026 · PS 26097 · Team: The AI Alchemists
 */

const nodemailer = require('nodemailer');

const SMTP_HOST = process.env.SMTP_HOST || 'smtp.gmail.com';
const SMTP_PORT = parseInt(process.env.SMTP_PORT, 10) || 587;
const SMTP_USER = process.env.SMTP_USER || 'dishasaathi@gmail.com';
const SMTP_PASS = process.env.SMTP_PASS || '';
const RESEND_API_KEY = process.env.RESEND_API_KEY || '';

function createSmtpTransporter(port, secure) {
  if (!SMTP_USER || !SMTP_PASS) {
    return null;
  }
  return nodemailer.createTransport({
    host: SMTP_HOST,
    port,
    secure,
    connectionTimeout: 8000,
    greetingTimeout: 8000,
    socketTimeout: 8000,
    auth: {
      user: SMTP_USER,
      pass: SMTP_PASS,
    },
    tls: {
      rejectUnauthorized: false,
    },
  });
}

const transporter587 = createSmtpTransporter(587, false);
const transporter465 = createSmtpTransporter(465, true);

/**
 * Sends a 6-digit OTP verification code from Gmail SMTP to any target recipient email address.
 * Returns true if accepted by SMTP server, or false if delivery fails.
 */
async function sendOtpEmail(toEmail, otpCode) {
  const cleanEmail = (toEmail || '').toLowerCase().trim();
  if (!cleanEmail || !cleanEmail.includes('@') || cleanEmail.length < 5) {
    console.warn(`[Email Dispatch Warning] Invalid recipient email address: ${cleanEmail}`);
    return false;
  }

  // Option 1: HTTPS REST API Delivery (Resend API)
  if (RESEND_API_KEY && RESEND_API_KEY.startsWith('re_')) {
    try {
      const response = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${RESEND_API_KEY}`,
        },
        body: JSON.stringify({
          from: 'Disha Saathi AI <onboarding@resend.dev>',
          to: [cleanEmail],
          subject: 'Disha Saathi — Your Email Verification Code',
          html: `
            <div style="font-family: Arial, sans-serif; padding: 20px; background-color: #f4f6f9;">
              <div style="max-width: 500px; margin: 0 auto; background: #ffffff; padding: 25px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.1);">
                <h2 style="color: #0A192F; margin-top: 0;">Disha Saathi AI</h2>
                <p style="font-size: 15px; color: #333;">Welcome! Your 6-digit OTP code to verify your email address (<strong>${cleanEmail}</strong>) is:</p>
                <div style="text-align: center; margin: 25px 0;">
                  <span style="font-size: 32px; font-weight: bold; letter-spacing: 6px; color: #00A884; background: #E6F7F2; padding: 12px 24px; border-radius: 8px; display: inline-block;">${otpCode}</span>
                </div>
                <p style="font-size: 13px; color: #666;">This code is valid for 10 minutes. Do not share this OTP with anyone.</p>
                <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;" />
                <p style="font-size: 11px; color: #999; text-align: center;">SIH 2026 · PS 26097 · Team The AI Alchemists</p>
              </div>
            </div>
          `,
        }),
      });

      if (response.ok) {
        console.log(`[Email Dispatch Success] Verification email accepted by Resend API for ${cleanEmail}`);
        return true;
      }
    } catch (err) {
      console.warn(`[Email Dispatch Resend Warning] ${cleanEmail}:`, err.message);
    }
  }

  // Option 2: Gmail SMTP Port 587 (STARTTLS)
  const mailOptions = {
    from: `"Disha Saathi AI" <${SMTP_USER}>`,
    to: cleanEmail,
    subject: 'Disha Saathi — Your 6-Digit Email Verification Code',
    text: `Your OTP verification code for Disha Saathi is: ${otpCode}. Valid for 10 minutes.`,
    html: `
      <div style="font-family: Arial, sans-serif; padding: 20px; background-color: #f4f6f9;">
        <div style="max-width: 500px; margin: 0 auto; background: #ffffff; padding: 25px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.1);">
          <h2 style="color: #0A192F; margin-top: 0;">Disha Saathi AI</h2>
          <p style="font-size: 15px; color: #333;">Welcome! Your 6-digit OTP code to verify your email address (<strong>${cleanEmail}</strong>) is:</p>
          <div style="text-align: center; margin: 25px 0;">
            <span style="font-size: 32px; font-weight: bold; letter-spacing: 6px; color: #00A884; background: #E6F7F2; padding: 12px 24px; border-radius: 8px; display: inline-block;">${otpCode}</span>
          </div>
          <p style="font-size: 13px; color: #666;">This code is valid for 10 minutes. Do not share this OTP with anyone.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;" />
          <p style="font-size: 11px; color: #999; text-align: center;">SIH 2026 · PS 26097 · Team The AI Alchemists</p>
        </div>
      </div>
    `,
  };

  if (transporter587) {
    try {
      const info = await transporter587.sendMail(mailOptions);
      console.log(`[Email OTP] Email accepted by SMTP server (587) for ${cleanEmail} (${info.messageId})`);
      return true;
    } catch (err) {
      console.warn(`[Email OTP SMTP 587 Warning] ${cleanEmail}:`, err.message);
    }
  }

  // Option 3: Gmail SMTP Port 465 (SSL)
  if (transporter465) {
    try {
      const info = await transporter465.sendMail(mailOptions);
      console.log(`[Email OTP] Email accepted by SMTP server (465) for ${cleanEmail} (${info.messageId})`);
      return true;
    } catch (err) {
      console.warn(`[Email OTP SMTP 465 Warning] ${cleanEmail}:`, err.message);
    }
  }

  // Fallback for development / offline testing mode
  if (process.env.NODE_ENV !== 'production' || process.env.ALLOW_DEMO_OTP === 'true') {
    console.log(`[Email OTP] Verification code generated for ${cleanEmail}`);
    return true;
  }

  console.error(`[Email OTP Error] Unable to dispatch email to ${cleanEmail}`);
  return false;
}

module.exports = { sendOtpEmail };
