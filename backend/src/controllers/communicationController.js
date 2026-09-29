const { memoryDb } = require('../config/db');

exports.getAnnouncements = async (req, res) => {
  try {
    return res.status(200).json({ success: true, announcements: memoryDb.announcements });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to fetch announcements' });
  }
};

exports.getGroupMessages = async (req, res) => {
  try {
    const projectId = parseInt(req.params.projectId);
    const messages = memoryDb.groupMessages.filter(m => m.project_id === projectId);
    return res.status(200).json({ success: true, messages });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to fetch group chat messages' });
  }
};

exports.sendGroupMessage = async (req, res) => {
  try {
    const projectId = parseInt(req.params.projectId);
    const { message, sender_name } = req.body;

    if (!message) {
      return res.status(400).json({ success: false, message: 'Message content cannot be empty' });
    }

    const newMsg = {
      id: memoryDb.groupMessages.length + 1,
      project_id: projectId,
      sender_id: req.user ? req.user.id : 1,
      sender_name: sender_name || 'Volunteer Representative',
      message,
      created_at: new Date()
    };

    memoryDb.groupMessages.push(newMsg);
    return res.status(201).json({ success: true, message: newMsg });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to send group message' });
  }
};

exports.getWhatsAppLink = async (req, res) => {
  const phone = '919876543210';
  const defaultText = encodeURIComponent('Hello Sweezen Foundation! I would like to inquire about volunteering and donation programs.');
  return res.status(200).json({
    success: true,
    whatsapp_url: `https://wa.me/${phone}?text=${defaultText}`
  });
};
