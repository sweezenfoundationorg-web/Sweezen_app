import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import 'onboarding_screen.dart';
import 'main_shell_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final state = Provider.of<AppStateProvider>(context, listen: false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => state.isLoggedIn ? const MainShellScreen() : const OnboardingScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Eagle Logo Asset Centered Badge (Square format)
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppTheme.cardNavy,
                  border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.6), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.amberGold.withValues(alpha: 0.35),
                      blurRadius: 30,
                      spreadRadius: 4,
                    )
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) {
                        return const Icon(Icons.shield, color: AppTheme.goldAccent, size: 80);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'SWEEZEN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.goldAccent,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0,
                ),
              ),
              const Text(
                'FOUNDATION',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 6.0,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.cardNavy,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'SECTION 8 NON-PROFIT | UN SDG ALIGNED',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.amberGold,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.amberGold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
