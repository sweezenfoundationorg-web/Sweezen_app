class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String profilePhoto;
  final List<String> skills;
  final List<String> interests;
  final String location;
  final String availability;
  final int impactPoints;
  final List<String> badges;
  final String humanityCardId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.profilePhoto,
    required this.skills,
    required this.interests,
    required this.location,
    required this.availability,
    required this.impactPoints,
    required this.badges,
    required this.humanityCardId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 1,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'Volunteer',
      profilePhoto: json['profile_photo'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      location: json['location'] ?? '',
      availability: json['availability'] ?? 'Flexible',
      impactPoints: json['impact_points'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      humanityCardId: json['humanity_card_id'] ?? '',
    );
  }
}

class ProjectModel {
  final int id;
  final String name;
  final String category;
  final String description;
  final List<String> objectives;
  final String location;
  final int beneficiaryCount;
  final double fundingGoal;
  final double fundingRaised;
  final double fundingUtilized;
  final String status;
  final String imageUrl;

  ProjectModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.objectives,
    required this.location,
    required this.beneficiaryCount,
    required this.fundingGoal,
    required this.fundingRaised,
    required this.fundingUtilized,
    required this.status,
    required this.imageUrl,
  });

  double get progressPercentage {
    if (fundingGoal == 0) return 0.0;
    final val = fundingRaised / fundingGoal;
    return val > 1.0 ? 1.0 : val;
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? 'Healthcare',
      description: json['description'] ?? '',
      objectives: List<String>.from(json['objectives'] ?? []),
      location: json['location'] ?? '',
      beneficiaryCount: json['beneficiary_count'] ?? 0,
      fundingGoal: (json['funding_goal'] ?? 0).toDouble(),
      fundingRaised: (json['funding_raised'] ?? 0).toDouble(),
      fundingUtilized: (json['funding_utilized'] ?? 0).toDouble(),
      status: json['status'] ?? 'Active',
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class TaskModel {
  final int id;
  final String title;
  final String description;
  final String location;
  final List<String> requiredSkills;
  final String status; // Pending, In Progress, Completed
  final String remarks;
  final String? photoUrl;
  final double? geoLat;
  final double? geoLng;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.requiredSkills,
    required this.status,
    required this.remarks,
    this.photoUrl,
    this.geoLat,
    this.geoLng,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      requiredSkills: List<String>.from(json['required_skills'] ?? []),
      status: json['status'] ?? 'Pending',
      remarks: json['remarks'] ?? '',
      photoUrl: json['photo_url'],
      geoLat: json['geo_lat'] != null ? (json['geo_lat'] as num).toDouble() : null,
      geoLng: json['geo_lng'] != null ? (json['geo_lng'] as num).toDouble() : null,
    );
  }
}

class EventModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final String location;
  final int registeredCount;
  final String bannerUrl;
  final String status;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.registeredCount,
    required this.bannerUrl,
    required this.status,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Outreach',
      location: json['location'] ?? '',
      registeredCount: json['registered_count'] ?? 0,
      bannerUrl: json['banner_url'] ?? '',
      status: json['status'] ?? 'Upcoming',
    );
  }
}
