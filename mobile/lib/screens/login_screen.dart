import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_gold_button.dart';
import 'register_screen.dart';
import 'main_shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _otpSent = false;
  bool _isLoading = false;
  String? _devOtp;

  void _handleRequestOtp() async {
    final target = _targetController.text.trim();
    if (target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Mobile Number or Email Address')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final res = await ApiService.requestOtp(target);

    setState(() {
      _isLoading = false;
      _otpSent = true;
      _devOtp = res['otp'];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message'] ?? 'OTP dispatched via Gmail SMTP!'),
        backgroundColor: AppTheme.amberGold,
      ),
    );
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

    final res = await ApiService.verifyOtp(target, otp);

    setState(() => _isLoading = false);

    if (res['success'] == true) {
      final state = Provider.of<AppStateProvider>(context, listen: false);
      if (res['user'] != null && res['user'] is Map<String, dynamic>) {
        state.loginUser(UserModel.fromJson(Map<String, dynamic>.from(res['user'])));
      } else {
        state.loginUser(state.currentUser!);
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Invalid OTP code'), backgroundColor: AppTheme.errorRed),
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
                const SizedBox(height: 40),

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
                            : 'Enter your Mobile Number or Email to receive an instant OTP verification code via Gmail SMTP.',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.3),
                      ),
                      const SizedBox(height: 24),

                      if (!_otpSent) ...[
                        TextField(
                          controller: _targetController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Mobile Number / Email Address',
                            prefixIcon: Icon(Icons.phone_android, color: AppTheme.goldAccent),
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
                        if (_devOtp != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryNavy,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.amberGold.withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.mark_email_read, color: AppTheme.amberGold, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'Gmail SMTP OTP Code: $_devOtp',
                                  style: const TextStyle(color: AppTheme.lightGold, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],

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
                            child: const Text('Change Mobile/Email', style: TextStyle(color: AppTheme.textMuted)),
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
