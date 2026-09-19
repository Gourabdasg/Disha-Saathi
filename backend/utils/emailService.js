const nodemailer = require('nodemailer');

// Optional SMTP configuration from backend/.env
const SMTP_HOST = process.env.SMTP_HOST || 'smtp.gmail.com';
const SMTP_PORT = process.env.SMTP_PORT || 587;
const SMTP_USER = process.env.SMTP_USER || '';
const SMTP_PASS = process.env.SMTP_PASS || '';

let transporter = null;

if (SMTP_USER && SMTP_PASS) {
  transporter = nodemailer.createTransport({
    host: SMTP_HOST,
    port: parseInt(SMTP_PORT, 10),
    secure: SMTP_PORT == 465,
    auth: {
      user: SMTP_USER,
      pass: SMTP_PASS,
    },
  });
}

/**
 * Sends a 6-digit OTP verification code to the target email address.
 * Returns true if sent via SMTP, or false if running in demo/offline mode.
 */
async function sendOtpEmail(toEmail, otpCode) {
  if (transporter) {
    try {
      await transporter.sendMail({
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
      console.log(`[SMTP] Email OTP ${otpCode} successfully sent to ${toEmail}`);
      return true;
    } catch (err) {
      console.warn(`[SMTP Warning] Failed to send email to ${toEmail}:`, err.message);
    }
  }
  return false;
}

module.exports = { sendOtpEmail };
