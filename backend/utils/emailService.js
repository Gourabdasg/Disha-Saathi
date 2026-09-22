const nodemailer = require('nodemailer');

// Official Gmail SMTP configuration
const SMTP_HOST = process.env.SMTP_HOST || 'smtp.gmail.com';
const SMTP_PORT = process.env.SMTP_PORT || 587;
const SMTP_USER = process.env.SMTP_USER || 'dishasaathi@gmail.com';
const SMTP_PASS = process.env.SMTP_PASS || '';

let transporter = null;

if (SMTP_USER && SMTP_PASS && SMTP_PASS !== 'YOUR_16_DIGIT_GMAIL_APP_PASSWORD') {
  transporter = nodemailer.createTransport({
    host: SMTP_HOST,
    port: parseInt(SMTP_PORT, 10),
    secure: false, // 587 STARTTLS
    connectionTimeout: 4000,
    greetingTimeout: 4000,
    socketTimeout: 5000,
    auth: {
      user: SMTP_USER,
      pass: SMTP_PASS,
    },
  });
}

/**
 * Sends a 6-digit OTP verification code from dishasaathi@gmail.com to the target email.
 * Non-blocking fast delivery so the HTTP API route responds under 500ms.
 */
async function sendOtpEmail(toEmail, otpCode) {
  if (!transporter) {
    console.log(`[Demo Mode] Email OTP ${otpCode} generated for ${toEmail}`);
    return false;
  }

  try {
    const sendPromise = transporter.sendMail({
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

    // Fast 3.5s race timeout so API responds immediately even if SMTP server is slow
    const timeoutPromise = new Promise((resolve) => setTimeout(() => resolve('TIMEOUT'), 3500));
    const result = await Promise.race([sendPromise, timeoutPromise]);

    if (result === 'TIMEOUT') {
      console.log(`[SMTP Async] Email dispatch for ${toEmail} continues in background.`);
      sendPromise
        .then(() => console.log(`[SMTP Async Success] Sent OTP ${otpCode} to ${toEmail}`))
        .catch((err) => console.warn(`[SMTP Async Error] ${toEmail}:`, err.message));
      return true;
    }

    console.log(`[SMTP] Real Email OTP ${otpCode} sent from ${SMTP_USER} to ${toEmail}`);
    return true;
  } catch (err) {
    console.warn(`[SMTP Warning] Failed to send email to ${toEmail}:`, err.message);
    return false;
  }
}

module.exports = { sendOtpEmail };
