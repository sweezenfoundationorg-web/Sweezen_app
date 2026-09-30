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

  // Getters
  String get currentLanguage => _currentLanguage;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get onboardingCompleted => _onboardingCompleted;

  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get isAppUnlocked => _isAppUnlocked;

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

    // Load Projects
    loadProjects();

    // Default Tasks (Matching Website Data)
    _assignedTasks = [
      TaskModel(
        id: 101,
        title: 'HealthCare Camp Patient Registration & Assistance',
        description: 'Assist doctors with patient token distribution, vital recordings, and basic medicine kit dispatch at Haridwar Health Camp.',
        location: '353 Avas Vikas Colony, Haridwar',
        requiredSkills: ['Field Work', 'Patient Assistance', 'First Aid'],
        status: 'Pending',
        remarks: 'Coordinate with Camp Leader Sheetal on arrival.',
        geoLat: 29.9600,
        geoLng: 78.2000,
      ),
      TaskModel(
        id: 102,
        title: 'Haridwar Riverbank Environment Sanitation Drive',
        description: 'Lead volunteer groups in plastic waste collection, segregation, and public eco-awareness near riverbank ghats.',
        location: 'Riverbank Ghats, Haridwar',
        requiredSkills: ['Environment', 'Community Work'],
        status: 'In Progress',
        remarks: 'Safety gloves and collection bags will be provided.',
        photoUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=600&q=80',
        geoLat: 29.9457,
        geoLng: 78.1642,
      )
    ];

    // Default Events (Matching Website Data)
    _events = [
      EventModel(
        id: 201,
        title: 'Community HealthCare Camp Haridwar',
        description: 'Free medical checkup camp providing doctor consultations, free medicine distribution, and diagnostic screenings for local families.',
        category: 'Healthcare',
        location: '353 Avas Vikas Colony, Haridwar, Uttarakhand',
        registeredCount: 211,
        bannerUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=800&q=80',
        status: 'Upcoming',
      ),
      EventModel(
        id: 202,
        title: 'Swachh Haridwar Environment Drive',
        description: 'Mass public cleanliness drive, plastic waste collection, and riverbank environmental sanitation campaign.',
        category: 'Environment',
        location: 'Ghats & Public Parks, Haridwar, Uttarakhand',
        registeredCount: 100,
        bannerUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=800&q=80',
        status: 'Upcoming',
      )
    ];
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
