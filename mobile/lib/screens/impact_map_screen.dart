import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class ImpactMapScreen extends StatelessWidget {
  const ImpactMapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    final locations = [
      {'name': 'Ranchi & East Singhbhum', 'state': 'Jharkhand', 'program': 'Mobile Health Unit Clinics', 'lat': '23.3441° N', 'lng': '85.3096° E', 'beneficiaries': '14,200'},
      {'name': 'Dharavi & Thane Rural', 'state': 'Maharashtra', 'program': 'Shiksha Setu Digital Pods', 'lat': '19.0402° N', 'lng': '72.8508° E', 'beneficiaries': '8,500'},
      {'name': 'Uttarkashi & Haridwar', 'state': 'Uttarakhand', 'program': 'Green Canopy Tree Plantation', 'lat': '30.7268° N', 'lng': '78.4354° E', 'beneficiaries': '25,500'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Impact Map & Financial Transparency')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Visual Representation Container
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.cardNavy,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.goldAccent.withOpacity(0.5)),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?auto=format&fit=crop&w=800&q=80'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.map, color: AppTheme.amberGold, size: 48),
                    SizedBox(height: 8),
                    Text('GEO-TAGGED PROJECT IMPACT MAP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                    Text('3 Active States • 47 Camp Locations', style: TextStyle(color: AppTheme.lightGold, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('FINANCIAL TRANSPARENCY & UTILIZATION:', style: TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.cardNavy, borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  _buildUtilizationRow('Healthcare Programs', '84% Utilized', '₹850,000 / ₹1,120,000'),
                  _buildUtilizationRow('Education Pods', '71% Utilized', '₹1,200,000 / ₹1,680,000'),
                  _buildUtilizationRow('Environment Drives', '80% Utilized', '₹740,000 / ₹920,000'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('GEO-TAGGED SERVICE LOCATIONS:', style: TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 10),

            ...locations.map((loc) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                color: AppTheme.cardNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppTheme.goldAccent.withOpacity(0.3)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: AppTheme.amberGold),
                  title: Text(loc['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('${loc['program']} • ${loc['beneficiaries']} Beneficiaries', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  trailing: Text(loc['lat']!, style: const TextStyle(color: AppTheme.lightGold, fontSize: 11)),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilizationRow(String title, String status, String numbers) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(numbers, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ],
          ),
          Text(status, style: const TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
