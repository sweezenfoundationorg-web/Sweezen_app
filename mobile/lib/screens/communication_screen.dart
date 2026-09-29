import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({Key? key}) : super(key: key);

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, String>> _groupChat = [
    {'sender': 'Aarav Sharma', 'text': 'Mobile clinic vehicle arrives at Camp 4 tomorrow at 9 AM!', 'time': '10:30 AM'},
    {'sender': 'Priya Verma', 'text': 'Funded 500 additional health kits for this drive!', 'time': '11:15 AM'},
  ];

  void _sendGroupMessage() {
    if (_msgController.text.trim().isEmpty) return;
    setState(() {
      _groupChat.add({
        'sender': 'Aarav Sharma (Volunteer)',
        'text': _msgController.text.trim(),
        'time': 'Just now'
      });
      _msgController.clear();
    });
  }

  void _launchWhatsApp() async {
    final res = await ApiService.getWhatsAppLink();
    final url = res['whatsapp_url'] ?? 'https://wa.me/919876543210';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Communication Center'),
          bottom: const TabBar(
            indicatorColor: AppTheme.amberGold,
            labelColor: AppTheme.amberGold,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: 'Announcements', icon: Icon(Icons.campaign)),
              Tab(text: 'Project Group Chat', icon: Icon(Icons.forum)),
            ],
          ),
        ),
        body: Column(
          children: [
            // WhatsApp Direct Connect Banner
            Container(
              color: AppTheme.cardNavy,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, color: AppTheme.successGreen),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Official WhatsApp Business Helpline', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen, foregroundColor: Colors.white),
                    icon: const Icon(Icons.send, size: 14),
                    label: const Text('OPEN WHATSAPP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: _launchWhatsApp,
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Administrative Announcements
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildAnnouncementCard(
                        'Sweezen Foundation receives UN SDG Special Recognition!',
                        'We are proud to announce our recognition for excellence in rural health outreach and digital literacy integration.',
                        'Oct 24, 2026',
                        'Achievement',
                      ),
                      _buildAnnouncementCard(
                        'Urgent Monsoon Relief Drive launched in Jharkhand',
                        'Field volunteers are requested to mobilize flood emergency shelters and medical kits in affected districts.',
                        'Oct 20, 2026',
                        'Urgent',
                      ),
                    ],
                  ),

                  // Tab 2: Project Group Chat
                  Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _groupChat.length,
                          itemBuilder: (ctx, i) {
                            final m = _groupChat[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.cardNavy,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(m['sender']!, style: const TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold, fontSize: 12)),
                                      Text(m['time']!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(m['text']!, style: const TextStyle(color: Colors.white, fontSize: 13)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Input Bar
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: AppTheme.cardNavy,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _msgController,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: const InputDecoration(hintText: 'Type project team message...'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.send, color: AppTheme.amberGold),
                              onPressed: _sendGroupMessage,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(String title, String body, String date, String tag) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: AppTheme.cardNavy,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: AppTheme.goldAccent.withOpacity(0.3))),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppTheme.amberGold, borderRadius: BorderRadius.circular(10)),
                  child: Text(tag.toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 9)),
                ),
                Text(date, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(body, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
