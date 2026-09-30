const { memoryDb } = require('../config/db');

if (!memoryDb.documents) {
  memoryDb.documents = [
    {
      id: 'DOC-80G-99201',
      title: '80G Tax Exemption Receipt (₹5,000)',
      category: 'Tax Receipt',
      file_url: 'http://localhost:5000/api/donations/receipt/SWZ-TXN-80G-DEMO',
      created_at: new Date('2026-08-15'),
      file_size: '145 KB',
      status: 'Verified'
    },
    {
      id: 'DOC-CERT-10293',
      title: 'Volunteering Achievement Certificate (100+ Hours)',
      category: 'Certificate',
      file_url: 'http://localhost:5000/api/events/certificates',
      created_at: new Date('2026-09-01'),
      file_size: '320 KB',
      status: 'Issued'
    },
    {
      id: 'DOC-AUDIT-2026-Q3',
      title: 'Audited Financial & Utilization Report Q3 2026',
      category: 'Audit Report',
      file_url: 'http://localhost:5000/public/reports/sweezen_q3_financial_audit.pdf',
      created_at: new Date('2026-09-15'),
      file_size: '2.4 MB',
      status: 'Audited & Published'
    }
  ];
}

exports.getUserDocuments = async (req, res) => {
  try {
    const { category } = req.query;
    let docs = memoryDb.documents;

    if (category && category !== 'All') {
      docs = docs.filter(d => d.category.toLowerCase() === category.toLowerCase());
    }

    return res.status(200).json({
      success: true,
      categories: ['Tax Receipt', 'Certificate', 'Audit Report', 'Identity Proof'],
      count: docs.length,
      documents: docs
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to fetch user documents' });
  }
};
