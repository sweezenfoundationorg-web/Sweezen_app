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
      {'name': 'Haridwar HealthCare Camp', 'state': 'Uttarakhand', 'program': 'HealthCare Camp', 'lat': '29.9600° N', 'lng': '78.2000° E', 'beneficiaries': '211 Lives Touched'},
      {'name': 'Haridwar Riverbanks', 'state': 'Uttarakhand', 'program': 'Environment Cleaning Camp', 'lat': '29.9457° N', 'lng': '78.1642° E', 'beneficiaries': '100+ Community Members'},
    ];

    final wallOfHonor = [
      {'name': 'Fareed Khan', 'amount': '₹14,200', 'donations': '3 Donations'},
      {'name': 'SHEETAL', 'amount': '₹100', 'donations': '1 Donation'},
      {'name': 'Kapil', 'amount': '₹10', 'donations': '1 Donation'},
      {'name': 'Dev', 'amount': '₹1', 'donations': '1 Donation'},
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
              height: 190,
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
                    Icon(Icons.map, color: AppTheme.amberGold, size: 44),
                    SizedBox(height: 8),
                    Text('GEO-TAGGED PROJECT IMPACT MAP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                    Text('12+ Districts Covered • 2 Active Projects', style: TextStyle(color: AppTheme.lightGold, fontSize: 12)),
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
                  _buildUtilizationRow('HealthCare Camp', 'Active Campaign', '₹14,311 Raised / ₹60,000 Target'),
                  const Divider(color: Colors.white12),
                  _buildUtilizationRow('Environment Cleaning Camp', 'Active Campaign', '₹0 Raised / Community Drive'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('WALL OF HONOR (CONTRIBUTORS):', style: TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.cardNavy, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.amberGold.withOpacity(0.3))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('TOTAL FUNDS RAISED:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('₹14,311 (₹0.14 Lakhs)', style: TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.w900, fontSize: 15)),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  ...wallOfHonor.map((d) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.favorite, color: AppTheme.amberGold, size: 14),
                            const SizedBox(width: 8),
                            Text(d['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                        Text('${d['amount']} (${d['donations']})', style: const TextStyle(color: AppTheme.lightGold, fontSize: 12)),
                      ],
                    ),
                  )),
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
                  subtitle: Text('${loc['program']} • ${loc['beneficiaries']}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
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
