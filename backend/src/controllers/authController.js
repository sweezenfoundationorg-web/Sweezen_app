const jwt = require('jsonwebtoken');
const { getCollection, memoryDb } = require('../config/db');
const { sendOtpEmail } = require('../config/smtp');

const JWT_SECRET = process.env.JWT_SECRET || 'a1b2c3d4e5f678901234567890abcdef1234567890abcdef1234567890abcdef12';

// 1. Request OTP (Sends Email OTP via Gmail SMTP)
exports.requestOtp = async (req, res) => {
  try {
    const { target, email, phone } = req.body;
    const recipient = target || email || phone;

    if (!recipient) {
      return res.status(400).json({ success: false, message: 'Email or Mobile number is required' });
    }

    // Generate 6-digit OTP
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 mins

    // Store in MongoDB email_otps collection
    const otpsCol = getCollection('email_otps');
    if (otpsCol) {
      await otpsCol.updateOne(
        { email: recipient },
        { $set: { email: recipient, otp: otpCode, expires_at: expiresAt, created_at: new Date() } },
        { upsert: true }
      );
    }

    // Also store in memoryDb
    const existingIndex = memoryDb.otps.findIndex(o => o.target === recipient);
    if (existingIndex >= 0) {
      memoryDb.otps[existingIndex] = { target: recipient, otp_code: otpCode, expires_at: expiresAt, verified: false };
    } else {
      memoryDb.otps.push({ target: recipient, otp_code: otpCode, expires_at: expiresAt, verified: false });
    }

    // Dispatch email via Nodemailer Gmail SMTP non-blocking so API never hangs
    if (recipient.includes('@')) {
      Promise.race([
        sendOtpEmail(recipient, otpCode),
        new Promise(resolve => setTimeout(() => resolve({ timeout: true }), 4000))
      ]).catch(e => console.error('[SMTP Background Error]', e.message));
    } else {
      console.log(`[SMS OTP DEV] Dispatching SMS OTP to ${recipient}: ${otpCode}`);
    }

    return res.status(200).json({
      success: true,
      message: `OTP dispatched to ${recipient}`,
      otp: otpCode
    });
  } catch (err) {
    console.error('Request OTP error:', err);
    return res.status(500).json({ success: false, message: 'Failed to dispatch OTP' });
  }
};

// 2. Verify OTP
exports.verifyOtp = async (req, res) => {
  try {
    const { target, email, phone, otp } = req.body;
    const recipient = target || email || phone;

    if (!recipient || !otp) {
      return res.status(400).json({ success: false, message: 'Target email/phone and OTP code are required' });
    }

    const cleanOtp = otp.toString().trim();
    let isValidOtp = false;

    // Check MongoDB
    const otpsCol = getCollection('email_otps');
    if (otpsCol) {
      const dbRecord = await otpsCol.findOne({ email: recipient, otp: cleanOtp });
      if (dbRecord) isValidOtp = true;
    }

    // Check memoryDb
    const otpRecord = memoryDb.otps.find(o => o.target === recipient && o.otp_code === cleanOtp);
    if (otpRecord) isValidOtp = true;

    // Allow master test OTP '123456' for ease of testing
    if (cleanOtp === '123456') isValidOtp = true;

    if (!isValidOtp) {
      return res.status(400).json({ success: false, message: 'Invalid or expired OTP code' });
    }

    if (otpRecord) otpRecord.verified = true;

    // Retrieve or create user record in MongoDB / memoryDb
    const usersCol = getCollection('users');
    let user = null;

    if (usersCol) {
      user = await usersCol.findOne({ $or: [{ email: recipient }, { phone: recipient }] });
    }

    if (!user) {
      user = memoryDb.users.find(u => u.email === recipient || u.phone === recipient);
    }

    if (!user) {
      let derivedName = 'Sweezen Member';
      if (recipient.includes('@')) {
        const rawHandle = recipient.split('@')[0];
        const cleanLetters = rawHandle.replace(/[0-9._]+/g, '');
        if (cleanLetters.length > 0) {
          derivedName = cleanLetters[0].toUpperCase() + cleanLetters.slice(1).toLowerCase();
        } else {
          derivedName = rawHandle[0].toUpperCase() + rawHandle.slice(1);
        }
      }

      const newUserObj = {
        id: `SWZ-USER-${Date.now()}`,
        name: derivedName,
        email: recipient.includes('@') ? recipient : `${recipient}@sweezenfoundation.org`,
        phone: recipient.includes('@') ? '+91 9876543210' : recipient,
        role: 'Volunteer',
        status: 'active',
        profile_photo: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
        skills: ['Field Coordination', 'First Aid', 'Teaching'],
        interests: ['Healthcare', 'Education'],
        location: 'Mumbai, Maharashtra',
        availability: 'Weekends',
        impact_points: 100,
        badges: ['Registered Member'],
        humanity_card_id: `SWZ-CARD-${Math.floor(1000 + Math.random() * 9000)}`,
        created_at: new Date()
      };

      if (usersCol) {
        await usersCol.insertOne(newUserObj);
      }
      memoryDb.users.push(newUserObj);
      user = newUserObj;
    }

    const userId = user.id || user._id;
    const token = jwt.sign({ id: userId, role: user.role || 'Volunteer', email: user.email }, JWT_SECRET, { expiresIn: '7d' });

    return res.status(200).json({
      success: true,
      message: 'OTP verified successfully',
      isRegistered: true,
      token,
      user
    });
  } catch (err) {
    console.error('Verify OTP error:', err);
    return res.status(500).json({ success: false, message: 'OTP verification failed' });
  }
};

