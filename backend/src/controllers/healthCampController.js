const { getCollection, memoryDb } = require('../config/db');
const { logAudit } = require('../services/auditLogService');

if (!memoryDb.healthCamps) {
  memoryDb.healthCamps = [
    {
      id: 101,
      title: 'Haridwar Multi-Specialty Free Health Camp',
      district: 'Haridwar',
      location: 'Community Centre, Kankhal, Haridwar',
      date_time: new Date(Date.now() + 86400000 * 3),
      doctor_incharge: 'Dr. R. K. Sharma (MD)',
      services_offered: ['General Checkup', 'Blood Sugar', 'Eye Testing', 'Free Medicines'],
      capacity: 200,
      booked_count: 42,
      status: 'Scheduled'
    },
    {
      id: 102,
      title: 'Dehradun Rural Healthcare & Pediatrics Drive',
      district: 'Dehradun',
      location: 'Panchayat Bhavan, Vikasnagar, Dehradun',
      date_time: new Date(Date.now() + 86400000 * 7),
      doctor_incharge: 'Dr. Anita Verma (Pediatrician)',
      services_offered: ['Pediatric Care', 'Vaccination Drive', 'Nutritional Supplements'],
      capacity: 150,
      booked_count: 28,
      status: 'Scheduled'
    },
    {
      id: 103,
      title: 'Rishikesh Eye & Cataract Screening Camp',
      district: 'Dehradun',
      location: 'Municipal Ground, Rishikesh',
      date_time: new Date(Date.now() + 86400000 * 12),
      doctor_incharge: 'Dr. S. P. Gupta (Ophthalmologist)',
      services_offered: ['Cataract Screening', 'Free Spectacles Distribution'],
      capacity: 180,
      booked_count: 89,
      status: 'Scheduled'
    }
  ];
}

if (!memoryDb.healthCampBookings) {
  memoryDb.healthCampBookings = [];
}

// 1. Get Health Camps (with district filtering)
exports.getHealthCamps = async (req, res) => {
  try {
    const { district } = req.query;
    let list = memoryDb.healthCamps;

    if (district && district !== 'All') {
      list = list.filter(c => c.district.toLowerCase() === district.toLowerCase());
    }

    return res.status(200).json({
      success: true,
      districts: ['Haridwar', 'Dehradun', 'Tehri Garhwal', 'Pauri Garhwal', 'Udhamsingh Nagar'],
      count: list.length,
      camps: list
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to fetch health camps' });
  }
};

// 2. Book Slot at Health Camp & generate QR
exports.bookCampSlot = async (req, res) => {
  try {
    const { camp_id, beneficiary_name, phone } = req.body;
    const campId = parseInt(camp_id);

    const camp = memoryDb.healthCamps.find(c => c.id === campId);
    if (!camp) {
      return res.status(404).json({ success: false, message: 'Health camp not found' });
    }

    if (camp.booked_count >= camp.capacity) {
      return res.status(400).json({ success: false, message: 'Health camp is fully booked!' });
    }

    camp.booked_count += 1;

    const booking = {
      id: `SWZ-HCB-${Date.now()}`,
      camp_id: camp.id,
      camp_title: camp.title,
      beneficiary_name: beneficiary_name || 'Beneficiary',
      phone: phone || '',
      booking_qr: `CAMP:${camp.id}:${Date.now()}`,
      status: 'Confirmed',
      booked_at: new Date()
    };

    memoryDb.healthCampBookings.push(booking);

    await logAudit({
      userId: req.user?.id || 1,
      userName: beneficiary_name || 'Beneficiary',
      userRole: 'Beneficiary',
      action: 'BOOK_CAMP_SLOT',
      targetModule: 'Health Camps',
      details: `Booked slot for ${camp.title}`
    });

    return res.status(201).json({
      success: true,
      message: 'Health Camp slot booked successfully!',
      booking
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to book camp slot' });
  }
};

// 3. Camp QR Check-in by Volunteer
exports.verifyCampQRCheckin = async (req, res) => {
  try {
    const { qr_data } = req.body;
    const booking = memoryDb.healthCampBookings.find(b => b.booking_qr === qr_data);

    if (!booking) {
      return res.status(404).json({ success: false, message: 'Invalid or unverified camp QR pass' });
    }

    booking.status = 'Attended';
    booking.attended_at = new Date();

    await logAudit({
      userId: req.user?.id || 1,
      userName: req.user?.name || 'Volunteer',
      userRole: 'Volunteer',
      action: 'QR_CAMP_CHECKIN',
      targetModule: 'Health Camps',
      details: `Checked in beneficiary ${booking.beneficiary_name} for camp #${booking.camp_id}`
    });

    return res.status(200).json({
      success: true,
      message: 'Beneficiary QR Check-in Verified!',
      booking
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'QR verification error' });
  }
};
