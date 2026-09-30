import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_gold_button.dart';

class HealthCampsScreen extends StatefulWidget {
  const HealthCampsScreen({Key? key}) : super(key: key);

  @override
  State<HealthCampsScreen> createState() => _HealthCampsScreenState();
}

class _HealthCampsScreenState extends State<HealthCampsScreen> {
  String _selectedDistrict = 'All';

  final List<Map<String, dynamic>> _mockCamps = [
    {
      'id': 101,
      'title': 'Haridwar Multi-Specialty Free Health Camp',
      'district': 'Haridwar',
      'location': 'Community Centre, Kankhal, Haridwar',
      'date': 'Oct 15, 2026 • 09:00 AM',
      'doctor': 'Dr. R. K. Sharma (MD)',
      'services': ['General Checkup', 'Blood Sugar', 'Eye Testing', 'Free Medicines'],
      'capacity': 200,
      'booked': 42
    },
    {
      'id': 102,
      'title': 'Dehradun Rural Healthcare & Pediatrics Drive',
      'district': 'Dehradun',
      'location': 'Panchayat Bhavan, Vikasnagar, Dehradun',
      'date': 'Oct 20, 2026 • 10:00 AM',
      'doctor': 'Dr. Anita Verma (Pediatrician)',
      'services': ['Pediatric Care', 'Vaccination Drive', 'Nutritional Supplements'],
      'capacity': 150,
      'booked': 28
    },
    {
      'id': 103,
      'title': 'Rishikesh Free Eye & Cataract Screening Camp',
      'district': 'Dehradun',
      'location': 'Municipal Ground, Rishikesh',
      'date': 'Nov 02, 2026 • 08:30 AM',
      'doctor': 'Dr. S. P. Gupta (Ophthalmologist)',
      'services': ['Cataract Screening', 'Free Spectacles Distribution'],
      'capacity': 180,
      'booked': 89
    }
  ];

  void _showBookingDialog(Map<String, dynamic> camp) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.amberGold),
        ),
        title: Text(
          'Book Slot: ${camp['title']}',
          style: const TextStyle(color: AppTheme.goldAccent, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Beneficiary Name',
                labelStyle: TextStyle(color: AppTheme.textMuted),
                prefixIcon: Icon(Icons.person, color: AppTheme.amberGold),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Mobile Phone Number',
                labelStyle: TextStyle(color: AppTheme.textMuted),
                prefixIcon: Icon(Icons.phone, color: AppTheme.amberGold),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amberGold),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green.shade800,
                  content: Text('🎉 Slot Booked! QR Pass generated for ${nameCtrl.text.isNotEmpty ? nameCtrl.text : 'Beneficiary'}'),
                ),
              );
            },
            child: const Text('Confirm Booking', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCamps = _selectedDistrict == 'All'
        ? _mockCamps
        : _mockCamps.where((c) => c['district'] == _selectedDistrict).toList();

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        backgroundColor: AppTheme.cardNavy,
        elevation: 0,
        title: const Text('Nearby Health Camps', style: TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // District Filter Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.cardNavy,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Haridwar', 'Dehradun', 'Tehri Garhwal', 'Pauri Garhwal'].map((dist) {
                  final isSelected = _selectedDistrict == dist;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(dist),
                      selected: isSelected,
                      selectedColor: AppTheme.amberGold,
                      backgroundColor: AppTheme.primaryNavy,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedDistrict = dist);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredCamps.length,
              itemBuilder: (ctx, i) {
                final camp = filteredCamps[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardNavy,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.amberGold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.amberGold),
                            ),
                            child: Text(
                              camp['district'],
                              style: const TextStyle(color: AppTheme.amberGold, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.stars, color: AppTheme.goldAccent, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${camp['booked']}/${camp['capacity']} Slots Booked',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        camp['title'],
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppTheme.amberGold, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(camp['location'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppTheme.amberGold, size: 14),
                          const SizedBox(width: 4),
                          Text(camp['date'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: (camp['services'] as List<String>).map((srv) => Chip(
                          label: Text(srv, style: const TextStyle(fontSize: 10, color: Colors.white)),
                          backgroundColor: AppTheme.primaryNavy,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        )).toList(),
                      ),
                      const SizedBox(height: 14),
                      CustomGoldButton(
                        text: 'Book Free Consultation Slot',
                        icon: Icons.qr_code_2,
                        onPressed: () => _showBookingDialog(camp),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
