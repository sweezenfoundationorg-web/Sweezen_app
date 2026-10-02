const { memoryDb } = require('../config/db');

/**
 * AI-assisted Analytics Controller
 * Provides NLP Report Summaries, Anomaly Detection, and Draft Impact Reports with Human-in-the-Loop Approval.
 */

exports.getReportSummaries = (req, res) => {
  try {
    const summaries = memoryDb.aiAnalytics?.summaries || [];
    return res.status(200).json({ success: true, count: summaries.length, data: summaries });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.getDataAnomalies = (req, res) => {
  try {
    const anomalies = memoryDb.aiAnalytics?.anomalies || [];
    return res.status(200).json({
      success: true,
      flaggedCount: anomalies.filter(a => a.status.includes('Flagged')).length,
      data: anomalies
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.getDraftImpactReports = (req, res) => {
  try {
    const reports = memoryDb.aiAnalytics?.draftReports || [];
    return res.status(200).json({ success: true, count: reports.length, data: reports });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.approveDraftImpactReport = (req, res) => {
  try {
    const { reportId, approvedBy, action } = req.body; // action: 'approve' or 'reject'
    const reports = memoryDb.aiAnalytics?.draftReports || [];
    const targetReport = reports.find(r => r.id === (reportId || 'DRAFT-REP-2026-01'));

    if (!targetReport) {
      return res.status(404).json({ success: false, message: 'Draft impact report not found.' });
    }

    if (action === 'reject') {
      targetReport.status = 'Rejected / Needs Revision';
      targetReport.isHumanApproved = false;
      return res.status(200).json({ success: true, message: 'Report rejected and marked for AI revision.', data: targetReport });
    }

    targetReport.isHumanApproved = true;
    targetReport.approvedBy = approvedBy || 'Sheetal (Director & Human Reviewer)';
    targetReport.approvalDate = new Date().toISOString();
    targetReport.status = 'Approved & Published';

    return res.status(200).json({
      success: true,
      message: 'Draft impact report has been approved by human reviewer and published.',
      data: targetReport
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};
