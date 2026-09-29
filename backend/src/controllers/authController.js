const jwt = require('jsonwebtoken');
const { memoryDb } = require('../config/db');
const { sendOtpEmail } = require('../config/smtp');

const JWT_SECRET = process.env.JWT_SECRET || 'sweezen_jwt_secret_key_2026';

// Send OTP
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

    // Store in memoryDb
    const existingIndex = memoryDb.otps.findIndex(o => o.target === recipient);
    if (existingIndex >= 0) {
      memoryDb.otps[existingIndex] = { target: recipient, otp_code: otpCode, expires_at: expiresAt, verified: false };
    } else {
      memoryDb.otps.push({ target: recipient, otp_code: otpCode, expires_at: expiresAt, verified: false });
    }

    // Send email via Nodemailer Gmail SMTP if recipient looks like an email
    if (recipient.includes('@')) {
      await sendOtpEmail(recipient, otpCode);
    } else {
      console.log(`[SMS OTP DEV] Sending SMS OTP to ${recipient}: ${otpCode}`);
    }

    return res.status(200).json({
      success: true,
      message: `OTP sent successfully to ${recipient}`,
      otp: process.env.NODE_ENV === 'production' ? undefined : otpCode // Returned for dev ease
    });
  } catch (err) {
    console.error('Request OTP error:', err);
    return res.status(500).json({ success: false, message: 'Failed to dispatch OTP' });
  }
};

// Verify OTP
exports.verifyOtp = async (req, res) => {
  try {
    const { target, email, phone, otp } = req.body;
    const recipient = target || email || phone;

    if (!recipient || !otp) {
      return res.status(400).json({ success: false, message: 'Target and OTP code are required' });
    }

    const otpRecord = memoryDb.otps.find(o => o.target === recipient && o.otp_code === otp.trim());

    // Allow static master OTP '123456' for test convenience
    if (!otpRecord && otp.trim() !== '123456') {
      return res.status(400).json({ success: false, message: 'Invalid or expired OTP code' });
    }

    if (otpRecord) {
      otpRecord.verified = true;
    }

    // Check if user already exists
    let user = memoryDb.users.find(u => u.email === recipient || u.phone === recipient);
    
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

      user = {
        id: memoryDb.users.length + 1,
        name: derivedName,
        email: recipient.includes('@') ? recipient : `${recipient}@sweezen.org`,
        phone: recipient.includes('@') ? '+91 9876543210' : recipient,
        role: 'Volunteer',
        profile_photo: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
        skills: ['Field Coordination', 'First Aid'],
        interests: ['Healthcare', 'Education'],
        location: 'Mumbai, Maharashtra',
        availability: 'Weekends',
        impact_points: 100,
        badges: ['Registered Member'],
        humanity_card_id: `SWZ-CARD-${Math.floor(1000 + Math.random() * 9000)}`,
        created_at: new Date()
      };
      memoryDb.users.push(user);
    }

    const token = jwt.sign({ id: user.id, role: user.role, email: user.email }, JWT_SECRET, { expiresIn: '7d' });

    return res.status(200).json({
      success: true,
      message: 'OTP verified successfully',
      isRegistered: true,
      token: token,
      user: user
    });
  } catch (err) {
    console.error('Verify OTP error:', err);
    return res.status(500).json({ success: false, message: 'OTP verification failed' });
  }
};

// Multi-step Registration
exports.registerMultiStep = async (req, res) => {
  try {
    const {
      name,
      email,
      phone,
      role, // Volunteer, Donor, Researcher, Beneficiary, Staff, Partner
      skills,
      interests,
      location,
      availability,
      experience,
      documents
    } = req.body;

    if (!name || (!email && !phone)) {
      return res.status(400).json({ success: false, message: 'Name and Email/Phone are required' });
    }

    // Check existing
    const existing = memoryDb.users.find(u => (email && u.email === email) || (phone && u.phone === phone));
    if (existing) {
      return res.status(400).json({ success: false, message: 'An account with this Email or Phone already exists' });
    }

    const newUser = {
      id: memoryDb.users.length + 1,
      name,
      email: email || `${phone}@sweezen.org`,
      phone: phone || '',
      role: role || 'Volunteer',
      profile_photo: req.body.profile_photo || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      skills: Array.isArray(skills) ? skills : (skills ? skills.split(',') : []),
      interests: Array.isArray(interests) ? interests : (interests ? interests.split(',') : []),
      location: location || 'India',
      availability: availability || 'Flexible',
      experience: experience || '',
      documents: documents || [{ name: 'ID_Proof.pdf', status: 'Pending Review' }],
      impact_points: role === 'Volunteer' ? 50 : 100, // Welcome points
      badges: role === 'Volunteer' ? ['Registered Volunteer'] : ['Registered Donor'],
      humanity_card_id: `SWZ-CARD-${Math.floor(1000 + Math.random() * 9000)}`,
      created_at: new Date()
    };

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

// Login
exports.login = async (req, res) => {
  try {
    const { email, phone } = req.body;
    const recipient = email || phone;
    const user = memoryDb.users.find(u => u.email === recipient || u.phone === recipient);

    if (!user) {
      return res.status(404).json({ success: false, message: 'User account not found. Please register.' });
    }

    const token = jwt.sign({ id: user.id, role: user.role, email: user.email }, JWT_SECRET, { expiresIn: '7d' });

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

// Get Profile
exports.getProfile = async (req, res) => {
  try {
    const userId = req.user ? req.user.id : parseInt(req.query.id || '1');
    const user = memoryDb.users.find(u => u.id === userId);

    if (!user) {
      return res.status(404).json({ success: false, message: 'Profile not found' });
    }

    return res.status(200).json({ success: true, user });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to fetch profile' });
  }
};

// Update Profile
exports.updateProfile = async (req, res) => {
  try {
    const userId = req.user ? req.user.id : parseInt(req.body.id || '1');
    const user = memoryDb.users.find(u => u.id === userId);

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    Object.assign(user, req.body);
    return res.status(200).json({ success: true, message: 'Profile updated successfully', user });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Profile update failed' });
  }
};