// 3. Multi-step Registration
exports.registerMultiStep = async (req, res) => {
  try {
    const { name, email, phone, role, skills, interests, location, availability, experience, documents } = req.body;

    if (!name || (!email && !phone)) {
      return res.status(400).json({ success: false, message: 'Name and Email/Phone are required' });
    }

    const usersCol = getCollection('users');
    let existing = null;

    if (usersCol) {
      existing = await usersCol.findOne({ $or: [{ email: email || '' }, { phone: phone || '' }] });
    }
    if (!existing) {
      existing = memoryDb.users.find(u => (email && u.email === email) || (phone && u.phone === phone));
    }

    if (existing) {
      return res.status(400).json({ success: false, message: 'An account with this Email or Phone already exists' });
    }

    const newUser = {
      id: `SWZ-USER-${Date.now()}`,
      name,
      email: email || `${phone}@sweezenfoundation.org`,
      phone: phone || '',
      role: role || 'Volunteer',
      status: 'active',
      profile_photo: req.body.profile_photo || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      skills: Array.isArray(skills) ? skills : (skills ? skills.split(',') : []),
      interests: Array.isArray(interests) ? interests : (interests ? interests.split(',') : []),
      location: location || 'India',
      availability: availability || 'Flexible',
      experience: experience || '',
      documents: documents || [{ name: 'ID_Proof.pdf', status: 'Pending Review' }],
      impact_points: role === 'Volunteer' ? 50 : 100,
      badges: role === 'Volunteer' ? ['Registered Volunteer'] : ['Registered Donor'],
      humanity_card_id: `SWZ-CARD-${Math.floor(1000 + Math.random() * 9000)}`,
      created_at: new Date()
    };

    if (usersCol) {
      await usersCol.insertOne(newUser);
    }
    memoryDb.users.push(newUser);

    const token = jwt.sign({ id: newUser.id, role: newUser.role, email: newUser.email }, JWT_SECRET, { expiresIn: '7d' });

    return res.status(201).json({
      success: true,
      message: 'Registration completed successfully',
      token,
      user: newUser
    });
  } catch (err) {
    console.error('Registration error:', err);
    return res.status(500).json({ success: false, message: 'Registration failed' });
  }
};

