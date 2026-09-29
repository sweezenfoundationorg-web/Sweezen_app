import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_gold_button.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Empowering Rural Education',
      'subtitle': 'DIGITAL SMART PODS & LITERACY',
      'description':
          'Bridging the digital divide by equipping village schools with solar smart tablets, interactive learning modules, and trained digital educators.',
      'imageUrl': 'https://images.unsplash.com/photo-1509062522246-3755977927d7?auto=format&fit=crop&w=800&q=80',
      'icon': Icons.school_rounded,
      'badge': 'UN SDG 4: Quality Education',
      'stats': '15,000+ Students Empowered',
    },
    {
      'title': 'Healthcare & Medical Relief',
      'subtitle': 'MOBILE HEALTH CAMPS & EYE CARE',
      'description':
          'Providing free comprehensive medical checkups, essential medicines, vision care, and maternal health support directly to underserved rural communities.',
      'imageUrl': 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=800&q=80',
      'icon': Icons.medical_services_rounded,
      'badge': 'UN SDG 3: Good Health & Well-being',
      'stats': '48,000+ Medical Examinations',
    },
    {
      'title': 'Eco Drive & Community Impact',
      'subtitle': 'GEO-TAGGED TREE PLANTATION & WATER',
      'description':
          'Driving sustainable climate action through community tree plantations, verified GPS geo-tagging, and clean drinking water filtration systems.',
      'imageUrl': 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=800&q=80',
      'icon': Icons.nature_people_rounded,
      'badge': 'UN SDG 13: Climate Action',
      'stats': '120,000+ Saplings Planted',
    },
  ];

  void _onFinishOnboarding() {
    final state = Provider.of<AppStateProvider>(context, listen: false);
    state.completeOnboarding();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.darkNavyGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar with Logo and Skip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.cardNavy,
                            border: Border.all(color: AppTheme.goldAccent.withOpacity(0.4)),
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 28,
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, err, stack) => const Icon(Icons.shield, color: AppTheme.goldAccent, size: 24),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SWEEZEN',
                              style: TextStyle(
                                color: AppTheme.goldAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              'FOUNDATION',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _onFinishOnboarding,
                      child: const Text(
                        'SKIP',
                        style: TextStyle(
                          color: AppTheme.amberGold,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main PageView Carousel
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          // Visual Hero Banner Container
                          Container(
                            height: size.height * 0.32,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.amberGold.withOpacity(0.15),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Stack(
                                children: [
                                  // Network Image with smooth fallback
                                  Image.network(
                                    slide['imageUrl'],
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) {
                                      return Container(
                                        color: AppTheme.cardNavy,
                                        child: Center(
                                          child: Icon(slide['icon'], size: 80, color: AppTheme.goldAccent),
                                        ),
                                      );
                                    },
                                  ),

                                  // Dark Overlay Gradient
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          AppTheme.primaryNavy.withOpacity(0.6),
                                          AppTheme.primaryNavy.withOpacity(0.95),
                                        ],
                                        stops: const [0.3, 0.7, 1.0],
                                      ),
                                    ),
                                  ),

                                  // Badge Pill at top right
                                  Positioned(
                                    top: 14,
                                    right: 14,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppTheme.amberGold.withOpacity(0.5)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(slide['icon'], color: AppTheme.amberGold, size: 14),
                                          const SizedBox(width: 6),
                                          Text(
                                            slide['badge'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Bottom Stats Overlay
                                  Positioned(
                                    bottom: 14,
                                    left: 14,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.amberGold.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        slide['stats'],
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Subtitle Tag
                          Text(
                            slide['subtitle'],
                            style: const TextStyle(
                              color: AppTheme.amberGold,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Main Title
                          Text(
                            slide['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Description
                          Text(
                            slide['description'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13.5,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Control Bar (Indicator Dots & Button)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    // Dot Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _slides.length,
                        (idx) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentPage == idx ? 28 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == idx ? AppTheme.goldAccent : Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: _currentPage == idx
                                ? [
                                    BoxShadow(
                                      color: AppTheme.amberGold.withOpacity(0.5),
                                      blurRadius: 8,
                                    )
                                  ]
                                : [],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomGoldButton(
                        text: _currentPage == _slides.length - 1 ? 'GET STARTED NOW' : 'CONTINUE',
                        icon: _currentPage == _slides.length - 1 ? Icons.rocket_launch : Icons.arrow_forward,
                        onPressed: () {
                          if (_currentPage < _slides.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _onFinishOnboarding();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
