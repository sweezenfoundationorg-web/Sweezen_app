import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class AppLockScreen extends StatefulWidget {
  final Widget child;

  const AppLockScreen({Key? key, required this.child}) : super(key: key);

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerBiometricAuth();
    });
  }

  void _triggerBiometricAuth() {
    final state = Provider.of<AppStateProvider>(context, listen: false);
    if (state.isAppLockEnabled && !state.isAppUnlocked) {
      state.authenticateAndUnlock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    // If lock is disabled OR app is unlocked, show child application screens
    if (!state.isAppLockEnabled || state.isAppUnlocked) {
      return widget.child;
    }

    // Otherwise render App Lock Screen
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.darkNavyGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Sweezen Logo Badge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardNavy,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.goldAccent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.goldAccent.withOpacity(0.3),
                        blurRadius: 25,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                    width: 80,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.shield_outlined,
                      color: AppTheme.amberGold,
                      size: 60,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'SWEEZEN FOUNDATION',
                  style: TextStyle(
                    color: AppTheme.goldAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '🔒 App Security Lock Active',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                // Fingerprint Pulse Icon
                GestureDetector(
                  onTap: () => state.authenticateAndUnlock(),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.goldAccent.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.goldAccent, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.goldAccent.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.fingerprint,
                      color: AppTheme.goldAccent,
                      size: 64,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Scan Fingerprint to Unlock',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Touch the fingerprint sensor or enter your device security PIN to access your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),

                const Spacer(),

                // Manual Unlock Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => state.authenticateAndUnlock(),
                    icon: const Icon(Icons.lock_open, color: Colors.black),
                    label: const Text(
                      'UNLOCK WITH BIOMETRICS / PIN',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
