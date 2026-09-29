const { getCollection, memoryDb } = require('../config/db');

exports.getProjects = async (req, res) => {
  try {
    const { category, search } = req.query;
    const projCol = getCollection('projects');
    let list = [];

    if (projCol) {
      const filter = {};
      if (category && category !== 'All') {
        filter.category = { $regex: new RegExp(`^${category}$`, 'i') };
      }
      if (search) {
        filter.$or = [
          { title: { $regex: search, $options: 'i' } },
          { name: { $regex: search, $options: 'i' } },
          { description: { $regex: search, $options: 'i' } },
          { location: { $regex: search, $options: 'i' } }
        ];
      }
      list = await projCol.find(filter).toArray();
    }

    if (!list || list.length === 0) {
      list = [...memoryDb.projects];
      if (category && category !== 'All') {
        list = list.filter(p => (p.category || '').toLowerCase() === category.toLowerCase());
      }
      if (search) {
        const q = search.toLowerCase();
        list = list.filter(p => (p.name || p.title || '').toLowerCase().includes(q) || (p.description || '').toLowerCase().includes(q));
      }
    }

    // Standardize object fields for compatibility
    const formattedList = list.map((p, idx) => ({
      id: p.id || p._id || (idx + 1),
      name: p.title || p.name || 'Sweezen Community Project',
      title: p.title || p.name || 'Sweezen Community Project',
      category: p.category || 'General',
      description: p.description || '',
      objectives: p.objectives || [],
      location: p.location || 'Haridwar, Uttarakhand',
      beneficiary_count: p.beneficiary_count || p.beneficiaryCount || 100,
      funding_goal: p.budget || p.funding_goal || p.fundingGoal || 100000,
      funding_raised: p.raised || p.funding_raised || p.fundingRaised || 0,
      funding_utilized: p.funding_utilized || p.fundingUtilized || 0,
      status: p.status || 'Active',
      image_url: p.image_url || p.imageUrl || 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=800&q=80',
      milestones: p.milestones || []
    }));

    return res.status(200).json({
      success: true,
      count: formattedList.length,
      projects: formattedList
    });
  } catch (err) {
    console.error('getProjects error:', err);
    return res.status(500).json({ success: false, message: 'Failed to fetch projects' });
  }
};

exports.getProjectById = async (req, res) => {
  try {
    const paramId = req.params.id;
    const projCol = getCollection('projects');
    let project = null;

    if (projCol) {
      project = await projCol.findOne({
        $or: [
          { id: paramId },
          { id: parseInt(paramId) || -1 },
          { _id: paramId }
        ]
      });
    }

    if (!project) {
      project = memoryDb.projects.find(p => p.id == paramId);
    }

    if (!project) {
      return res.status(404).json({ success: false, message: 'Project not found' });
    }

    const formattedProject = {
      id: project.id || project._id,
      name: project.title || project.name,
      title: project.title || project.name,
      category: project.category || 'General',
      description: project.description || '',
      objectives: project.objectives || [],
      location: project.location || 'India',
      beneficiary_count: project.beneficiary_count || 100,
      funding_goal: project.budget || project.funding_goal || 100000,
      funding_raised: project.raised || project.funding_raised || 0,
      funding_utilized: project.funding_utilized || 0,
      status: project.status || 'Active',
      image_url: project.image_url || 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=800&q=80',
      milestones: project.milestones || []
    };

    return res.status(200).json({
      success: true,
      project: formattedProject
    });
  } catch (err) {
    console.error('getProjectById error:', err);
    return res.status(500).json({ success: false, message: 'Failed to fetch project detail' });
  }
};

exports.createProject = async (req, res) => {
  try {
    const { title, name, category, description, objectives, location, budget, funding_goal, image_url } = req.body;
    const projCol = getCollection('projects');

    const newProject = {
      id: `SWZ-PRJ-${Date.now()}`,
      title: title || name,
      name: title || name,
      category: category || 'Healthcare',
      description,
      objectives: objectives || [],
      location: location || 'India',
      beneficiary_count: 0,
      budget: parseFloat(budget || funding_goal || 100000),
      funding_goal: parseFloat(budget || funding_goal || 100000),
      raised: 0,
      funding_raised: 0,
      funding_utilized: 0,
      status: 'Active',
      image_url: image_url || 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=800&q=80',
      milestones: [],
      created_at: new Date()
    };

    if (projCol) {
      await projCol.insertOne(newProject);
    }
    memoryDb.projects.push(newProject);

    return res.status(201).json({ success: true, message: 'Project created successfully', project: newProject });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to create project' });
  }
};
