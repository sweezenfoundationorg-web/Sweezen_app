const { memoryDb } = require('../config/db');

// Get assigned tasks for volunteer
exports.getAssignedTasks = async (req, res) => {
  try {
    const userId = req.user ? req.user.id : parseInt(req.query.userId || '1');
    const tasks = memoryDb.tasks.filter(t => t.assigned_user_id === userId || !t.assigned_user_id);

    return res.status(200).json({
      success: true,
      count: tasks.length,
      tasks
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to fetch assigned tasks' });
  }
};

// Update task status and submit field report (photo, GPS, remarks)
exports.submitFieldReport = async (req, res) => {
  try {
    const { taskId, status, remarks, photo_url, geo_lat, geo_lng, offline_timestamp } = req.body;

    const task = memoryDb.tasks.find(t => t.id === parseInt(taskId));

    if (!task) {
      return res.status(404).json({ success: false, message: 'Task not found' });
    }

    task.status = status || 'Completed';
    if (remarks) task.remarks = remarks;
    if (photo_url) task.photo_url = photo_url;
    if (geo_lat) task.geo_lat = parseFloat(geo_lat);
    if (geo_lng) task.geo_lng = parseFloat(geo_lng);
    task.updated_at = new Date();

    // Reward volunteer with impact points on task completion
    const userId = req.user ? req.user.id : task.assigned_user_id;
    const volunteer = memoryDb.users.find(u => u.id === userId);
    if (volunteer && task.status === 'Completed') {
      volunteer.impact_points = (volunteer.impact_points || 0) + 50;
      if (volunteer.impact_points >= 300 && !volunteer.badges.includes('Community Hero')) {
        volunteer.badges.push('Community Hero');
      }
    }

    return res.status(200).json({
      success: true,
      message: 'Field report submitted & synced successfully!',
      task,
      updated_points: volunteer ? volunteer.impact_points : 0
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Field report submission failed' });
  }
};

// Batch offline sync endpoint
exports.syncOfflineReports = async (req, res) => {
  try {
    const { reports } = req.body; // Array of field reports queued offline

    if (!Array.isArray(reports) || reports.length === 0) {
      return res.status(400).json({ success: false, message: 'No offline reports provided to sync' });
    }

    const syncedResults = [];
    for (const item of reports) {
      const task = memoryDb.tasks.find(t => t.id === parseInt(item.taskId));
      if (task) {
        task.status = item.status || 'Completed';
        task.remarks = item.remarks || task.remarks;
        task.photo_url = item.photo_url || task.photo_url;
        task.geo_lat = item.geo_lat || task.geo_lat;
        task.geo_lng = item.geo_lng || task.geo_lng;
        task.updated_at = new Date(item.offline_timestamp || Date.now());
        syncedResults.push({ taskId: task.id, status: 'Synced' });
      }
    }

    return res.status(200).json({
      success: true,
      message: `Successfully synced ${syncedResults.length} offline field reports!`,
      synced: syncedResults
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Offline sync failed' });
  }
};
