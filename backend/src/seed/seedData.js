const { memoryDb } = require('../config/db');

function initSeedData() {
  // 1. Projects
  memoryDb.projects = [
    {
      id: 1,
      name: 'Mobile Health Unit - Rural Tribal Camps',
      category: 'Healthcare',
      description: 'Deploying fully equipped mobile medical clinics offering free diagnostic tests, maternal care, and life-saving pharmaceuticals in remote villages.',
      objectives: ['Conduct 50 medical camps monthly', 'Provide free health screenings to 10,000+ villagers', 'Distribute essential medical kits'],
      location: 'Ranchi & East Singhbhum, Jharkhand',
      beneficiary_count: 14200,
      funding_goal: 1500000,
      funding_raised: 1120000,
      funding_utilized: 850000,
      status: 'Active',
      image_url: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=800&q=80',
      video_url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      milestones: [
        { title: 'Clinic Setup', completed: true },
        { title: 'Doctor Recruitment', completed: true },
        { title: 'First 5,000 Consultations', completed: true },
        { title: 'Expansion to 10 Remote Villages', completed: false }
      ],
      documents: [
        { name: 'Impact Report Q3.pdf', size: '2.4 MB', url: '#' },
        { name: 'Financial Utilization.pdf', size: '1.1 MB', url: '#' }
      ],
      created_at: new Date('2025-01-15')
    },
    {
      id: 2,
      name: 'Shiksha Setu - Digital Learning Pods',
      category: 'Education',
      description: 'Setting up solar-powered digital smart classrooms equipped with tablets and interactive educational software for underprivileged children.',
      objectives: ['Establish 25 digital learning centers', 'Train 50 local educators', 'Improve literacy rate by 40%'],
      location: 'Dharavi, Mumbai & Rural Thane',
      beneficiary_count: 8500,
      funding_goal: 2000000,
      funding_raised: 1680000,
      funding_utilized: 1200000,
      status: 'Active',
      image_url: 'https://images.unsplash.com/photo-1509062522246-3755977927d7?auto=format&fit=crop&w=800&q=80',
      milestones: [
        { title: 'Tablet Procurement', completed: true },
        { title: 'Teacher Orientation', completed: true },
        { title: 'Student Enrollment (5,000)', completed: true },
        { title: 'AI-Guided Learning Modules', completed: true }
      ],
      documents: [
        { name: 'Curriculum Overview.pdf', size: '3.1 MB', url: '#' }
      ],
      created_at: new Date('2025-02-01')
    },
    {
      id: 3,
      name: 'Green Canopy - Clean River & Forest Drive',
      category: 'Environment',
      description: 'Community-led mass tree plantation drive and plastic waste recycling initiative around major river basins to combat soil erosion.',
      objectives: ['Plant 100,000 native saplings', 'Clear 20 tons of riverbank plastic', 'Empower local eco-warriors'],
      location: 'Uttarkashi & Haridwar, Uttarakhand',
      beneficiary_count: 25000,
      funding_goal: 1000000,
      funding_raised: 920000,
      funding_utilized: 740000,
      status: 'Active',
      image_url: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=800&q=80',
      milestones: [
        { title: 'Sapling Nursery Setup', completed: true },
        { title: '50,000 Saplings Planted', completed: true },
        { title: 'Plastic Bio-Recycling Unit', completed: false }
      ],
      documents: [
        { name: 'Environmental Audit 2025.pdf', size: '1.8 MB', url: '#' }
      ],
      created_at: new Date('2025-03-10')
    }
  ];

  // 2. Initial Admin & Test Users
  memoryDb.users = [
    {
      id: 1,
      name: 'Aarav Sharma',
      email: 'volunteer@sweezenfoundation.org',
      phone: '+91 9876543210',
      role: 'Volunteer',
      profile_photo: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      skills: ['Field Coordination', 'First Aid', 'Teaching', 'Hindi Translation'],
      interests: ['Healthcare', 'Education'],
      location: 'Mumbai, Maharashtra',
      availability: 'Weekends (Sat - Sun)',
      experience: '3 years in community healthcare outreach',
      documents: [{ name: 'ID_Proof_Aadhaar.pdf', status: 'Approved' }],
      impact_points: 340,
      badges: ['Community Hero', 'Top Field Agent', '100+ Hours'],
      humanity_card_id: 'SWZ-CARD-8849',
      created_at: new Date()
    },
    {
      id: 2,
      name: 'Priya Verma',
      email: 'donor@sweezenfoundation.org',
      phone: '+91 9123456789',
      role: 'Donor',
      profile_photo: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80',
      skills: ['Corporate Sponsorship', 'CSR Strategy'],
      interests: ['Healthcare', 'Environment'],
      location: 'Bengaluru, Karnataka',
      availability: 'On Call',
      impact_points: 1250,
      badges: ['Golden Benefactor', 'Patron of Hope'],
      humanity_card_id: 'SWZ-CARD-9901',
      created_at: new Date()
    }
  ];

  // 3. Initial Tasks
  memoryDb.tasks = [
    {
      id: 101,
      title: 'Distribute Health Kits in Village Camp',
      description: 'Provide hygiene kits, basic medicine packages, and nutritional supplements to families at Camp 4.',
      location: 'Camp 4, Ranchi Outskirts',
      required_skills: ['Field Work', 'First Aid'],
      date_time: new Date(Date.now() + 86400000 * 2),
      assigned_user_id: 1,
      status: 'Pending',
      remarks: 'Bring extra water bottles for volunteers.',
      photo_url: null,
      geo_lat: 23.3441,
      geo_lng: 85.3096,
      updated_at: new Date()
    },
    {
      id: 102,
      title: 'Digital Learning Assessment Drive',
      description: 'Evaluate student tablet usage and collect feedback from local teachers at Dharavi Smart Pod.',
      location: 'Dharavi Center 2, Mumbai',
      required_skills: ['Teaching', 'Data Entry'],
      date_time: new Date(Date.now() + 86400000 * 5),
      assigned_user_id: 1,
      status: 'In Progress',
      remarks: 'Forms to be filled offline if internet drops.',
      photo_url: 'https://images.unsplash.com/photo-1509062522246-3755977927d7?auto=format&fit=crop&w=600&q=80',
      geo_lat: 19.0402,
      geo_lng: 72.8508,
      updated_at: new Date()
    },
    {
      id: 103,
      title: 'Riverbank Tree Sapling Geo-tagging',
      description: 'Plant 200 saplings and capture exact GPS locations using the mobile app scanner.',
      location: 'Uttarkashi Sector 3',
      required_skills: ['Environment', 'GPS Tagging'],
      date_time: new Date(Date.now() - 86400000 * 3),
      assigned_user_id: 1,
      status: 'Completed',
      remarks: '200 saplings tagged successfully!',
      photo_url: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=600&q=80',
      geo_lat: 30.7268,
      geo_lng: 78.4354,
      updated_at: new Date()
    }
  ];

  // 4. Events
  memoryDb.events = [
    {
      id: 201,
      title: 'Annual Sweezen Impact Conclave 2026',
      description: 'Join philanthropic leaders, rural volunteers, and donors for an inspiring summit on UN SDG alignment and community empowerment.',
      category: 'Conference',
      date_time: new Date(Date.now() + 86400000 * 10),
      location: 'National Convention Center, New Delhi & Virtual',
      capacity: 500,
      registered_count: 342,
      banner_url: 'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=800&q=80',
      status: 'Upcoming'
    },
    {
      id: 202,
      title: 'Mega Health & Eye Checkup Camp',
      description: 'Free comprehensive health checkups, eye testing, and prescription spectacles for over 1,500 rural villagers.',
      category: 'Healthcare',
      date_time: new Date(Date.now() + 86400000 * 14),
      location: 'Community Center, Thane Rural',
      capacity: 300,
      registered_count: 210,
      banner_url: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=800&q=80',
      status: 'Upcoming'
    }
  ];

  // 5. Humanity Cards
  memoryDb.humanityCards = [
    {
      id: 1,
      card_number: 'SWZ-CARD-8849',
      beneficiary_name: 'Sunita Devi',
      phone: '+91 9988776655',
      village_camp: 'Camp 4, Ranchi',
      qr_code_data: 'SWEEZEN:CARD:8849:SUNITA_DEVI',
      created_at: new Date('2025-01-20')
    },
    {
      id: 2,
      card_number: 'SWZ-CARD-9901',
      beneficiary_name: 'Ramesh Kumar',
      phone: '+91 9876123456',
      village_camp: 'Village B, Thane',
      qr_code_data: 'SWEEZEN:CARD:9901:RAMESH_KUMAR',
      created_at: new Date('2025-02-10')
    }
  ];

  // 6. Humanity Card Logs
  memoryDb.humanityLogs = [
    {
      id: 1,
      card_number: 'SWZ-CARD-8849',
      service_type: 'Health Service',
      volunteer_id: 1,
      location: 'Mobile Health Unit #2, Ranchi',
      geo_lat: 23.3441,
      geo_lng: 85.3096,
      notes: 'General physician checkup and iron tablet supplement provided.',
      scanned_at: new Date(Date.now() - 3600000 * 24)
    },
    {
      id: 2,
      card_number: 'SWZ-CARD-8849',
      service_type: 'Ration & Nutrition Kit',
      volunteer_id: 1,
      location: 'Camp 4 Distribution Center',
      geo_lat: 23.3441,
      geo_lng: 85.3096,
      notes: 'Monthly grains and nutrition kit delivered.',
      scanned_at: new Date(Date.now() - 3600000 * 5)
    }
  ];

  // 7. Announcements
  memoryDb.announcements = [
    {
      id: 1,
      title: 'Sweezen Foundation receives UN SDG Special Recognition!',
      content: 'We are proud to announce our recognition for excellence in rural health outreach and digital literacy integration.',
      category: 'Achievement',
      created_at: new Date(Date.now() - 86400000 * 2)
    },
    {
      id: 2,
      title: 'Urgent Monsoon Relief Drive launched in Jharkhand',
      content: 'Field volunteers are requested to mobilize flood emergency shelters and medical kits in affected districts.',
      category: 'Urgent',
      created_at: new Date(Date.now() - 86400000 * 5)
    }
  ];

  // 8. Initial Group Messages
  memoryDb.groupMessages = [
    { id: 1, project_id: 1, sender_id: 1, sender_name: 'Aarav Sharma', message: 'Mobile clinic vehicle arrives at Camp 4 tomorrow at 9 AM!', created_at: new Date(Date.now() - 3600000 * 2) },
    { id: 2, project_id: 1, sender_id: 2, sender_name: 'Priya Verma', message: 'Funded 500 additional health kits for this drive!', created_at: new Date(Date.now() - 3600000) }
  ];

  // 9. Sample Donations
  memoryDb.donations = [
    {
      id: 1,
      transaction_id: 'TXN_SWZ_98231',
      user_id: 2,
      donor_name: 'Priya Verma',
      donor_email: 'donor@sweezenfoundation.org',
      donor_phone: '+91 9123456789',
      project_id: 1,
      amount: 5000,
      donation_type: 'One-Time',
      payment_method: 'UPI (Razorpay)',
      is_anonymous: false,
      is_80g_requested: true,
      pan_number: 'ABCDE1234F',
      receipt_url: '/api/donations/receipt/TXN_SWZ_98231',
      status: 'Success',
      created_at: new Date(Date.now() - 86400000 * 3)
    },
    {
      id: 2,
      transaction_id: 'TXN_SWZ_98232',
      user_id: 1,
      donor_name: 'Anonymous Donor',
      donor_email: 'anon@example.com',
      donor_phone: '+91 9990001112',
      project_id: 2,
      amount: 2500,
      donation_type: 'One-Time',
      payment_method: 'Card',
      is_anonymous: true,
      is_80g_requested: false,
      receipt_url: '/api/donations/receipt/TXN_SWZ_98232',
      status: 'Success',
      created_at: new Date(Date.now() - 86400000 * 7)
    }
  ];

  console.log('[SEED] In-memory seed data loaded successfully.');
}

module.exports = { initSeedData };
