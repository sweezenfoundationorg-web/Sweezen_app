import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../localization/app_localizations.dart';
import '../widgets/custom_gold_button.dart';
import '../widgets/project_card.dart';

class HomeTab extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeTab({Key? key, required this.onNavigateTab}) : super(key: key);

  void _launchUrl(String urlStr) async {
    final uri = Uri.parse(urlStr);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final loc = AppLocalizations(state.currentLanguage);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Campaign Banner Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppTheme.darkNavyGradient,
              border: Border(bottom: BorderSide(color: AppTheme.goldAccent.withOpacity(0.3))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.cardNavy,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.amberGold.withOpacity(0.4)),
                  ),
                  child: Text(
                    loc.translate('tagline'),
                    style: const TextStyle(color: AppTheme.amberGold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  loc.translate('hero_heading'),
                  style: TextStyle(
                    color: AppTheme.goldAccent,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    shadows: [
                      Shadow(color: AppTheme.amberGold.withOpacity(0.3), blurRadius: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  loc.translate('hero_sub'),
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: CustomGoldButton(
                        text: loc.translate('btn_donate_now'),
                        icon: Icons.favorite,
                        onPressed: () => onNavigateTab(2), // Navigate to Donate tab
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.shield_outlined, color: AppTheme.amberGold, size: 14),
                      SizedBox(width: 6),
                      Text(
                        '80G TAX BENEFIT AVAILABLE ON ALL DONATIONS',
                        style: TextStyle(color: AppTheme.lightGold, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Quick Statistics Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'REAL-TIME FOUNDATION IMPACT',
                  style: TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _buildStatCard(loc.translate('stat_beneficiaries'), state.impactMetrics['beneficiaries'] ?? '211+', Icons.groups),
                    _buildStatCard(loc.translate('stat_projects'), state.impactMetrics['total_projects'] ?? '2+', Icons.account_tree),
                    _buildStatCard(loc.translate('stat_volunteers'), state.impactMetrics['volunteers'] ?? '7+', Icons.volunteer_activism),
                    _buildStatCard(loc.translate('stat_districts'), state.impactMetrics['districts'] ?? '12+', Icons.location_city),
                  ],
                ),
              ],
            ),
          ),

          // 3. Featured Projects
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.translate('featured_projects'),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => onNavigateTab(1),
                  child: const Text('View All', style: TextStyle(color: AppTheme.amberGold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.projects.take(2).length,
              itemBuilder: (ctx, i) {
                return ProjectCard(
                  project: state.projects[i],
                  onDonateTap: () => onNavigateTab(2),
                );
              },
            ),
          ),

          // 4. Social Links & Footer
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardNavy,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text('CONNECT WITH SWEEZEN FOUNDATION', style: TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.language, color: Colors.white),
                      onPressed: () => _launchUrl('https://www.sweezenfoundation.org/'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () => _launchUrl('https://wa.me/919876543210'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.email, color: Colors.white),
                      onPressed: () => _launchUrl('mailto:info@sweezenfoundation.org'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('© 2026 Sweezen Foundation. All Rights Reserved.', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardNavy,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.amberGold, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.w900, fontSize: 17)),
                Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }
}
