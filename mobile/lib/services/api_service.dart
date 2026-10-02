import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  // Backend Base API URL
  static String baseUrl = 'https://sweezen-backend-api-bgo3.onrender.com/api';

  // Request OTP via Email (No Mock Fallback)
  static Future<Map<String, dynamic>> requestOtp(String recipient) async {
    try {
      // Try request-otp endpoint first, fallback to email-otp/send
      var res = await http.post(
        Uri.parse('$baseUrl/auth/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'target': recipient, 'email': recipient}),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        res = await http.post(
          Uri.parse('$baseUrl/auth/email-otp/send'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': recipient}),
        );
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      } else {
        final body = jsonDecode(res.body);
        final errMsg = body['message'] ?? body['detail'] ?? 'Failed to send OTP email';
        return {'success': false, 'message': errMsg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: Could not connect to backend ($e)'};
    }
  }

  // Verify OTP (No Mock Fallback)
  static Future<Map<String, dynamic>> verifyOtp(String recipient, String otp) async {
    try {
      var res = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'target': recipient, 'email': recipient, 'otp': otp}),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        res = await http.post(
          Uri.parse('$baseUrl/auth/email-otp/verify'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': recipient, 'otp': otp}),
        );
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      } else {
        final body = jsonDecode(res.body);
        final errMsg = body['message'] ?? body['detail'] ?? 'Invalid or expired OTP code';
        return {'success': false, 'message': errMsg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error during OTP verification ($e)'};
    }
  }

  // Multi-step Registration (No Mock Fallback)
  static Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      } else {
        final body = jsonDecode(res.body);
        return {'success': false, 'message': body['message'] ?? body['detail'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error during registration ($e)'};
    }
  }

  // Fetch Projects from Database (No Mock Fallback)
  static Future<List<ProjectModel>> fetchProjects({String category = 'All'}) async {
    final url = category == 'All' ? '$baseUrl/projects' : '$baseUrl/projects?category=$category';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final rawList = data['projects'] ?? data;
      if (rawList is List) {
        return rawList.map((p) => ProjectModel.fromJson(p)).toList();
      }
    }
    throw Exception('Failed to load projects from backend (Status: ${res.statusCode})');
  }

  // Create Donation Order (Razorpay) (No Mock Fallback)
  static Future<Map<String, dynamic>> createDonationOrder(
    double amount, {
    int? projectId,
    required String donorName,
    required String donorEmail,
    bool isAnonymous = false,
    bool is80g = true,
    String? panNumber
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/donations/create-order'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amount,
        'project_id': projectId,
        'donor_name': donorName,
        'donor_email': donorEmail,
        'is_anonymous': isAnonymous,
        'is_80g_requested': is80g,
        'pan_number': panNumber
      }),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    final body = jsonDecode(res.body);
    throw Exception(body['message'] ?? body['detail'] ?? 'Failed to create donation order');
  }

  // Verify Donation Payment (No Mock Fallback)
  static Future<Map<String, dynamic>> verifyDonationPayment(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$baseUrl/donations/verify-payment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    final body = jsonDecode(res.body);
    throw Exception(body['message'] ?? body['detail'] ?? 'Donation payment verification failed');
  }

  // Ask Sweezen AI Chatbot (No Mock Fallback)
  static Future<Map<String, dynamic>> askSweezenAi(String question, String language) async {
    final res = await http.post(
      Uri.parse('$baseUrl/chatbot/ask'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'question': question, 'language': language}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('AI Chatbot request failed');
  }

  // Scan & Log Humanity Smart ID (No Mock Fallback)
  static Future<Map<String, dynamic>> logHumanityCardService({
    required String cardNumber,
    required String serviceType,
    String? location,
    double? lat,
    double? lng,
    String? notes
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/humanity-card/log-service'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'card_number': cardNumber,
        'service_type': serviceType,
        'location': location ?? 'Mobile Field Station',
        'geo_lat': lat ?? 23.3441,
        'geo_lng': lng ?? 85.3096,
        'notes': notes ?? 'Service delivered successfully.'
      }),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw Exception('Failed to log Humanity Smart ID service');
  }

  // Get Official WhatsApp Business Helpline Link
  static Future<Map<String, dynamic>> getWhatsAppLink() async {
    final res = await http.get(Uri.parse('$baseUrl/communication/whatsapp-link'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return {'success': true, 'whatsapp_url': 'https://wa.me/919876543210?text=Hello%20Sweezen%20Foundation!'};
  }

  // Fetch Events from Database (No Mock Fallback)
  static Future<List<EventModel>> fetchEvents() async {
    final res = await http.get(Uri.parse('$baseUrl/events'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final rawList = data['events'] ?? data;
      if (rawList is List) {
        return rawList.map((e) => EventModel.fromJson(e)).toList();
      }
    }
    throw Exception('Failed to fetch events from backend (Status: ${res.statusCode})');
  }

  // Setup Google 2FA (TOTP)
  static Future<Map<String, dynamic>> setup2FA(String email) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/setup-2fa'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
      return {'success': false, 'message': 'Failed to setup 2FA'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Verify Google 2FA (TOTP)
  static Future<Map<String, dynamic>> verify2FA(String token, String secret) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/verify-2fa'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'secret': secret}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Fetch Real Impact Stats from MongoDB
  static Future<Map<String, dynamic>> fetchImpactStats() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/stats'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['stats'] ?? {};
      }
    } catch (_) {}
    return {};
  }
}
