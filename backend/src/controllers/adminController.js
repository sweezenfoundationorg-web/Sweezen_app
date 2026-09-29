const { memoryDb } = require('../config/db');
const { sendPushToTopic, sendPushToDevice } = require('../services/notificationService');

// Get Dashboard Stats
exports.getAdminDashboardStats = async (req, res) => {
  try {
    const totalProjects = memoryDb.projects.length;
    const totalFundsRaised = memoryDb.donations.reduce((sum, d) => sum + (d.amount || 0), 0);
    const totalBeneficiaries = memoryDb.projects.reduce((sum, p) => sum + (p.beneficiary_count || 0), 0);
    const totalVolunteers = memoryDb.users.filter(u => u.role === 'Volunteer').length;
    const pendingTasks = memoryDb.tasks.filter(t => t.status === 'Pending').length;

    return res.status(200).json({
      success: true,
      stats: {
        totalProjects,
        totalFundsRaised,
        totalBeneficiaries,
        totalVolunteers,
        pendingTasks,
        totalDonationsCount: memoryDb.donations.length,
        humanityCardsIssued: memoryDb.humanityCards.length,
        servicesLoggedCount: memoryDb.humanityLogs.length,
        totalEventsCount: memoryDb.events.length
      }
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to fetch admin stats' });
  }
};

// ==========================================
// 1. PROJECTS / DONATION CAMPAIGNS CRUD
// ==========================================

exports.createProject = async (req, res) => {
  try {
    const { name, category, description, objectives, location, funding_goal, funding_raised, image_url, beneficiary_count } = req.body;

    if (!name || !description) {
      return res.status(400).json({ success: false, message: 'Project title and description are required' });
    }

    const newProject = {
      id: memoryDb.projects.length ? Math.max(...memoryDb.projects.map(p => p.id)) + 1 : 1,
      name,
      category: category || 'Healthcare',
      description,
      objectives: Array.isArray(objectives) ? objectives : (objectives ? objectives.split(',').map(s => s.trim()) : []),
      location: location || 'India',
      beneficiary_count: parseInt(beneficiary_count || '1000'),
      funding_goal: parseFloat(funding_goal || '500000'),
      funding_raised: parseFloat(funding_raised || '0'),
      funding_utilized: 0,
      status: 'Active',
      image_url: image_url || 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=800&q=80',
      milestones: [],
      documents: [],
      created_at: new Date()
    };

    memoryDb.projects.push(newProject);

    return res.status(201).json({
      success: true,
      message: 'Donation Campaign/Project created successfully',
      project: newProject
    });
  } catch (err) {
    console.error('Create project error:', err);
    return res.status(500).json({ success: false, message: 'Failed to create project' });
  }
};

exports.updateProject = async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const index = memoryDb.projects.findIndex(p => p.id === id);

    if (index === -1) {
      return res.status(404).json({ success: false, message: 'Project not found' });
    }

    const current = memoryDb.projects[index];
    const { name, category, description, objectives, location, funding_goal, funding_raised, funding_utilized, status, image_url, beneficiary_count } = req.body;

    memoryDb.projects[index] = {
      ...current,
      name: name !== undefined ? name : current.name,
      category: category !== undefined ? category : current.category,
      description: description !== undefined ? description : current.description,
      objectives: objectives !== undefined ? (Array.isArray(objectives) ? objectives : objectives.split(',')) : current.objectives,
      location: location !== undefined ? location : current.location,
      funding_goal: funding_goal !== undefined ? parseFloat(funding_goal) : current.funding_goal,
      funding_raised: funding_raised !== undefined ? parseFloat(funding_raised) : current.funding_raised,
      funding_utilized: funding_utilized !== undefined ? parseFloat(funding_utilized) : current.funding_utilized,
      status: status !== undefined ? status : current.status,
      image_url: image_url !== undefined ? image_url : current.image_url,
      beneficiary_count: beneficiary_count !== undefined ? parseInt(beneficiary_count) : current.beneficiary_count,
    };

    return res.status(200).json({
      success: true,
      message: 'Project updated successfully',
      project: memoryDb.projects[index]
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to update project' });
  }
};

exports.deleteProject = async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const index = memoryDb.projects.findIndex(p => p.id === id);

    if (index === -1) {
      return res.status(404).json({ success: false, message: 'Project not found' });
    }

    memoryDb.projects.splice(index, 1);
    return res.status(200).json({ success: true, message: 'Project deleted successfully' });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to delete project' });
  }
};

// ==========================================
// 2. EVENTS CRUD
// ==========================================

