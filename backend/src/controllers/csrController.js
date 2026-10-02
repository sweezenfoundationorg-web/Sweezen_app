const { memoryDb } = require('../config/db');

/**
 * CSR Partner Dashboard Controller
 * Handles project proposals, approved budgets, milestones, and utilization reports.
 */

exports.getCsrProposals = (req, res) => {
  try {
    const proposals = memoryDb.csrProposals || [];
    return res.status(200).json({ success: true, count: proposals.length, data: proposals });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.submitCsrProposal = (req, res) => {
  try {
    const { partnerName, projectTitle, budgetProposed } = req.body;
    if (!partnerName || !projectTitle || !budgetProposed) {
      return res.status(400).json({ success: false, message: 'Partner name, project title, and proposed budget are required.' });
    }

    const newProposal = {
      id: `CSR-2026-00${(memoryDb.csrProposals?.length || 0) + 1}`,
      partnerName,
      projectTitle,
      budgetProposed: Number(budgetProposed),
      budgetApproved: 0,
      status: 'Under Review',
      submittedDate: new Date().toISOString().split('T')[0],
      approvalDate: null,
      milestones: [
        { phase: 'Phase 1', title: 'Proposal Evaluation & Scope Alignment', status: 'In Progress', percentage: 20 },
        { phase: 'Phase 2', title: 'Implementation & Field Operations', status: 'Pending', percentage: 0 }
      ],
      utilization: [
        { category: 'Initial Setup & Logistics', allocated: Number(budgetProposed) * 0.4, spent: 0 },
        { category: 'Equipment & Field Delivery', allocated: Number(budgetProposed) * 0.6, spent: 0 }
      ]
    };

    memoryDb.csrProposals.unshift(newProposal);
    return res.status(201).json({ success: true, message: 'CSR Proposal submitted successfully.', data: newProposal });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.getCsrBudgets = (req, res) => {
  try {
    const proposals = memoryDb.csrProposals || [];
    const totalProposed = proposals.reduce((acc, p) => acc + (p.budgetProposed || 0), 0);
    const totalApproved = proposals.reduce((acc, p) => acc + (p.budgetApproved || 0), 0);
    let totalUtilized = 0;
    proposals.forEach(p => {
      p.utilization?.forEach(u => { totalUtilized += (u.spent || 0); });
    });

    return res.status(200).json({
      success: true,
      summary: {
        totalProposed,
        totalApproved,
        totalUtilized,
        balanceRemaining: totalApproved - totalUtilized,
        activePartnersCount: proposals.length
      },
      proposals
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.getCsrMilestones = (req, res) => {
  try {
    const proposals = memoryDb.csrProposals || [];
    const allMilestones = proposals.flatMap(p => 
      (p.milestones || []).map(m => ({
        proposalId: p.id,
        partnerName: p.partnerName,
        projectTitle: p.projectTitle,
        ...m
      }))
    );
    return res.status(200).json({ success: true, data: allMilestones });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};

exports.getCsrUtilizationReports = (req, res) => {
  try {
    const proposals = memoryDb.csrProposals || [];
    const reports = proposals.map(p => {
      const allocatedSum = (p.utilization || []).reduce((a, u) => a + u.allocated, 0);
      const spentSum = (p.utilization || []).reduce((a, u) => a + u.spent, 0);
      return {
        proposalId: p.id,
        partnerName: p.partnerName,
        projectTitle: p.projectTitle,
        approvedBudget: p.budgetApproved,
        allocatedSum,
        spentSum,
        burnRatePercentage: allocatedSum > 0 ? ((spentSum / allocatedSum) * 100).toFixed(1) : 0,
        breakdown: p.utilization || []
      };
    });
    return res.status(200).json({ success: true, data: reports });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
};
