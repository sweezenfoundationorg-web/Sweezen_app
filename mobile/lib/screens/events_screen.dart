import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Events & Conclaves')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.events.length,
        itemBuilder: (ctx, i) {
          final e = state.events[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: AppTheme.cardNavy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppTheme.goldAccent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  e.bannerUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, err, s) => Container(height: 150, color: AppTheme.surfaceElevated),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.category.toUpperCase(), style: const TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold, fontSize: 10)),
                      const SizedBox(height: 4),
                      Text(e.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 6),
                      Text(e.description, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppTheme.goldAccent, size: 16),
                          const SizedBox(width: 4),
                          Expanded(child: Text(e.location, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                        ],
                      ),
                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amberGold, foregroundColor: Colors.black),
                          icon: const Icon(Icons.event_available),
                          label: const Text('REGISTER & GET PARTICIPATION CERTIFICATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          onPressed: () {
                            state.registerForEvent(e.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Registered successfully! Digital certificate saved in your profile.'), backgroundColor: AppTheme.successGreen),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
