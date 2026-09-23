const nodemailer = require('nodemailer');

// Official Gmail SMTP configuration
const SMTP_HOST = process.env.SMTP_HOST || 'smtp.gmail.com';
const SMTP_PORT = process.env.SMTP_PORT || 587;
const SMTP_USER = process.env.SMTP_USER || 'dishasaathi@gmail.com';
const SMTP_PASS = process.env.SMTP_PASS || 'bvwy cehy xumg exya';
const RESEND_API_KEY = process.env.RESEND_API_KEY || '';

function createTransporter(port, secure) {
  if (!SMTP_USER || !SMTP_PASS || SMTP_PASS === 'YOUR_16_DIGIT_GMAIL_APP_PASSWORD') {
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

const transporter587 = createTransporter(587, false);
const transporter465 = createTransporter(465, true);

/**
 * Sends a 6-digit OTP verification code from dishasaathi@gmail.com to the target email address.
 * Uses Resend HTTPS REST API (if RESEND_API_KEY is configured), Port 587 STARTTLS, or Port 465 SSL.
 */
async function sendOtpEmail(toEmail, otpCode) {
  // Option 1: Fast Resend HTTPS REST API
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
          to: [toEmail],
          subject: 'Disha Saathi — Your 6-Digit Email Verification OTP',
          html: `<p>Your Disha Saathi OTP verification code is: <strong>${otpCode}</strong>. Valid for 10 minutes.</p>`,
        }),
      });

      if (response.ok) {
        console.log(`[Resend API Success] Email OTP ${otpCode} sent to ${toEmail}`);
        return true;
      } else {
        const errorData = await response.text();
        console.warn(`[Resend API Error] ${toEmail}:`, errorData);
      }
    } catch (err) {
      console.warn(`[Resend API Exception] ${toEmail}:`, err.message);
    }
  }

  // Option 2: Nodemailer Gmail SMTP Port 587 (STARTTLS)
  const mailOptions = {
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
  };

  if (transporter587) {
    try {
      const info = await transporter587.sendMail(mailOptions);
      console.log(`[SMTP 587 Success] Email OTP ${otpCode} sent to ${toEmail} (${info.messageId})`);
      return true;
    } catch (err) {
      console.warn(`[SMTP 587 Warning] ${toEmail}:`, err.message);
    }
  }

  // Option 3: Nodemailer Gmail SMTP Port 465 (SSL)
  if (transporter465) {
    try {
      const info = await transporter465.sendMail(mailOptions);
      console.log(`[SMTP 465 Success] Email OTP ${otpCode} sent to ${toEmail} (${info.messageId})`);
      return true;
    } catch (err) {
      console.warn(`[SMTP 465 Warning] ${toEmail}:`, err.message);
    }
  }

  console.error(`[SMTP Fatal Error] All email delivery methods failed for ${toEmail}`);
  return false;
}

module.exports = { sendOtpEmail };
