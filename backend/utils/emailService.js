const nodemailer = require('nodemailer');

// Official Gmail SMTP configuration
const SMTP_HOST = process.env.SMTP_HOST || 'smtp.gmail.com';
const SMTP_PORT = process.env.SMTP_PORT || 587;
const SMTP_USER = process.env.SMTP_USER || 'dishasaathi@gmail.com';
const SMTP_PASS = process.env.SMTP_PASS || 'bvwy cehy xumg exya';

let transporter = null;

if (SMTP_USER && SMTP_PASS && SMTP_PASS !== 'YOUR_16_DIGIT_GMAIL_APP_PASSWORD') {
  const isPort465 = parseInt(SMTP_PORT, 10) === 465;
  transporter = nodemailer.createTransport({
    host: SMTP_HOST,
    port: parseInt(SMTP_PORT, 10),
    secure: isPort465, // true for 465, false for 587
    connectionTimeout: 10000,
    greetingTimeout: 10000,
    socketTimeout: 10000,
    auth: {
      user: SMTP_USER,
      pass: SMTP_PASS,
    },
    tls: {
      rejectUnauthorized: false,
    },
  });
}

/**
 * Sends a 6-digit OTP verification code from dishasaathi@gmail.com to the target email address.
 */
async function sendOtpEmail(toEmail, otpCode) {
  if (!transporter) {
    console.log(`[Demo Mode] Email OTP ${otpCode} generated for ${toEmail} (no SMTP transporter configured)`);
    return false;
  }

  try {
    const info = await transporter.sendMail({
      from: `"Disha Saathi AI" <${SMTP_USER}>`,
      to: toEmail,
      subject: 'Disha Saathi — Your 6-Digit Email Verification OTP',
      text: `Your OTP verification code for Disha Saathi is: ${otpCode}. Valid for 10 minutes.`,
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; background-color: #f4f6f9;">
          <div style="max-width: 500px; margin: 0 auto; background: #ffffff; padding: 25px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.1);">
            <h2 style="color: #0A192F; margin-top: 0;">Disha Saathi AI</h2>
            <p style="font-size: 15px; color: #333;">Welcome! Your 6-digit OTP code to verify your email address is:</p>
            <div style="text-align: center; margin: 25px 0;">
              <span style="font-size: 32px; font-weight: bold; letter-spacing: 6px; color: #00A884; background: #E6F7F2; padding: 12px 24px; border-radius: 8px; display: inline-block;">${otpCode}</span>
            </div>
            <p style="font-size: 13px; color: #666;">This code is valid for 10 minutes. Do not share this OTP with anyone.</p>
            <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;" />
            <p style="font-size: 11px; color: #999; text-align: center;">SIH 2026 · PS 26097 · Team The AI Alchemists</p>
          </div>
        </div>
      `,
    });

    console.log(`[SMTP Success] Email OTP ${otpCode} sent to ${toEmail} (messageId: ${info.messageId})`);
    return true;
  } catch (err) {
    console.warn(`[SMTP Warning] Failed to send email to ${toEmail}:`, err.message);
    return false;
  }
}

module.exports = { sendOtpEmail };