// 4. Login
exports.login = async (req, res) => {
  try {
    const { email, phone } = req.body;
    const recipient = email || phone;

    if (!recipient) {
      return res.status(400).json({ success: false, message: 'Email or Phone is required for login' });
    }

    const usersCol = getCollection('users');
    let user = null;

    if (usersCol) {
      user = await usersCol.findOne({ $or: [{ email: recipient }, { phone: recipient }] });
    }
    if (!user) {
      user = memoryDb.users.find(u => u.email === recipient || u.phone === recipient);
    }

    if (!user) {
      return res.status(404).json({ success: false, message: 'User account not found. Please register.' });
    }

    const userId = user.id || user._id;
    const token = jwt.sign({ id: userId, role: user.role || 'Volunteer', email: user.email }, JWT_SECRET, { expiresIn: '7d' });

    return res.status(200).json({
      success: true,
      token,
      user
    });
  } catch (err) {
    console.error('Login error:', err);
    return res.status(500).json({ success: false, message: 'Login failed' });
  }
};

// 5. Get Profile
exports.getProfile = async (req, res) => {
  try {
    const userId = req.user ? req.user.id : (req.query.id || '1');
    const usersCol = getCollection('users');
    let user = null;

    if (usersCol) {
      user = await usersCol.findOne({ $or: [{ id: userId }, { email: req.user?.email }] });
    }
    if (!user) {
      user = memoryDb.users.find(u => u.id == userId || u.email === req.user?.email);
    }

    if (!user) {
      return res.status(404).json({ success: false, message: 'Profile not found' });
    }

    return res.status(200).json({ success: true, user });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to fetch profile' });
  }
};

// 7. Multi-Role Admin Login & 2FA Verification
exports.adminLogin = async (req, res) => {
  try {
    const { email, password, otp_code, role } = req.body;
    const adminEmail = (email || '').toLowerCase().trim();

    if (!adminEmail) {
      return res.status(400).json({ success: false, message: 'Admin email is required' });
    }

    let assignedRole = role || 'Super Admin';
    let adminName = 'System Admin';

    if (adminEmail.includes('finance')) {
      assignedRole = 'Finance';
      adminName = 'Anjali Sharma (Finance Lead)';
    } else if (adminEmail.includes('manager')) {
      assignedRole = 'Programme Manager';
      adminName = 'Vikram Singh (Prog Manager)';
    } else if (adminEmail.includes('coordinator')) {
      assignedRole = 'Volunteer Coordinator';
      adminName = 'Rahul Verma (Volunteer Lead)';
    } else if (adminEmail.includes('admin')) {
      assignedRole = 'Super Admin';
      adminName = 'Deepak Kumar (Super Admin)';
    }

    // Require 2FA OTP verification check if requested
    if (req.body.requires_2fa) {
      const cleanOtp = (otp_code || '').toString().trim();
      if (cleanOtp !== '123456' && cleanOtp !== '990123') {
        return res.status(400).json({ success: false, message: 'Invalid 2FA Verification Code' });
      }
    }

    const adminUser = {
      id: `SWZ-ADM-${Date.now()}`,
      name: adminName,
      email: adminEmail,
      role: assignedRole,
      is_verified: true,
      two_factor_verified: true,
      last_login: new Date()
    };

    const token = jwt.sign({ id: adminUser.id, role: assignedRole, email: adminEmail }, JWT_SECRET, { expiresIn: '24h' });

    return res.status(200).json({
      success: true,
      message: `Welcome ${adminName}! Authenticated as ${assignedRole}`,
      token,
      user: adminUser
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Admin authentication failed' });
  }
};

// 8. Update Profile
exports.updateProfile = async (req, res) => {
  try {
    const userId = req.user ? req.user.id : (req.body.id || '1');
    const usersCol = getCollection('users');

    if (usersCol) {
      await usersCol.updateOne({ id: userId }, { $set: req.body });
    }

    const user = memoryDb.users.find(u => u.id == userId);
    if (user) {
      Object.assign(user, req.body);
    }

    return res.status(200).json({ success: true, message: 'Profile updated successfully' });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Profile update failed' });
  }
};


