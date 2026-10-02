import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../services/api_service.dart';
import '../services/firebase_auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_gold_button.dart';
import 'register_screen.dart';
import 'main_shell_screen.dart';

enum AuthMethod { firebasePhone, emailSmtp }

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  AuthMethod _authMethod = AuthMethod.firebasePhone;
  bool _otpSent = false;
  bool _isLoading = false;
  String? _firebaseVerificationId;
  int? _resendToken;

  void _handleRequestOtp() async {
    final target = _targetController.text.trim();
    if (target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Mobile Number or Email Address')),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (_authMethod == AuthMethod.firebasePhone) {
      // Firebase Phone Auth SMS OTP
      await FirebaseAuthService.sendPhoneOtp(
        phoneNumber: target,
        onCodeSent: (verificationId, resendToken) {
          setState(() {
            _isLoading = false;
            _otpSent = true;
            _firebaseVerificationId = verificationId;
            _resendToken = resendToken;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Firebase SMS OTP sent! Please check your mobile messages.'),
              backgroundColor: AppTheme.amberGold,
            ),
          );
        },
        onError: (errorMsg) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: AppTheme.errorRed),
          );
        },
        onAutoVerified: (userCredential) async {
          setState(() => _isLoading = false);
          _completeFirebaseLogin(userCredential.user?.phoneNumber ?? target, await userCredential.user?.getIdToken());
        },
        resendToken: _resendToken,
      );
    } else {
      // Email OTP via SMTP
      final res = await ApiService.requestOtp(target);

      setState(() {
        _isLoading = false;
        _otpSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent to your Email address! Please check your inbox.'),
          backgroundColor: AppTheme.amberGold,
        ),
      );
    }
  }

  void _handleVerifyOtp() async {
    final target = _targetController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (_authMethod == AuthMethod.firebasePhone && _firebaseVerificationId != null) {
      // Firebase Verification
      final firebaseRes = await FirebaseAuthService.verifyOtpCode(
        verificationId: _firebaseVerificationId!,
        smsCode: otp,
      );

      if (firebaseRes['success'] == true) {
        final phoneNumber = firebaseRes['phoneNumber'] ?? target;
        final idToken = firebaseRes['idToken'];
        await _completeFirebaseLogin(phoneNumber, idToken);
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(firebaseRes['message'] ?? 'Invalid Firebase OTP'), backgroundColor: AppTheme.errorRed),
        );
      }
    } else {
      // Email OTP Verification
      final res = await ApiService.verifyOtp(target, otp);
      setState(() => _isLoading = false);

      if (res['success'] == true) {
        final state = Provider.of<AppStateProvider>(context, listen: false);
        final isRegistered = res['isRegistered'] ?? (res['user'] != null);
        
        if (isRegistered && res['user'] != null && res['user'] is Map) {
          final userModel = UserModel.fromJson(Map<String, dynamic>.from(res['user']));
          state.loginUser(userModel);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome back, ${userModel.name}! Logged in successfully.'), backgroundColor: AppTheme.successGreen),
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainShellScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP Verified! Please complete your registration.'), backgroundColor: AppTheme.amberGold),
          );

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RegisterScreen(initialTarget: target),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Invalid OTP code'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  Future<void> _completeFirebaseLogin(String phoneNumber, String? idToken) async {
    final res = await ApiService.firebasePhoneLogin(
      phoneNumber: phoneNumber,
      idToken: idToken,
    );

    setState(() => _isLoading = false);

    if (res['success'] == true && res['user'] != null) {
      final state = Provider.of<AppStateProvider>(context, listen: false);
      final userModel = UserModel.fromJson(Map<String, dynamic>.from(res['user']));
      state.loginUser(userModel);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome back, ${userModel.name}! Firebase Phone Auth Success.'), backgroundColor: AppTheme.successGreen),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    } else {
      // Direct registration prompt with prefilled phone number
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RegisterScreen(initialTarget: phoneNumber),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.darkNavyGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'SWEEZEN FOUNDATION',
                    style: TextStyle(
                      color: AppTheme.goldAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Empowering Rural Communities • Changing Lives',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 30),

                // Method Selector Tabs
                if (!_otpSent)
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Firebase Phone OTP'),
                          selected: _authMethod == AuthMethod.firebasePhone,
                          selectedColor: AppTheme.goldAccent.withOpacity(0.2),
                          onSelected: (val) {
                            if (val) setState(() => _authMethod = AuthMethod.firebasePhone);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Email OTP'),
                          selected: _authMethod == AuthMethod.emailSmtp,
                          selectedColor: AppTheme.goldAccent.withOpacity(0.2),
                          onSelected: (val) {
                            if (val) setState(() => _authMethod = AuthMethod.emailSmtp);
                          },
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                // Card Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardNavy,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _otpSent ? 'Enter Verification Code' : 'Sign In to Sweezen',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _otpSent
                            ? 'We sent a 6-digit OTP code to ${_targetController.text}'
                            : _authMethod == AuthMethod.firebasePhone
                                ? 'Enter your Mobile Number (+91...) to receive SMS OTP via Firebase Auth.'
                                : 'Enter your Email address to receive instant OTP verification code via Nodemailer SMTP.',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.3),
                      ),
                      const SizedBox(height: 24),

                      if (!_otpSent) ...[
                        TextField(
                          controller: _targetController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: _authMethod == AuthMethod.firebasePhone ? TextInputType.phone : TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: _authMethod == AuthMethod.firebasePhone ? 'Mobile Number (e.g. +919876543210)' : 'Email Address',
                            prefixIcon: Icon(_authMethod == AuthMethod.firebasePhone ? Icons.phone : Icons.email, color: AppTheme.goldAccent),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: CustomGoldButton(
                            text: _isLoading ? 'DISPATCHING OTP...' : 'REQUEST OTP CODE',
                            icon: Icons.send,
                            onPressed: _handleRequestOtp,
                          ),
                        ),
                      ] else ...[
                        TextField(
                          controller: _otpController,
                          style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 4.0),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            labelText: '6-Digit OTP',
                            prefixIcon: Icon(Icons.lock_clock, color: AppTheme.goldAccent),
                          ),
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: CustomGoldButton(
                            text: _isLoading ? 'VERIFYING...' : 'VERIFY & SIGN IN',
                            icon: Icons.check_circle,
                            onPressed: _handleVerifyOtp,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () => setState(() => _otpSent = false),
                            child: const Text('Change Target / Resend', style: TextStyle(color: AppTheme.textMuted)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Register Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(color: AppTheme.textMuted)),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Register Now',
                          style: TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