exports.createEvent = async (req, res) => {
  try {
    const { title, category, description, location, capacity, banner_url, status, date_time } = req.body;

    if (!title || !description) {
      return res.status(400).json({ success: false, message: 'Event title and description are required' });
    }

    const newEvent = {
      id: memoryDb.events.length ? Math.max(...memoryDb.events.map(e => e.id)) + 1 : 201,
      title,
      category: category || 'Healthcare',
      description,
      location: location || 'Community Hall',
      capacity: parseInt(capacity || '200'),
      registered_count: 0,
      banner_url: banner_url || 'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=800&q=80',
      status: status || 'Upcoming',
      date_time: date_time ? new Date(date_time) : new Date(Date.now() + 86400000 * 7)
    };

    memoryDb.events.push(newEvent);

    return res.status(201).json({
      success: true,
      message: 'Event created successfully',
      event: newEvent
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to create event' });
  }
};

exports.updateEvent = async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const index = memoryDb.events.findIndex(e => e.id === id);

    if (index === -1) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    Object.assign(memoryDb.events[index], req.body);
    return res.status(200).json({
      success: true,
      message: 'Event updated successfully',
      event: memoryDb.events[index]
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to update event' });
  }
};

exports.deleteEvent = async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const index = memoryDb.events.findIndex(e => e.id === id);

    if (index === -1) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    memoryDb.events.splice(index, 1);
    return res.status(200).json({ success: true, message: 'Event deleted successfully' });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to delete event' });
  }
};

// ==========================================
// 3. DONATIONS & TRANSACTIONS LOG
// ==========================================

exports.getAllDonations = async (req, res) => {
  try {
    const list = memoryDb.donations.map(d => {
      const project = memoryDb.projects.find(p => p.id === d.project_id);
      return {
        ...d,
        project_name: project ? project.name : 'General Foundation Fund'
      };
    });

    return res.status(200).json({
      success: true,
      count: list.length,
      donations: list
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to fetch donations log' });
  }
};

exports.deleteDonation = async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const index = memoryDb.donations.findIndex(d => d.id === id);

    if (index === -1) {
      return res.status(404).json({ success: false, message: 'Donation record not found' });
    }

    memoryDb.donations.splice(index, 1);
    return res.status(200).json({ success: true, message: 'Donation record deleted' });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to delete donation' });
  }
};

// ==========================================
// 4. VOLUNTEER TASKS MANAGEMENT
// ==========================================

exports.getAllTasks = async (req, res) => {
  try {
    return res.status(200).json({
      success: true,
      count: memoryDb.tasks.length,
      tasks: memoryDb.tasks
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to fetch tasks' });
  }
};

exports.assignTaskToVolunteer = async (req, res) => {
  try {
    const { title, description, location, required_skills, assigned_user_id, date_time } = req.body;

    const newTask = {
      id: memoryDb.tasks.length ? Math.max(...memoryDb.tasks.map(t => t.id)) + 1 : 101,
      title,
      description,
      location: location || 'Field Site',
      required_skills: Array.isArray(required_skills) ? required_skills : (required_skills ? required_skills.split(',') : ['Field Work']),
      date_time: date_time ? new Date(date_time) : new Date(Date.now() + 86400000),
      assigned_user_id: parseInt(assigned_user_id || '1'),
      status: 'Pending',
      remarks: '',
      photo_url: null,
      geo_lat: null,
      geo_lng: null,
      updated_at: new Date()
    };

    memoryDb.tasks.push(newTask);

    // Trigger FCM Push Notification
    await sendPushToTopic('all_volunteers', {
      title: '📋 New Field Task Assigned!',
      body: `You have been assigned: ${title} at ${newTask.location}`,
      data: { taskId: String(newTask.id), type: 'TASK_ASSIGNED' }
    });

    return res.status(201).json({ success: true, message: 'Task assigned successfully & push notification sent!', task: newTask });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to assign task' });
  }
};

exports.deleteTask = async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const index = memoryDb.tasks.findIndex(t => t.id === id);

    if (index === -1) {
      return res.status(404).json({ success: false, message: 'Task not found' });
    }

    memoryDb.tasks.splice(index, 1);
    return res.status(200).json({ success: true, message: 'Task deleted' });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to delete task' });
  }
};

// ==========================================
// 5. PUSH NOTIFICATIONS
// ==========================================

exports.sendPushNotification = async (req, res) => {
  try {
    const { title, body, topic, deviceToken } = req.body;

    let result;
    if (deviceToken) {
      result = await sendPushToDevice(deviceToken, { title, body });
    } else {
      result = await sendPushToTopic(topic || 'all_users', { title, body });
    }

    return res.status(200).json({
      success: true,
      message: `Push notification broadcast dispatched via Firebase Cloud Messaging!`,
      result
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Push notification error' });
  }
};
