const { memoryDb } = require('../config/db');

function initSeedData() {
  // 1. Projects (Exact 2 Active Programs from website)
  memoryDb.projects = [
    {
      id: 1,
      name: 'HealthCare Camp',
      category: 'Healthcare',
      description: 'Free medical checkups, primary treatment, and healthcare access for underserved communities. Aligned with UN SDG 3 (Good Health & Well-Being).',
      objectives: ['Free general medical checkups & consultations', 'Primary treatment & free medicine distribution', 'Community healthcare access & hygiene education'],
      location: 'Haridwar, Uttarakhand',
      beneficiary_count: 211,
      funding_goal: 60000,
      funding_raised: 14311,
      funding_utilized: 10000,
      status: 'Active',
      image_url: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=800&q=80',
      geo_lat: 29.9600,
      geo_lng: 78.2000,
      milestones: [
        { title: 'Foundation Incorporation', completed: true },
        { title: 'Medical Camp Setup in Haridwar', completed: true },
        { title: '211+ Patients Screened & Treated', completed: true }
      ],
      documents: [
        { name: 'Health Camp Audit 2026.pdf', size: '1.4 MB', url: '#' }
      ],
      created_at: new Date('2025-11-23')
    },
    {
      id: 2,
      name: 'Environment Cleaning Camp',
      category: 'Environment',
      description: 'Environmental sanitation, community cleaning drives, and ecological awareness around Haridwar riverbanks and public spaces. Aligned with UN SDG 13 (Climate Action).',
      objectives: ['Community sanitation & riverbank cleaning drive', 'Waste segregation & plastic recycling awareness', 'Clean public space maintenance'],
      location: 'Haridwar, Uttarakhand',
      beneficiary_count: 100,
      funding_goal: 0,
      funding_raised: 0,
      funding_utilized: 0,
      status: 'Active',
      image_url: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=800&q=80',
      geo_lat: 29.9457,
      geo_lng: 78.1642,
      milestones: [
        { title: 'Site Inspection Haridwar Riverbank', completed: true },
        { title: 'Community Cleaning Drive Initiated', completed: true }
      ],
      documents: [
        { name: 'Environment Drive Summary.pdf', size: '1.1 MB', url: '#' }
      ],
      created_at: new Date('2026-03-01')
    }
  ];

  // 2. Initial Directors, Volunteers & Donors
  memoryDb.users = [
    {
      id: 1,
      name: 'Sheetal',
      email: 'sheetal@sweezenfoundation.org',
      phone: '+91-9045652546',
      role: 'Director',
      profile_photo: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80',
      skills: ['Strategic Planning', 'Leadership', 'NGO Governance'],
      interests: ['Healthcare', 'Environment'],
      location: 'Haridwar, Uttarakhand',
      availability: 'Full-Time',
      impact_points: 1500,
      badges: ['Director', 'Founding Member'],
      humanity_card_id: 'SWZ-CARD-1001',
      created_at: new Date('2025-11-23')
    },
    {
      id: 2,
      name: 'Balistar Kashyap',
      email: 'balistar@sweezenfoundation.org',
      phone: '+91-9045652546',
      role: 'Director',
      profile_photo: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      skills: ['Operations', 'Community Outreach', 'Field Management'],
      interests: ['Healthcare', 'Environment'],
      location: 'Haridwar, Uttarakhand',
      availability: 'Full-Time',
      impact_points: 1400,
      badges: ['Director', 'Founding Member'],
      humanity_card_id: 'SWZ-CARD-1002',
      created_at: new Date('2025-11-23')
    },
    {
      id: 3,
      name: 'Fareed Khan',
      email: 'fareed@sweezenfoundation.org',
      phone: '+91-9876543210',
      role: 'Donor',
      profile_photo: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      skills: ['Philanthropy', 'Community Support'],
      interests: ['Healthcare'],
      location: 'Haridwar, Uttarakhand',
      availability: 'Patron',
      impact_points: 1420,
      badges: ['Top Donor', 'Golden Benefactor'],
      humanity_card_id: 'SWZ-CARD-1003',
      created_at: new Date('2026-01-10')
    }
  ];

  // 3. Field Tasks for Volunteers
  memoryDb.tasks = [
    {
      id: 101,
      title: 'HealthCare Camp Patient Registration & Assistance',
      description: 'Assist doctors with patient token distribution, vital recordings, and basic medicine kit dispatch at Haridwar Health Camp.',
      location: '353 Avas Vikas Colony, Haridwar',
      required_skills: ['Field Work', 'Patient Assistance', 'First Aid'],
      date_time: new Date(Date.now() + 86400000 * 2),
      assigned_user_id: 1,
      status: 'Pending',
      remarks: 'Coordinate with Camp Leader Sheetal on arrival.',
      photo_url: null,
      geo_lat: 29.9600,
      geo_lng: 78.2000,
      updated_at: new Date()
    },
    {
      id: 102,
      title: 'Haridwar Riverbank Environment Sanitation Drive',
      description: 'Lead volunteer groups in plastic waste collection, segregation, and public eco-awareness near riverbank ghats.',
      location: 'Riverbank Ghats, Haridwar',
      required_skills: ['Environment', 'Community Work'],
      date_time: new Date(Date.now() + 86400000 * 5),
      assigned_user_id: 2,
      status: 'In Progress',
      remarks: 'Safety gloves and collection bags will be provided.',
      photo_url: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=600&q=80',
      geo_lat: 29.9457,
      geo_lng: 78.1642,
      updated_at: new Date()
    }
  ];

  // 4. Events
  memoryDb.events = [
    {
      id: 201,
      title: 'Community HealthCare Camp Haridwar',
      description: 'Free medical checkup camp providing doctor consultations, free medicine distribution, and diagnostic screenings for local families.',
      category: 'Healthcare',
      date_time: new Date(Date.now() + 86400000 * 7),
      location: '353 Avas Vikas Colony, Haridwar, Uttarakhand 249401',
      capacity: 300,
      registered_count: 211,
      banner_url: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=800&q=80',
      status: 'Upcoming'
    },
    {
      id: 202,
      title: 'Swachh Haridwar Environment Drive',
      description: 'Mass public cleanliness drive, plastic waste collection, and riverbank environmental sanitation campaign.',
      category: 'Environment',
      date_time: new Date(Date.now() + 86400000 * 12),
      location: 'Ghats & Public Parks, Haridwar, Uttarakhand',
      capacity: 200,
      registered_count: 100,
      banner_url: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=800&q=80',
      status: 'Upcoming'
    }
  ];

  // 5. Humanity Cards
  memoryDb.humanityCards = [
    {
      id: 1,
      card_number: 'SWZ-CARD-1001',
      beneficiary_name: 'Sheetal',
      phone: '+91-9045652546',
      village_camp: 'Haridwar Center',
      qr_code_data: 'SWEEZEN:CARD:1001:SHEETAL',
      created_at: new Date('2025-11-23')
    },
    {
      id: 2,
      card_number: 'SWZ-CARD-1002',
      beneficiary_name: 'Balistar Kashyap',
      phone: '+91-9045652546',
      village_camp: 'Haridwar Center',
      qr_code_data: 'SWEEZEN:CARD:1002:BALISTAR_KASHYAP',
      created_at: new Date('2025-11-23')
    }
  ];

  // 6. Humanity Card Logs
  memoryDb.humanityLogs = [
    {
      id: 1,
      card_number: 'SWZ-CARD-1001',
      service_type: 'Health Checkup & Prescription',
      volunteer_id: 1,
      location: 'HealthCare Camp, Haridwar',
      geo_lat: 29.9600,
      geo_lng: 78.2000,
      notes: 'Primary consultation and free medicine distributed.',
      scanned_at: new Date(Date.now() - 3600000 * 24)
    }
  ];

  // 7. Announcements
  memoryDb.announcements = [
    {
      id: 1,
      title: 'Sweezen Foundation Incorporated as Section 8 NGO!',
      content: 'Official registration completed under CIN U88900UT2025NPL020255 & 80G tax exemption approval AAATS0123K.',
      category: 'Official',
      created_at: new Date('2025-11-23')
    },
    {
      id: 2,
      title: '211+ Lives Touched in First Haridwar HealthCare Camp!',
      content: 'Our dedicated healthcare drive successfully served 211 beneficiaries in Haridwar district.',
      category: 'Impact',
      created_at: new Date('2026-03-31')
    }
  ];

  // 8. Group Messages
  memoryDb.groupMessages = [
    { id: 1, project_id: 1, sender_id: 1, sender_name: 'Sheetal', message: 'HealthCare Camp preparations in Haridwar completed. Doctors ready!', created_at: new Date(Date.now() - 3600000 * 5) },
    { id: 2, project_id: 1, sender_id: 2, sender_name: 'Balistar Kashyap', message: 'Volunteer team assigned for patient token registration.', created_at: new Date(Date.now() - 3600000 * 2) }
  ];

  // 9. Exact Donors from Website (Wall of Honor - Total ₹14,311)
  memoryDb.donations = [
    {
      id: 1,
      transaction_id: 'TXN_SWZ_WALL_01',
      user_id: 3,
      donor_name: 'Fareed Khan',
      donor_email: 'fareed@sweezenfoundation.org',
      donor_phone: '+91-9876543210',
      project_id: 1,
      amount: 14200,
      donation_type: 'One-Time',
      payment_method: 'UPI',
      is_anonymous: false,
      is_80g_requested: true,
      pan_number: 'FKPAN1234F',
      receipt_url: '/api/donations/receipt/TXN_SWZ_WALL_01',
      status: 'Success',
      created_at: new Date('2026-03-15')
    },
    {
      id: 2,
      transaction_id: 'TXN_SWZ_WALL_02',
      user_id: 1,
      donor_name: 'SHEETAL',
      donor_email: 'sheetal@sweezenfoundation.org',
      donor_phone: '+91-9045652546',
      project_id: 1,
      amount: 100,
      donation_type: 'One-Time',
      payment_method: 'UPI',
      is_anonymous: false,
      is_80g_requested: true,
      pan_number: 'SHPAN5678S',
      receipt_url: '/api/donations/receipt/TXN_SWZ_WALL_02',
      status: 'Success',
      created_at: new Date('2026-03-18')
    },
    {
      id: 3,
      transaction_id: 'TXN_SWZ_WALL_03',
      user_id: null,
      donor_name: 'Kapil',
      donor_email: 'kapil@example.com',
      donor_phone: '+91-9988776655',
      project_id: 1,
      amount: 10,
      donation_type: 'One-Time',
      payment_method: 'UPI',
      is_anonymous: false,
      is_80g_requested: false,
      receipt_url: '/api/donations/receipt/TXN_SWZ_WALL_03',
      status: 'Success',
      created_at: new Date('2026-03-20')
    },
    {
      id: 4,
      transaction_id: 'TXN_SWZ_WALL_04',
      user_id: null,
      donor_name: 'Dev',
      donor_email: 'dev@example.com',
      donor_phone: '+91-9988776644',
      project_id: 1,
      amount: 1,
      donation_type: 'One-Time',
      payment_method: 'UPI',
      is_anonymous: false,
      is_80g_requested: false,
      receipt_url: '/api/donations/receipt/TXN_SWZ_WALL_04',
      status: 'Success',
      created_at: new Date('2026-03-21')
    }
  ];

  // 6. CSR Partner Proposals, Budgets, Milestones & Utilization Reports
  memoryDb.csrProposals = [
    {
      id: 'CSR-2026-001',
      partnerName: 'Tata Clean Earth Foundation',
      projectTitle: 'Haridwar Rural Clean Water & Health Infrastructure',
      budgetProposed: 5000000,
      budgetApproved: 4500000,
      status: 'Approved',
      submittedDate: '2026-01-15',
      approvalDate: '2026-02-01',
      milestones: [
        { phase: 'Phase 1', title: 'Water Testing & Site Setup', status: 'Completed', percentage: 100 },
        { phase: 'Phase 2', title: 'Filter Installation & Camp Deployment', status: 'In Progress', percentage: 75 },
        { phase: 'Phase 3', title: 'Impact Evaluation & Audit', status: 'Pending', percentage: 0 }
      ],
      utilization: [
        { category: 'Medical & Filtration Equipment', allocated: 2000000, spent: 1850000 },
        { category: 'Field Operations & Staffing', allocated: 1500000, spent: 1200000 },
        { category: 'Logistics & Community Outreach', allocated: 1000000, spent: 750000 }
      ]
    },
    {
      id: 'CSR-2026-002',
      partnerName: 'Infosys Foundation',
      projectTitle: 'Digital Education & Health Monitoring for Tribal Schools',
      budgetProposed: 3200000,
      budgetApproved: 3200000,
      status: 'Under Review',
      submittedDate: '2026-03-01',
      approvalDate: null,
      milestones: [
        { phase: 'Phase 1', title: 'School Onboarding & Tab Distribution', status: 'In Progress', percentage: 40 },
        { phase: 'Phase 2', title: 'Teacher Training & Health Tracker Setup', status: 'Pending', percentage: 0 }
      ],
      utilization: [
        { category: 'Hardware & Educational Tablets', allocated: 1800000, spent: 900000 },
        { category: 'Connectivity & Cloud Software', allocated: 800000, spent: 300000 },
        { category: 'Trainer Stipends', allocated: 600000, spent: 150000 }
      ]
    }
  ];

  // 7. Hospital & Education Portals (Partners, Referrals, Camps, Student Progress)
  memoryDb.portalPartners = [
    { id: 1, name: 'AIIMS Rishikesh Healthcare Wing', type: 'Hospital', location: 'Rishikesh', status: 'Verified', contactPerson: 'Dr. A. Sharma', phone: '+91-9812345678' },
    { id: 2, name: 'Doona Super Speciality Hospital', type: 'Hospital', location: 'Dehradun', status: 'Verified', contactPerson: 'Dr. R. Verma', phone: '+91-9876512345' },
    { id: 3, name: 'Sweezen Model Vidya Mandir', type: 'Education Institution', location: 'Haridwar', status: 'Verified', contactPerson: 'Mrs. S. Gupta', phone: '+91-9834567890' }
  ];

  memoryDb.portalReferrals = [
    { id: 'REF-8801', partnerName: 'AIIMS Rishikesh', type: 'Medical Surgery', patientOrStudentName: 'Ramesh Kumar (Age 9)', diagnosisOrNeed: 'Pediatric Cardiac Surgery Grant', status: 'Approved', urgency: 'High', date: '2026-03-10' },
    { id: 'REF-8802', partnerName: 'Sweezen Model Vidya Mandir', type: 'Education Scholarship', patientOrStudentName: 'Pooja Devi (Class 8)', diagnosisOrNeed: 'Higher Secondary Kit & Tuition Support', status: 'Under Review', urgency: 'Medium', date: '2026-03-18' },
    { id: 'REF-8803', partnerName: 'Doona Hospital', type: 'Eye Care & Cataract', patientOrStudentName: 'Sohan Lal (Age 64)', diagnosisOrNeed: 'Free Cataract Surgery & Glasses', status: 'Completed', urgency: 'Medium', date: '2026-03-22' }
  ];

  memoryDb.portalCamps = [
    { id: 'CAMP-101', title: 'Free Mega Eye & Health Camp', facility: 'AIIMS Rishikesh Outreach Team', location: 'Community Center, Haridwar', date: '2026-10-15', time: '09:00 AM - 04:00 PM', capacity: 300, registeredCount: 184, status: 'Upcoming' },
    { id: 'CAMP-102', title: 'Child Nutrition & Literacy Drive', facility: 'Sweezen Model Vidya Mandir', location: 'Sector 4 School Campus, Haridwar', date: '2026-10-22', time: '10:00 AM - 02:00 PM', capacity: 150, registeredCount: 112, status: 'Upcoming' }
  ];

  memoryDb.portalStudentProgress = [
    { id: 'STU-901', name: 'Aarav Sharma', grade: 'Class 7', school: 'Sweezen Model Vidya Mandir', attendance: '96%', academicScore: '88% (Grade A)', healthScore: 'Good (BMI Normal)', kitStatus: 'Distributed March 2026' },
    { id: 'STU-902', name: 'Priya Joshi', grade: 'Class 9', school: 'Haridwar Girls High School', attendance: '92%', academicScore: '91% (Grade A+)', healthScore: 'Anemia Screened - Meds Provided', kitStatus: 'Distributed Feb 2026' }
  ];

  // 8. AI-assisted Analytics (Summaries, Data Anomalies, Draft Impact Reports with Human Approval)
  memoryDb.aiAnalytics = {
    summaries: [
      { id: 1, topic: 'Q1 2026 Health Operations Summary', summaryText: 'AI analysis of 211 health camp consultations indicates a 94.2% patient satisfaction rate. Primary remedies distributed included oral rehydration, vitamins, and eye drops. Cost per beneficiary was ₹67.8, representing a 14% improvement in budget efficiency.' },
      { id: 2, topic: 'CSR Utilization ROI', summaryText: 'Total CSR fund utilization reached 78.4% across active programs. Zero unverified expenditure items were detected. Projected beneficiary reach for upcoming Q4 camps is 1,200 individuals.' }
    ],
    anomalies: [
      { id: 'ANO-101', severity: 'Medium', area: 'Budget Variance', description: 'Logistics expenses in Haridwar Environmental Camp spiked +18% above historical average.', status: 'Flagged for Review', timestamp: '2026-03-25T14:30:00Z' },
      { id: 'ANO-102', severity: 'Low', area: 'Unverified QR Scan', description: 'Duplicate Humanity Card scan detected within 30 seconds at Camp-101.', status: 'Resolved - System Auto-Deduplicated', timestamp: '2026-03-26T09:12:00Z' }
    ],
    draftReports: [
      {
        id: 'DRAFT-REP-2026-01',
        title: 'Sweezen Foundation Annual Impact & CSR Governance Report 2026',
        author: 'Ask Sweezen AI Analytics Engine v3.4',
        executiveSummary: 'This draft report evaluates 2 active programs across Haridwar and Uttarakhand, summarizing financial utilization of ₹14,311 raised, 211+ direct healthcare beneficiaries, and 100% digital 80G tax receipt compliance.',
        highlights: [
          'Direct beneficiary outreach expanded by 34% quarter-on-quarter.',
          '100% of field volunteer task reports geo-verified with real-time GPS coordinates.',
          'Zero compliance deviations across 80G tax exemption certificates.'
        ],
        isHumanApproved: false,
        approvedBy: null,
        approvalDate: null,
        status: 'Pending Human Approval'
      }
    ]
  };

  console.log('[SEED] In-memory seed data loaded with official sweezenfoundation.org website data & CSR, Portal, AI modules.');
}

module.exports = { initSeedData };
