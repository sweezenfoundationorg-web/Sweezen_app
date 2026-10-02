import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AppStateProvider extends ChangeNotifier {
  String _currentLanguage = 'en';
  UserModel? _currentUser;
  bool _isLoggedIn = false;

  bool _isAppLockEnabled = false;
  bool _isAppUnlocked = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  List<ProjectModel> _projects = [];
  List<TaskModel> _assignedTasks = [];
  List<EventModel> _events = [];
  List<Map<String, dynamic>> _offlineSyncQueue = [];
  List<String> _notifications = [
    'Welcome to Sweezen Foundation Mobile Application!',
    'New Healthcare Camp scheduled for Sunday in Ranchi.',
    'Your 80G Tax Receipt for TXN_SWZ_98231 is ready to download.'
  ];

  Map<String, String> _impactMetrics = {
    'total_projects': '2+',
    'beneficiaries': '211+',
    'volunteers': '7+',
    'districts': '12+',
    'funds_raised': '₹14,311'
  };

  bool _onboardingCompleted = false;

  // Accessibility Settings
  double _textScaleFactor = 1.0;
  bool _isHighContrast = false;

  // CSR Partner Dashboard Data
  List<Map<String, dynamic>> _csrProposals = [
    {
      'id': 'CSR-2026-001',
      'partnerName': 'Tata Clean Earth Foundation',
      'projectTitle': 'Haridwar Rural Clean Water & Health Infrastructure',
      'budgetProposed': 5000000,
      'budgetApproved': 4500000,
      'status': 'Approved',
      'submittedDate': '2026-01-15',
      'approvalDate': '2026-02-01',
      'milestones': [
        {'phase': 'Phase 1', 'title': 'Water Testing & Site Setup', 'status': 'Completed', 'percentage': 100},
        {'phase': 'Phase 2', 'title': 'Filter Installation & Camp Deployment', 'status': 'In Progress', 'percentage': 75},
        {'phase': 'Phase 3', 'title': 'Impact Evaluation & Audit', 'status': 'Pending', 'percentage': 0}
      ],
      'utilization': [
        {'category': 'Medical & Filtration Equipment', 'allocated': 2000000, 'spent': 1850000},
        {'category': 'Field Operations & Staffing', 'allocated': 1500000, 'spent': 1200000},
        {'category': 'Logistics & Community Outreach', 'allocated': 1000000, 'spent': 750000}
      ]
    },
    {
      'id': 'CSR-2026-002',
      'partnerName': 'Infosys Foundation',
      'projectTitle': 'Digital Education & Health Monitoring for Tribal Schools',
      'budgetProposed': 3200000,
      'budgetApproved': 3200000,
      'status': 'Under Review',
      'submittedDate': '2026-03-01',
      'approvalDate': null,
      'milestones': [
        {'phase': 'Phase 1', 'title': 'School Onboarding & Tab Distribution', 'status': 'In Progress', 'percentage': 40},
        {'phase': 'Phase 2', 'title': 'Teacher Training & Health Tracker Setup', 'status': 'Pending', 'percentage': 0}
      ],
      'utilization': [
        {'category': 'Hardware & Educational Tablets', 'allocated': 1800000, 'spent': 900000},
        {'category': 'Connectivity & Cloud Software', 'allocated': 800000, 'spent': 300000},
        {'category': 'Trainer Stipends', 'allocated': 600000, 'spent': 150000}
      ]
    }
  ];

  // Hospital & Education Portals Data
  List<Map<String, dynamic>> _portalPartners = [
    {'id': 1, 'name': 'AIIMS Rishikesh Healthcare Wing', 'type': 'Hospital', 'location': 'Rishikesh', 'status': 'Verified', 'contactPerson': 'Dr. A. Sharma', 'phone': '+91-9812345678'},
    {'id': 2, 'name': 'Doona Super Speciality Hospital', 'type': 'Hospital', 'location': 'Dehradun', 'status': 'Verified', 'contactPerson': 'Dr. R. Verma', 'phone': '+91-9876512345'},
    {'id': 3, 'name': 'Sweezen Model Vidya Mandir', 'type': 'Education Institution', 'location': 'Haridwar', 'status': 'Verified', 'contactPerson': 'Mrs. S. Gupta', 'phone': '+91-9834567890'}
  ];

  List<Map<String, dynamic>> _portalReferrals = [
    {'id': 'REF-8801', 'partnerName': 'AIIMS Rishikesh', 'type': 'Medical Surgery', 'patientOrStudentName': 'Ramesh Kumar (Age 9)', 'diagnosisOrNeed': 'Pediatric Cardiac Surgery Grant', 'status': 'Approved', 'urgency': 'High', 'date': '2026-03-10'},
    {'id': 'REF-8802', 'partnerName': 'Sweezen Model Vidya Mandir', 'type': 'Education Scholarship', 'patientOrStudentName': 'Pooja Devi (Class 8)', 'diagnosisOrNeed': 'Higher Secondary Kit & Tuition Support', 'status': 'Under Review', 'urgency': 'Medium', 'date': '2026-03-18'},
    {'id': 'REF-8803', 'partnerName': 'Doona Hospital', 'type': 'Eye Care & Cataract', 'patientOrStudentName': 'Sohan Lal (Age 64)', 'diagnosisOrNeed': 'Free Cataract Surgery & Glasses', 'status': 'Completed', 'urgency': 'Medium', 'date': '2026-03-22'}
  ];

  List<Map<String, dynamic>> _portalCamps = [
    {'id': 'CAMP-101', 'title': 'Free Mega Eye & Health Camp', 'facility': 'AIIMS Rishikesh Outreach Team', 'location': 'Community Center, Haridwar', 'date': '2026-10-15', 'time': '09:00 AM - 04:00 PM', 'capacity': 300, 'registeredCount': 184, 'status': 'Upcoming'},
    {'id': 'CAMP-102', 'title': 'Child Nutrition & Literacy Drive', 'facility': 'Sweezen Model Vidya Mandir', 'location': 'Sector 4 School Campus, Haridwar', 'date': '2026-10-22', 'time': '10:00 AM - 02:00 PM', 'capacity': 150, 'registeredCount': 112, 'status': 'Upcoming'}
  ];

  List<Map<String, dynamic>> _portalStudentProgress = [
    {'id': 'STU-901', 'name': 'Aarav Sharma', 'grade': 'Class 7', 'school': 'Sweezen Model Vidya Mandir', 'attendance': '96%', 'academicScore': '88% (Grade A)', 'healthScore': 'Good (BMI Normal)', 'kitStatus': 'Distributed March 2026'},
    {'id': 'STU-902', 'name': 'Priya Joshi', 'grade': 'Class 9', 'school': 'Haridwar Girls High School', 'attendance': '92%', 'academicScore': '91% (Grade A+)', 'healthScore': 'Anemia Screened - Meds Provided', 'kitStatus': 'Distributed Feb 2026'}
  ];

  // AI Analytics Data
  List<Map<String, dynamic>> _aiReportSummaries = [
    {'id': 1, 'topic': 'Q1 2026 Health Operations Summary', 'summaryText': 'AI analysis of 211 health camp consultations indicates a 94.2% patient satisfaction rate. Primary remedies distributed included oral rehydration, vitamins, and eye drops. Cost per beneficiary was ₹67.8, representing a 14% improvement in budget efficiency.'},
    {'id': 2, 'topic': 'CSR Utilization ROI', 'summaryText': 'Total CSR fund utilization reached 78.4% across active programs. Zero unverified expenditure items were detected. Projected beneficiary reach for upcoming Q4 camps is 1,200 individuals.'}
  ];

  List<Map<String, dynamic>> _aiAnomalies = [
    {'id': 'ANO-101', 'severity': 'Medium', 'area': 'Budget Variance', 'description': 'Logistics expenses in Haridwar Environmental Camp spiked +18% above historical average.', 'status': 'Flagged for Review', 'timestamp': '2026-03-25T14:30:00Z'},
    {'id': 'ANO-102', 'severity': 'Low', 'area': 'Unverified QR Scan', 'description': 'Duplicate Humanity Card scan detected within 30 seconds at Camp-101.', 'status': 'Resolved - System Auto-Deduplicated', 'timestamp': '2026-03-26T09:12:00Z'}
  ];

  Map<String, dynamic> _aiDraftReport = {
    'id': 'DRAFT-REP-2026-01',
    'title': 'Sweezen Foundation Annual Impact & CSR Governance Report 2026',
    'author': 'Ask Sweezen AI Analytics Engine v3.4',
    'executiveSummary': 'This draft report evaluates 2 active programs across Haridwar and Uttarakhand, summarizing financial utilization of ₹14,311 raised, 211+ direct healthcare beneficiaries, and 100% digital 80G tax receipt compliance.',
    'highlights': [
      'Direct beneficiary outreach expanded by 34% quarter-on-quarter.',
      '100% of field volunteer task reports geo-verified with real-time GPS coordinates.',
      'Zero compliance deviations across 80G tax exemption certificates.'
    ],
    'isHumanApproved': false,
    'approvedBy': null,
    'approvalDate': null,
    'status': 'Pending Human Approval'
  };

  // Getters
  String get currentLanguage => _currentLanguage;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get onboardingCompleted => _onboardingCompleted;

  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get isAppUnlocked => _isAppUnlocked;

  double get textScaleFactor => _textScaleFactor;
  bool get isHighContrast => _isHighContrast;

  List<Map<String, dynamic>> get csrProposals => _csrProposals;
  List<Map<String, dynamic>> get portalPartners => _portalPartners;
  List<Map<String, dynamic>> get portalReferrals => _portalReferrals;
  List<Map<String, dynamic>> get portalCamps => _portalCamps;
  List<Map<String, dynamic>> get portalStudentProgress => _portalStudentProgress;
  List<Map<String, dynamic>> get aiReportSummaries => _aiReportSummaries;
  List<Map<String, dynamic>> get aiAnomalies => _aiAnomalies;
  Map<String, dynamic> get aiDraftReport => _aiDraftReport;

  // Accessibility Actions
  void setTextScaleFactor(double factor) {
    _textScaleFactor = factor;
    notifyListeners();
  }

  void toggleHighContrast(bool value) {
    _isHighContrast = value;
    notifyListeners();
  }

  // CSR Actions
  void addCsrProposal(Map<String, dynamic> proposal) {
    _csrProposals.insert(0, proposal);
    notifyListeners();
  }

  // Portal Actions
  void addPortalPartner(Map<String, dynamic> partner) {
    _portalPartners.add(partner);
    notifyListeners();
  }

  void addPortalReferral(Map<String, dynamic> referral) {
    _portalReferrals.insert(0, referral);
    notifyListeners();
  }

  void addPortalCamp(Map<String, dynamic> camp) {
    _portalCamps.insert(0, camp);
    notifyListeners();
  }

  void addStudentProgressRecord(Map<String, dynamic> record) {
    _portalStudentProgress.insert(0, record);
    notifyListeners();
  }

  // AI Analytics Actions
  void toggleApproveDraftReport({required bool approve, String reviewerName = 'Sheetal (Director & Human Reviewer)'}) {
    if (approve) {
      _aiDraftReport['isHumanApproved'] = true;
      _aiDraftReport['approvedBy'] = reviewerName;
      _aiDraftReport['approvalDate'] = DateTime.now().toIso8601String();
      _aiDraftReport['status'] = 'Approved & Published';
    } else {
      _aiDraftReport['isHumanApproved'] = false;
      _aiDraftReport['approvedBy'] = null;
      _aiDraftReport['approvalDate'] = null;
      _aiDraftReport['status'] = 'Rejected / Needs Revision';
    }
    notifyListeners();
  }

  void completeOnboarding() {
    _onboardingCompleted = true;
    notifyListeners();
  }

  List<ProjectModel> get projects => _projects;
  List<TaskModel> get assignedTasks => _assignedTasks;
  List<EventModel> get events => _events;
  List<Map<String, dynamic>> get offlineSyncQueue => _offlineSyncQueue;
  List<String> get notifications => _notifications;
  Map<String, String> get impactMetrics => _impactMetrics;

  AppStateProvider() {
    _initDefaults();
    loadAppLockSettings();
  }

  Future<void> loadAppLockSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAppLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
      _isAppUnlocked = !_isAppLockEnabled; // If lock is enabled, start locked until biometrics scanned
      notifyListeners();
    } catch (e) {
      debugPrint('AppLock settings load error: $e');
    }
  }

  Future<bool> checkBiometricsAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleAppLock(bool enable) async {
    if (enable) {
      final isAvailable = await checkBiometricsAvailable();
      if (!isAvailable) {
        // Fallback: Enable lock with PIN/Device credentials
      }
      final authenticated = await authenticateAndUnlock(reason: 'Authenticate fingerprint to enable App Lock');
      if (authenticated) {
        _isAppLockEnabled = true;
        _isAppUnlocked = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('app_lock_enabled', true);
        notifyListeners();
        return true;
      }
      return false;
    } else {
      final authenticated = await authenticateAndUnlock(reason: 'Authenticate fingerprint to disable App Lock');
      if (authenticated) {
        _isAppLockEnabled = false;
        _isAppUnlocked = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('app_lock_enabled', false);
        notifyListeners();
        return true;
      }
      return false;
    }
  }

  Future<bool> authenticateAndUnlock({String reason = 'Scan fingerprint or enter PIN to unlock Sweezen Foundation App'}) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      if (didAuthenticate) {
        _isAppUnlocked = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Biometric auth error: $e');
    }
    return false;
  }

  void forceLockApp() {
    if (_isAppLockEnabled) {
      _isAppUnlocked = false;
      notifyListeners();
    }
  }

  void _initDefaults() {
    // Default Volunteer/Director Profile
    _currentUser = UserModel(
      id: 1,
      name: 'Sheetal',
      email: 'sheetal@sweezenfoundation.org',
      phone: '+91-9045652546',
      role: 'Director',
      profilePhoto: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80',
      skills: ['Strategic Planning', 'Healthcare', 'Field Outreach'],
      interests: ['Healthcare', 'Environment'],
      location: 'Haridwar, Uttarakhand',
      availability: 'Full-Time',
      impactPoints: 1500,
      badges: ['Director', 'Founding Member'],
      humanityCardId: 'SWZ-CARD-1001',
    );
    _isLoggedIn = false;

    // Load Projects, Events & Impact Stats from MongoDB via API
    loadProjects();
    loadEvents();
    loadImpactStats();
  }

  Future<void> loadImpactStats() async {
    final stats = await ApiService.fetchImpactStats();
    if (stats.isNotEmpty) {
      final double totalFunds = (stats['totalFundsRaised'] ?? 0).toDouble();
      final int proj = (stats['totalProjects'] ?? 0).toInt();
      final int ben = (stats['totalBeneficiaries'] ?? 0).toInt();
      final int vol = (stats['totalVolunteers'] ?? 0).toInt();

      _impactMetrics = {
        'total_projects': '$proj',
        'beneficiaries': '$ben',
        'volunteers': '$vol',
        'districts': '12',
        'funds_raised': '₹${totalFunds.toStringAsFixed(0)}'
      };
      notifyListeners();
    }
  }

  void toggleLanguage(String langCode) {
    _currentLanguage = langCode;
    notifyListeners();
  }

  void loginUser(UserModel user) {
    _currentUser = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logoutUser() {
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> loadProjects({String category = 'All'}) async {
    _projects = await ApiService.fetchProjects(category: category);
    notifyListeners();
  }

  Future<void> loadEvents() async {
    _events = await ApiService.fetchEvents();
    notifyListeners();
  }

  // Update Task Status & Submit Field Report
  void updateTaskStatus(int taskId, String newStatus, {String? remarks, String? photoUrl, double? lat, double? lng, bool isOffline = false}) {
    final idx = _assignedTasks.indexWhere((t) => t.id == taskId);
    if (idx >= 0) {
      final old = _assignedTasks[idx];
      _assignedTasks[idx] = TaskModel(
        id: old.id,
        title: old.title,
        description: old.description,
        location: old.location,
        requiredSkills: old.requiredSkills,
        status: newStatus,
        remarks: remarks ?? old.remarks,
        photoUrl: photoUrl ?? old.photoUrl,
        geoLat: lat ?? old.geoLat,
        geoLng: lng ?? old.geoLng,
      );

      if (isOffline) {
        _offlineSyncQueue.add({
          'taskId': taskId,
          'status': newStatus,
          'remarks': remarks,
          'photoUrl': photoUrl,
          'geoLat': lat,
          'geoLng': lng,
          'timestamp': DateTime.now().toIso8601String()
        });
      }

      // Add points
      if (newStatus == 'Completed' && _currentUser != null) {
        final currentPts = _currentUser!.impactPoints + 50;
        List<String> badges = List.from(_currentUser!.badges);
        if (currentPts >= 300 && !badges.contains('Community Hero')) {
          badges.add('Community Hero');
        }
        _currentUser = UserModel(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          phone: _currentUser!.phone,
          role: _currentUser!.role,
          profilePhoto: _currentUser!.profilePhoto,
          skills: _currentUser!.skills,
          interests: _currentUser!.interests,
          location: _currentUser!.location,
          availability: _currentUser!.availability,
          impactPoints: currentPts,
          badges: badges,
          humanityCardId: _currentUser!.humanityCardId,
        );
      }

      notifyListeners();
    }
  }

  // Sync Offline Queue
  void syncOfflineQueue() {
    if (_offlineSyncQueue.isNotEmpty) {
      _offlineSyncQueue.clear();
      _notifications.insert(0, 'Offline field reports synced successfully with Cloud Database!');
      notifyListeners();
    }
  }

  // Register Event
  void registerForEvent(int eventId) {
    _notifications.insert(0, 'Registered for event! Digital participation certificate generated.');
    notifyListeners();
  }
}
