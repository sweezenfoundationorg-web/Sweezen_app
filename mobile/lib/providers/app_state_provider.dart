import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AppStateProvider extends ChangeNotifier {
  String _currentLanguage = 'en';
  UserModel? _currentUser;
  bool _isLoggedIn = false;

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
    'total_projects': '25+',
    'beneficiaries': '48,200+',
    'volunteers': '1,240+',
    'funds_raised': '₹4.82 Cr'
  };

  bool _onboardingCompleted = false;

  // Getters
  String get currentLanguage => _currentLanguage;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get onboardingCompleted => _onboardingCompleted;

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
  }

  void _initDefaults() {
    // Default Volunteer User Profile
    _currentUser = UserModel(
      id: 1,
      name: 'Aarav Sharma',
      email: 'aarav@sweezenfoundation.org',
      phone: '+91 9876543210',
      role: 'Volunteer',
      profilePhoto: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      skills: ['Field Work', 'First Aid', 'Teaching', 'Hindi Translation'],
      interests: ['Healthcare', 'Education'],
      location: 'Mumbai, Maharashtra',
      availability: 'Weekends (Sat - Sun)',
      impactPoints: 340,
      badges: ['Community Hero', 'Top Field Agent', '100+ Hours'],
      humanityCardId: 'SWZ-CARD-8849',
    );
    _isLoggedIn = false;

    // Load Projects
    loadProjects();

    // Default Tasks
    _assignedTasks = [
      TaskModel(
        id: 101,
        title: 'Distribute Health Kits in Village Camp',
        description: 'Provide hygiene kits, basic medicine packages, and nutritional supplements to families at Camp 4.',
        location: 'Camp 4, Ranchi Outskirts',
        requiredSkills: ['Field Work', 'First Aid'],
        status: 'Pending',
        remarks: 'Bring extra water bottles for volunteers.',
      ),
      TaskModel(
        id: 102,
        title: 'Digital Learning Assessment Drive',
        description: 'Evaluate student tablet usage and collect feedback from local teachers at Dharavi Smart Pod.',
        location: 'Dharavi Center 2, Mumbai',
        requiredSkills: ['Teaching', 'Data Entry'],
        status: 'In Progress',
        remarks: 'Forms to be filled offline if internet drops.',
        photoUrl: 'https://images.unsplash.com/photo-1509062522246-3755977927d7?auto=format&fit=crop&w=600&q=80',
      ),
      TaskModel(
        id: 103,
        title: 'Riverbank Tree Sapling Geo-tagging',
        description: 'Plant 200 saplings and capture exact GPS locations using the mobile app scanner.',
        location: 'Uttarkashi Sector 3',
        requiredSkills: ['Environment', 'GPS Tagging'],
        status: 'Completed',
        remarks: '200 saplings tagged successfully!',
        photoUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=600&q=80',
      )
    ];

    // Default Events
    _events = [
      EventModel(
        id: 201,
        title: 'Annual Sweezen Impact Conclave 2026',
        description: 'Join philanthropic leaders, rural volunteers, and donors for an inspiring summit on UN SDG alignment and community empowerment.',
        category: 'Conference',
        location: 'National Convention Center, New Delhi',
        registeredCount: 342,
        bannerUrl: 'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=800&q=80',
        status: 'Upcoming',
      ),
      EventModel(
        id: 202,
        title: 'Mega Health & Eye Checkup Camp',
        description: 'Free comprehensive health checkups, eye testing, and prescription spectacles for over 1,500 rural villagers.',
        category: 'Healthcare',
        location: 'Community Center, Thane Rural',
        registeredCount: 210,
        bannerUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=800&q=80',
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
