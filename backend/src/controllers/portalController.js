const { memoryDb } = require('../config/db');

/**
 * Hospital & Education Portals Controller
 * Handles Partner Registrations, Patient/Student Referrals, Camp Schedules & Student Progress.
 */

// 1. Partner Registrations
exports.getPartners = (req, res) => {
  try {
    const partners = memoryDb.portalPartners || [];
    return res.status(200).json({ success: true, count: partners.length, data: partners });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.registerPartner = (req, res) => {
  try {
    const { name, type, location, contactPerson, phone } = req.body;
    if (!name || !type || !contactPerson) {
      return res.status(400).json({ success: false, message: 'Institution Name, Type (Hospital/Education), and Contact Person are required.' });
    }

    const newPartner = {
      id: (memoryDb.portalPartners?.length || 0) + 1,
      name,
      type,
      location: location || 'Haridwar, Uttarakhand',
      status: 'Verified',
      contactPerson,
      phone: phone || '+91-9000000000',
      createdAt: new Date()
    };

    memoryDb.portalPartners.push(newPartner);
    return res.status(201).json({ success: true, message: 'Institutional Partner registered successfully.', data: newPartner });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

// 2. Patient / Student Referrals
exports.getReferrals = (req, res) => {
  try {
    const referrals = memoryDb.portalReferrals || [];
    return res.status(200).json({ success: true, count: referrals.length, data: referrals });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.createReferral = (req, res) => {
  try {
    const { partnerName, type, patientOrStudentName, diagnosisOrNeed, urgency } = req.body;
    if (!partnerName || !patientOrStudentName || !diagnosisOrNeed) {
      return res.status(400).json({ success: false, message: 'Partner name, beneficiary name, and diagnosis/need are required.' });
    }

    const newReferral = {
      id: `REF-${Math.floor(1000 + Math.random() * 9000)}`,
      partnerName,
      type: type || 'Medical Surgery',
      patientOrStudentName,
      diagnosisOrNeed,
      status: 'Under Review',
      urgency: urgency || 'Medium',
      date: new Date().toISOString().split('T')[0]
    };

    memoryDb.portalReferrals.unshift(newReferral);
    return res.status(201).json({ success: true, message: 'Referral request created and submitted.', data: newReferral });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

// 3. Camp Schedules
exports.getCampSchedules = (req, res) => {
  try {
    const camps = memoryDb.portalCamps || [];
    return res.status(200).json({ success: true, count: camps.length, data: camps });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.createCampSchedule = (req, res) => {
  try {
    const { title, facility, location, date, time, capacity } = req.body;
    if (!title || !location || !date) {
      return res.status(400).json({ success: false, message: 'Title, location, and date are required.' });
    }

    const newCamp = {
      id: `CAMP-${Math.floor(100 + Math.random() * 900)}`,
      title,
      facility: facility || 'Sweezen Healthcare Partner Team',
      location,
      date,
      time: time || '10:00 AM - 04:00 PM',
      capacity: Number(capacity) || 200,
      registeredCount: 0,
      status: 'Upcoming'
    };

    memoryDb.portalCamps.unshift(newCamp);
    return res.status(201).json({ success: true, message: 'Camp scheduled successfully.', data: newCamp });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

// 4. Student Progress Tracking
exports.getStudentProgress = (req, res) => {
  try {
    const records = memoryDb.portalStudentProgress || [];
    return res.status(200).json({ success: true, count: records.length, data: records });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.addStudentProgress = (req, res) => {
  try {
    const { name, grade, school, attendance, academicScore, healthScore, kitStatus } = req.body;
    if (!name || !school) {
      return res.status(400).json({ success: false, message: 'Student name and school are required.' });
    }

    const newRecord = {
      id: `STU-${Math.floor(900 + Math.random() * 100)}`,
      name,
      grade: grade || 'Class 6',
      school,
      attendance: attendance || '95%',
      academicScore: academicScore || '85% (Grade A)',
      healthScore: healthScore || 'Good (Normal)',
      kitStatus: kitStatus || 'Distributed Current Term'
    };

    memoryDb.portalStudentProgress.unshift(newRecord);
    return res.status(201).json({ success: true, message: 'Student progress record logged.', data: newRecord });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};
