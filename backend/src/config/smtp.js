const nodemailer = require('nodemailer');
require('dotenv').config();

const createTransporter = () => {
  const user = process.env.SMTP_EMAIL || process.env.GMAIL_USER;
  const pass = process.env.SMTP_PASS || process.env.GMAIL_APP_PASSWORD;

  if (user && pass) {
    return nodemailer.createTransport({
      host: 'smtp.gmail.com',
      port: 465,
      secure: true, // Port 465 SSL
      family: 4,    // FORCE IPv4 to avoid ENETUNREACH IPv6 error on Render cloud servers
      auth: {
        user: user,
        pass: pass
      },
      tls: {
        rejectUnauthorized: false
      }
    });
  }
  return null;
};

const sendOtpEmail = async (toEmail, otpCode) => {
  const transporter = createTransporter();
  const mailOptions = {
    from: `"Sweezen Foundation" <${process.env.SMTP_EMAIL || 'noreply@sweezenfoundation.org'}>`,
    to: toEmail,
    subject: 'Your Sweezen Foundation Verification Code (OTP)',
    html: `
      <div style="font-family: Arial, sans-serif; background-color: #0b132b; padding: 25px; color: #ffffff; border-radius: 8px;">
        <div style="text-align: center; margin-bottom: 20px;">
          <h2 style="color: #d4af37; margin: 0; font-size: 24px;">SWEEZEN FOUNDATION</h2>
          <p style="color: #94a3b8; font-size: 14px;">Empowering Communities • Changing Lives</p>
        </div>
        <div style="background-color: #152238; padding: 20px; border-radius: 6px; text-align: center; border: 1px solid #d4af37;">
          <h3 style="margin-top: 0; color: #ffffff;">Your One-Time Password (OTP)</h3>
          <div style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #f5a623; margin: 20px 0;">
            ${otpCode}
          </div>
          <p style="font-size: 13px; color: #94a3b8;">This code is valid for 10 minutes. Do not share this OTP with anyone.</p>
        </div>
        <p style="font-size: 12px; color: #64748b; text-align: center; margin-top: 20px;">
          © ${new Date().getFullYear()} Sweezen Foundation. All rights reserved.
        </p>
      </div>
    `
  };

  if (transporter) {
    try {
      const info = await transporter.sendMail(mailOptions);
      console.log(`[Gmail SMTP] OTP email dispatched to ${toEmail}. MessageId: ${info.messageId}`);
      return { success: true, messageId: info.messageId };
    } catch (err) {
      console.error('[Gmail SMTP] Error sending email via SMTP:', err.message);
      console.log(`[FALLBACK DEV OTP] OTP for ${toEmail} is: ${otpCode}`);
      return { success: true, fallback: true, otp: otpCode };
    }
  } else {
    console.log(`[SMTP DEV MODE] No SMTP_EMAIL configured. Simulating Gmail dispatch.`);
    console.log(`[OTP FOR ${toEmail}]: ${otpCode}`);
    return { success: true, simulated: true, otp: otpCode };
  }
};

module.exports = {
  sendOtpEmail
};
