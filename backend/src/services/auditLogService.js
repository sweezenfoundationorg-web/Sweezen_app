const { getCollection, memoryDb } = require('../config/db');

exports.logAudit = async ({ userId, userName, userRole, action, targetModule, details, ipAddress }) => {
  try {
    const auditEntry = {
      id: `LOG-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
      user_id: userId || null,
      user_name: userName || 'System Admin',
      user_role: userRole || 'Super Admin',
      action,
      target_module: targetModule,
      details: typeof details === 'object' ? JSON.stringify(details) : details,
      ip_address: ipAddress || '127.0.0.1',
      created_at: new Date()
    };

    const auditCol = getCollection('audit_logs');
    if (auditCol) {
      await auditCol.insertOne(auditEntry);
    }
    if (!memoryDb.auditLogs) {
      memoryDb.auditLogs = [];
    }
    memoryDb.auditLogs.unshift(auditEntry);
    console.log(`[AUDIT LOG] ${action} on ${targetModule} by ${userName || 'System'}`);
    return auditEntry;
  } catch (err) {
    console.error('Audit log error:', err);
  }
};
