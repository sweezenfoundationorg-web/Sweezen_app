import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reports = [
      {'title': 'Sweezen Annual Impact Report 2025', 'type': 'PDF', 'size': '4.2 MB', 'year': '2025'},
      {'title': 'Financial Audited Statement 2024-25', 'type': 'PDF', 'size': '2.8 MB', 'year': '2025'},
      {'title': 'UN SDG Compliance & Audit Summary', 'type': 'PDF', 'size': '3.1 MB', 'year': '2024'},
      {'title': 'Rural Healthcare Outcomes Assessment', 'type': 'PDF', 'size': '1.9 MB', 'year': '2024'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Media Center')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        itemBuilder: (ctx, i) {
          final r = reports[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: AppTheme.cardNavy,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: AppTheme.goldAccent.withOpacity(0.3))),
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppTheme.amberGold, size: 30),
              title: Text(r['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('${r['year']} Audit • ${r['size']}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              trailing: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: AppTheme.goldAccent),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('VIEW', style: TextStyle(fontSize: 11)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Downloading ${r['title']}...'), backgroundColor: AppTheme.amberGold),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
