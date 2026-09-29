const { memoryDb } = require('../config/db');

exports.getEvents = async (req, res) => {
  try {
    const { category, search } = req.query;
    let list = [...memoryDb.events];

    if (category && category !== 'All') {
      list = list.filter(e => e.category.toLowerCase() === category.toLowerCase());
    }

    if (search) {
      const q = search.toLowerCase();
      list = list.filter(e => e.title.toLowerCase().includes(q) || e.description.toLowerCase().includes(q) || e.location.toLowerCase().includes(q));
    }

    return res.status(200).json({ success: true, count: list.length, events: list });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to fetch events' });
  }
};

exports.registerForEvent = async (req, res) => {
  try {
    const eventId = parseInt(req.body.eventId);
    const userId = req.user ? req.user.id : parseInt(req.body.userId || '1');

    const event = memoryDb.events.find(e => e.id === eventId);
    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    const existingReg = memoryDb.registrations.find(r => r.event_id === eventId && r.user_id === userId);
    if (existingReg) {
      return res.status(400).json({ success: false, message: 'Already registered for this event' });
    }

    const reg = {
      id: memoryDb.registrations.length + 1,
      event_id: eventId,
      user_id: userId,
      registered_at: new Date(),
      certificate_issued: true // Issue digital participation certificate automatically on registration/completion
    };

    memoryDb.registrations.push(reg);
    event.registered_count += 1;

    return res.status(200).json({
      success: true,
      message: 'Successfully registered for event! Certificate generated.',
      registration: reg,
      event
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Event registration failed' });
  }
};

exports.cancelRegistration = async (req, res) => {
  try {
    const eventId = parseInt(req.body.eventId);
    const userId = req.user ? req.user.id : parseInt(req.body.userId || '1');

    const idx = memoryDb.registrations.findIndex(r => r.event_id === eventId && r.user_id === userId);
    if (idx >= 0) {
      memoryDb.registrations.splice(idx, 1);
      const event = memoryDb.events.find(e => e.id === eventId);
      if (event && event.registered_count > 0) event.registered_count -= 1;
    }

    return res.status(200).json({ success: true, message: 'Event registration cancelled' });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to cancel registration' });
  }
};

exports.getUserCertificates = async (req, res) => {
  try {
    const userId = req.user ? req.user.id : parseInt(req.query.userId || '1');
    const userRegs = memoryDb.registrations.filter(r => r.user_id === userId);

    const certificates = userRegs.map(r => {
      const event = memoryDb.events.find(e => e.id === r.event_id);
      return {
        certificate_id: `CERT-SWZ-${r.id * 1042}`,
        event_title: event ? event.title : 'Sweezen Community Leadership Drive',
        event_category: event ? event.category : 'Outreach',
        issue_date: r.registered_at,
        recipient_name: 'Aarav Sharma',
        issuer: 'Sweezen Foundation Board',
        download_url: `/api/events/certificate/${r.id}`
      };
    });

    // Add default welcome volunteer certificate if none
    if (certificates.length === 0) {
      certificates.push({
        certificate_id: 'CERT-SWZ-8801',
        event_title: 'Sweezen Volunteer Orientation & Ethical Leadership',
        event_category: 'Training',
        issue_date: new Date('2025-01-15'),
        recipient_name: 'Aarav Sharma',
        issuer: 'Sweezen Foundation Executive Committee',
        download_url: '/api/events/certificate/default'
      });
    }

    return res.status(200).json({ success: true, certificates });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to fetch certificates' });
  }
};
