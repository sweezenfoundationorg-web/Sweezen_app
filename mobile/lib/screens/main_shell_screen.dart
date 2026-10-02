import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../localization/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/sweezen_header.dart';
import '../widgets/ask_sweezen_sheet.dart';
import 'home_tab.dart';
import 'projects_tab.dart';
import 'donate_tab.dart';
import 'volunteer_tab.dart';
import 'profile_tab.dart';
import 'events_screen.dart';
import 'humanity_card_screen.dart';
import 'impact_map_screen.dart';
import 'communication_screen.dart';
import 'reports_screen.dart';
import 'login_screen.dart';
import 'csr_partner_dashboard_screen.dart';
import 'hospital_education_portal_screen.dart';
import 'ai_analytics_screen.dart';
import '../widgets/accessibility_dialog.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({Key? key}) : super(key: key);

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openAiChatbot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AskSweezenSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final loc = AppLocalizations(state.currentLanguage);

    final List<Widget> tabs = [
      HomeTab(onNavigateTab: _onTabTapped),
      ProjectsTab(onNavigateTab: _onTabTapped),
      const DonateTab(),
      const VolunteerTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: SweezenHeader(scaffoldKey: _scaffoldKey),
      drawer: Drawer(
        backgroundColor: AppTheme.primaryNavy,
        child: Column(
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.cardNavy),
              child: Row(
                children: [
                  Image.asset('assets/images/logo.png', height: 48, errorBuilder: (c, e, s) => const Icon(Icons.shield, color: AppTheme.amberGold, size: 40)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('SWEEZEN', style: TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
                        Text('FOUNDATION', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Drawer Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(Icons.corporate_fare, loc.translate('csr_dashboard'), () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CsrPartnerDashboardScreen()));
                  }, isGold: true),
                  _buildDrawerItem(Icons.local_hospital, loc.translate('hospital_education_portal'), () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HospitalEducationPortalScreen()));
                  }, isGold: true),
                  _buildDrawerItem(Icons.auto_awesome, loc.translate('ai_analytics'), () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAnalyticsScreen()));
                  }, isGold: true),
                  _buildDrawerItem(Icons.accessibility_new, loc.translate('accessibility_settings'), () {
                    Navigator.pop(context);
                    AccessibilityDialog.show(context);
                  }),
                  const Divider(color: Colors.white12),
                  _buildDrawerItem(Icons.event, loc.translate('drawer_events'), () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EventsScreen()));
                  }),
                  _buildDrawerItem(Icons.qr_code_2, loc.translate('humanity_card'), () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HumanityCardScreen()));
                  }),
                  _buildDrawerItem(Icons.map, loc.translate('drawer_impact_map'), () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ImpactMapScreen()));
                  }),
                  _buildDrawerItem(Icons.campaign, loc.translate('drawer_communication'), () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunicationScreen()));
                  }),
                  _buildDrawerItem(Icons.picture_as_pdf, loc.translate('drawer_reports'), () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
                  }),
                  const Divider(color: Colors.white12),

                  _buildDrawerItem(Icons.smart_toy, loc.translate('ask_sweezen'), () {
                    Navigator.pop(context);
                    _openAiChatbot();
                  }, isGold: true),
                ],
              ),
            ),

            const Spacer(),
            _buildDrawerItem(Icons.logout, loc.translate('drawer_logout'), () {
              state.logoutUser();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),

      // Floating AI Chatbot Action Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.amberGold,
        foregroundColor: Colors.black,
        elevation: 6,
        icon: const Icon(Icons.smart_toy),
        label: Text(loc.translate('ask_sweezen'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        onPressed: _openAiChatbot,
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: loc.translate('nav_home')),
          BottomNavigationBarItem(icon: const Icon(Icons.account_tree), label: loc.translate('nav_projects')),
          BottomNavigationBarItem(icon: const Icon(Icons.favorite), label: loc.translate('nav_donate')),
          BottomNavigationBarItem(icon: const Icon(Icons.volunteer_activism), label: loc.translate('nav_volunteer')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: loc.translate('nav_profile')),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {bool isGold = false}) {
    return ListTile(
      leading: Icon(icon, color: isGold ? AppTheme.amberGold : AppTheme.goldAccent),
      title: Text(
        title,
        style: TextStyle(
          color: isGold ? AppTheme.amberGold : Colors.white,
          fontWeight: isGold ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
}
