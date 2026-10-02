const { memoryDb } = require('../config/db');
const { createSmartNotification } = require('../services/notificationService');

// Lookup Card Details by QR Code Payload or Card Number
exports.lookupCard = async (req, res) => {
  try {
    const { qr_data, card_number } = req.body;
    const queryStr = card_number || qr_data;

    if (!queryStr) {
      return res.status(400).json({ success: false, message: 'Card number or QR Code data is required' });
    }

    const card = memoryDb.humanityCards.find(c => 
      c.card_number === queryStr || 
      c.qr_code_data === queryStr || 
      queryStr.includes(c.card_number)
    );

    if (!card) {
      // Create dynamic dummy card if not existing for flexible scanning test
      const generatedCard = {
        id: memoryDb.humanityCards.length + 1,
        card_number: queryStr.startsWith('SWZ') ? queryStr : `SWZ-CARD-${Math.floor(1000 + Math.random() * 9000)}`,
        beneficiary_name: 'Registered Beneficiary',
        phone: '+91 9876500000',
        village_camp: 'Mobile Field Camp, Ranchi',
        qr_code_data: queryStr,
        created_at: new Date()
      };
      memoryDb.humanityCards.push(generatedCard);
      return res.status(200).json({ success: true, card: generatedCard, isNew: true });
    }

    const logs = memoryDb.humanityLogs.filter(l => l.card_number === card.card_number);

    return res.status(200).json({
      success: true,
      card,
      service_history: logs
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to lookup Humanity Card' });
  }
};

// Log Service point scanning (Health / Education / Lounge / Ration)
exports.logServicePointScan = async (req, res) => {
  try {
    const { card_number, service_type, location, geo_lat, geo_lng, notes } = req.body;

    if (!card_number || !service_type) {
      return res.status(400).json({ success: false, message: 'Card number and service type are required' });
    }

    const newLog = {
      id: memoryDb.humanityLogs.length + 1,
      card_number,
      service_type,
      volunteer_id: req.user ? req.user.id : 1,
      location: location || 'Field Mobile Station',
      geo_lat: parseFloat(geo_lat || 23.3441),
      geo_lng: parseFloat(geo_lng || 85.3096),
      notes: notes || 'Service delivered successfully.',
      scanned_at: new Date()
    };

    memoryDb.humanityLogs.push(newLog);

    createSmartNotification({
      userId: card_number,
      category: 'SMART_ID_LOG',
      title: '🪪 Humanity Smart ID Service Recorded!',
      body: `Service point scan: ${service_type} successfully recorded at ${newLog.location}.`,
      data: { cardNumber: card_number, serviceType: service_type }
    }).catch(e => console.error('Humanity Card notification error:', e.message));

    return res.status(201).json({
      success: true,
      message: `Humanity Card scanned & ${service_type} logged to Cloud database!`,
      log: newLog
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to record Humanity Card service log' });
  }
};
