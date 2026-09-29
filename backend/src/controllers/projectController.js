const { memoryDb } = require('../config/db');

exports.getProjects = async (req, res) => {
  try {
    const { category, search } = req.query;
    let list = [...memoryDb.projects];

    if (category && category !== 'All') {
      list = list.filter(p => p.category.toLowerCase() === category.toLowerCase());
    }

    if (search) {
      const q = search.toLowerCase();
      list = list.filter(p => p.name.toLowerCase().includes(q) || p.description.toLowerCase().includes(q) || p.location.toLowerCase().includes(q));
    }

    return res.status(200).json({
      success: true,
      count: list.length,
      projects: list
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to fetch projects' });
  }
};

exports.getProjectById = async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const project = memoryDb.projects.find(p => p.id === id);

    if (!project) {
      return res.status(404).json({ success: false, message: 'Project not found' });
    }

    // Include recent group messages and stats
    const projectMessages = memoryDb.groupMessages.filter(m => m.project_id === id);
    const projectDonations = memoryDb.donations.filter(d => d.project_id === id);

    return res.status(200).json({
      success: true,
      project: {
        ...project,
        group_messages: projectMessages,
        donations_count: projectDonations.length
      }
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to fetch project detail' });
  }
};

exports.createProject = async (req, res) => {
  try {
    const { name, category, description, objectives, location, funding_goal, image_url } = req.body;

    const newProject = {
      id: memoryDb.projects.length + 1,
      name,
      category: category || 'Healthcare',
      description,
      objectives: objectives || [],
      location: location || 'India',
      beneficiary_count: 0,
      funding_goal: parseFloat(funding_goal || 100000),
      funding_raised: 0,
      funding_utilized: 0,
      status: 'Active',
      image_url: image_url || 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=800&q=80',
      milestones: [],
      documents: [],
      created_at: new Date()
    };

    memoryDb.projects.push(newProject);
    return res.status(201).json({ success: true, message: 'Project created successfully', project: newProject });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to create project' });
  }
};
