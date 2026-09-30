import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_gold_button.dart';

class DigitalDocumentCentreScreen extends StatefulWidget {
  const DigitalDocumentCentreScreen({Key? key}) : super(key: key);

  @override
  State<DigitalDocumentCentreScreen> createState() => _DigitalDocumentCentreScreenState();
}

class _DigitalDocumentCentreScreenState extends State<DigitalDocumentCentreScreen> {
  String _selectedCategory = 'All';

  final List<Map<String, String>> _docs = [
    {
      'title': '80G Tax Exemption Receipt (₹5,000)',
      'category': 'Tax Receipt',
      'date': 'Aug 15, 2026',
      'size': '145 KB',
      'status': 'Verified 80G'
    },
    {
      'title': 'Volunteering Achievement Certificate (100+ Hours)',
      'category': 'Certificate',
      'date': 'Sep 01, 2026',
      'size': '320 KB',
      'status': 'Issued & Signed'
    },
    {
      'title': 'Audited Financial & Utilization Report Q3 2026',
      'category': 'Audit Report',
      'date': 'Sep 15, 2026',
      'size': '2.4 MB',
      'status': 'Audited & Published'
    },
    {
      'title': 'Humanity Smart ID Verification Pass',
      'category': 'Identity Proof',
      'date': 'Jul 10, 2026',
      'size': '98 KB',
      'status': 'Active ID'
    }
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _docs
        : _docs.where((d) => d['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        backgroundColor: AppTheme.cardNavy,
        elevation: 0,
        title: const Text('Digital Document Centre', style: TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Filter Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.cardNavy,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Tax Receipt', 'Certificate', 'Audit Report', 'Identity Proof'].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppTheme.amberGold,
                      backgroundColor: AppTheme.primaryNavy,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = cat);
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
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final doc = filtered[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardNavy,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.amberGold.withOpacity(0.4)),
                        ),
                        child: Icon(
                          doc['category'] == 'Tax Receipt'
                              ? Icons.receipt_long
                              : doc['category'] == 'Certificate'
                                  ? Icons.workspace_premium
                                  : doc['category'] == 'Audit Report'
                                      ? Icons.analytics
                                      : Icons.badge,
                          color: AppTheme.amberGold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc['title']!,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${doc['date']} • ${doc['size']} • ${doc['status']}',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download, color: AppTheme.goldAccent),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green.shade800,
                              content: Text('📥 Downloading ${doc['title']} PDF...'),
                            ),
                          );
                        },
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
