import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Send OTP to the given phone number (e.g., +919876543210)
  static Future<void> sendPhoneOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(String errorMessage) onError,
    required Function(UserCredential userCredential) onAutoVerified,
    int? resendToken,
  }) async {
    try {
      // Ensure phone number starts with country code, default to +91 if missing
      String formattedPhone = phoneNumber.trim();
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+91$formattedPhone';
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('[Firebase Auth] Verification Auto-Completed!');
          try {
            UserCredential userCredential = await _auth.signInWithCredential(credential);
            onAutoVerified(userCredential);
          } catch (e) {
            onError('Auto sign-in failed: ${e.toString()}');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('[Firebase Auth] Verification Failed: ${e.code} - ${e.message}');
          String message = 'Phone verification failed';
          if (e.code == 'invalid-phone-number') {
            message = 'Invalid phone number format. Please enter full number with country code.';
          } else if (e.code == 'quota-exceeded') {
            message = 'SMS quota exceeded for Firebase project. Please try again later.';
          } else if (e.code == 'too-many-requests') {
            message = 'Too many attempts. Please wait a few minutes.';
          } else if (e.message != null && e.message!.isNotEmpty) {
            message = e.message!;
          }
          onError(message);
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('[Firebase Auth] Code Sent! Verification ID: $verificationId');
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('[Firebase Auth] Auto retrieval timeout for ID: $verificationId');
        },
      );
    } catch (e) {
      onError('Error initiating Phone OTP: ${e.toString()}');
    }
  }

  /// Verify the 6-digit OTP code entered by the user
  static Future<Map<String, dynamic>> verifyOtpCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();

      return {
        'success': true,
        'user': userCredential.user,
        'phoneNumber': userCredential.user?.phoneNumber,
        'idToken': idToken,
      };
    } on FirebaseAuthException catch (e) {
      String msg = 'Invalid OTP code';
      if (e.code == 'invalid-verification-code') {
        msg = 'The OTP code entered is incorrect. Please try again.';
      } else if (e.code == 'session-expired') {
        msg = 'The OTP session has expired. Please request a new OTP.';
      }
      return {'success': false, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': 'Verification failed: ${e.toString()}'};
    }
  }

  /// Get Current Firebase User ID Token
  static Future<String?> getCurrentUserToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  /// Sign Out Firebase User
  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
