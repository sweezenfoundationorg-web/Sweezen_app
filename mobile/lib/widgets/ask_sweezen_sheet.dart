import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AskSweezenSheet extends StatefulWidget {
  const AskSweezenSheet({super.key});

  @override
  State<AskSweezenSheet> createState() => _AskSweezenSheetState();
}

class _AskSweezenSheetState extends State<AskSweezenSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'bot',
      'text': 'Hello! I am Sweezen AI Assistant. Ask me anything about our foundation, 80G tax exemptions, active healthcare/education programs, volunteering, or Humanity Smart IDs!'
    }
  ];
  bool _isLoading = false;

  final List<String> _quickSuggestions = [
    'How do I claim 80G tax benefit?',
    'Tell me about active healthcare camps',
    'How to scan Humanity Smart ID?',
    'How do field volunteers report tasks?'
  ];

  void _sendMessage(String query) async {
    if (query.trim().isEmpty) return;

    final lang = Provider.of<AppStateProvider>(context, listen: false).currentLanguage;

    setState(() {
      _messages.add({'sender': 'user', 'text': query});
      _isLoading = true;
    });
    _controller.clear();

    final response = await ApiService.askSweezenAi(query, lang);

    setState(() {
      _isLoading = false;
      _messages.add({
        'sender': 'bot',
        'text': response['answer'] ?? 'Thank you for reaching out to Sweezen Foundation. Our team is available 24/7 to support your inquiry.'
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppTheme.primaryNavy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.goldAccent, width: 1.5)),
      ),
      child: Column(
        children: [
          // Sheet Drag Handle & Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: AppTheme.cardNavy,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppTheme.amberGold, shape: BoxShape.circle),
                  child: const Icon(Icons.smart_toy, color: Colors.black, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Ask Sweezen AI Assistant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('24/7 Instant Support & Guidance', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.goldAccent),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),

          // Quick Suggestion Chips
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _quickSuggestions.length,
              itemBuilder: (ctx, i) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: AppTheme.cardNavy,
                    side: BorderSide(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
                    label: Text(
                      _quickSuggestions[i],
                      style: const TextStyle(color: AppTheme.lightGold, fontSize: 11),
                    ),
                    onPressed: () => _sendMessage(_quickSuggestions[i]),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white12, height: 1),

          // Chat Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final isUser = _messages[i]['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? AppTheme.amberGold : AppTheme.cardNavy,
                      borderRadius: BorderRadius.circular(16),
                      border: isUser ? null : Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _messages[i]['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.black : Colors.white,
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: isUser ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.amberGold),
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
                    controller: _controller,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Ask about 80G, projects, volunteering...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (val) => _sendMessage(val),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.amberGold),
                  onPressed: () => _sendMessage(_controller.text),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
