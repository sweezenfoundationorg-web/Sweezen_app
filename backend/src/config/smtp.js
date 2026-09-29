const nodemailer = require('nodemailer');
const axios = require('axios');
require('dotenv').config();

// 1. Mailjet REST API v3.1 Email Dispatch (Bypasses SMTP port blocking on cloud containers)
const sendViaMailjetApi = async (toEmail, otpCode) => {
  const apiKey = process.env.MAILJET_API_KEY || process.env.MJ_APIKEY_PUBLIC;
  const secretKey = process.env.MAILJET_SECRET_KEY || process.env.MJ_APIKEY_PRIVATE;
  const senderEmail = process.env.MAILJET_SENDER_EMAIL || process.env.SMTP_EMAIL || 'noreply@sweezenfoundation.org';

  if (!apiKey || !secretKey) return null;

  try {
    const authHeader = 'Basic ' + Buffer.from(`${apiKey}:${secretKey}`).toString('base64');
    const payload = {
      Messages: [
        {
          From: {
            Email: senderEmail,
            Name: "Sweezen Foundation"
          },
          To: [
            {
              Email: toEmail,
              Name: "Sweezen Member"
            }
          ],
          Subject: "Your Sweezen Foundation Verification Code (OTP)",
          HTMLPart: `
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
        }
      ]
    };

    const res = await axios.post('https://api.mailjet.com/v3.1/send', payload, {
      headers: {
        'Authorization': authHeader,
        'Content-Type': 'application/json'
      },
      timeout: 10000
    });

    console.log(`[Mailjet REST API] OTP email successfully sent to ${toEmail}`);
    return { success: true, api: true, data: res.data };
  } catch (err) {
    console.error('[Mailjet REST API Error]', err.response ? err.response.data : err.message);
    return null;
  }
};

// 2. Mailjet / Nodemailer SMTP Transporter
const createTransporter = () => {
  const host = process.env.SMTP_HOST || 'in-v3.mailjet.com';
  const port = parseInt(process.env.SMTP_PORT || '587');
  const user = process.env.MAILJET_API_KEY || process.env.MJ_APIKEY_PUBLIC || process.env.SMTP_EMAIL || process.env.GMAIL_USER;
  const pass = process.env.MAILJET_SECRET_KEY || process.env.MJ_APIKEY_PRIVATE || process.env.SMTP_PASS || process.env.GMAIL_APP_PASSWORD;

  if (user && pass) {
    return nodemailer.createTransport({
      host: host,
      port: port,
      secure: port === 465,
      family: 4, // Force IPv4
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

// Main OTP Dispatcher (Tries Mailjet REST API -> Mailjet SMTP -> Gmail SMTP)
const sendOtpEmail = async (toEmail, otpCode) => {
  // 1. Try Mailjet REST API first
  const apiRes = await sendViaMailjetApi(toEmail, otpCode);
  if (apiRes && apiRes.success) {
    return apiRes;
  }

  // 2. Fallback to Mailjet / Nodemailer SMTP
  const transporter = createTransporter();
  const senderEmail = process.env.MAILJET_SENDER_EMAIL || process.env.SMTP_EMAIL || 'noreply@sweezenfoundation.org';

  const mailOptions = {
    from: `"Sweezen Foundation" <${senderEmail}>`,
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
      console.log(`[Mailjet SMTP] OTP email dispatched to ${toEmail}. MessageId: ${info.messageId}`);
      return { success: true, messageId: info.messageId };
    } catch (err) {
      console.error('[Mailjet SMTP Error]', err.message);
      console.log(`[DEV OTP] OTP for ${toEmail} is: ${otpCode}`);
      return { success: true, fallback: true, otp: otpCode };
    }
  } else {
    console.log(`[DEV MODE] No Mailjet credentials configured. Simulating OTP dispatch.`);
    console.log(`[OTP FOR ${toEmail}]: ${otpCode}`);
    return { success: true, simulated: true, otp: otpCode };
  }
};

module.exports = {
  sendOtpEmail
};
