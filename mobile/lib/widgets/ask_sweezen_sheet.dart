import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String _selectedLanguage = 'en';

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'bot',
      'text': 'Hello! I am Sweezen AI Assistant. Ask me anything about our Foundation, 80G Tax Exemptions, Healthcare & Education programs, Volunteering, or Humanity Smart IDs!',
      'escalate': false
    }
  ];
  bool _isLoading = false;

  final Map<String, String> _languages = {
    'en': 'English (EN)',
    'hi': 'हिन्दी (Hindi)',
    'bn': 'বাংলা (Bengali)',
    'pa': 'ਪੰਜਾਬੀ (Punjabi)',
    'mr': 'मराठी (Marathi)',
    'gu': 'ગુજરાતી (Gujarati)',
    'ta': 'தமிழ் (Tamil)',
    'te': 'తెలుగు (Telugu)',
    'kn': 'ಕನ್ನಡ (Kannada)',
    'ml': 'മലയാളം (Malayalam)',
    'or': 'ଓଡ଼ିଆ (Odia)',
    'ur': 'اردو (Urdu)'
  };

  final Map<String, Map<String, String>> _chipQueries = {
    'en': {
      '🏛️ Mission & Vision': 'What is Sweezen Foundation mission and vision?',
      '📜 80G Tax Exemption': 'How do I claim 80G tax benefit on my donation?',
      '🏥 Healthcare Camps': 'Tell me about upcoming Healthcare & Medical camps',
      '📚 Education Programs': 'What Education and child welfare programs do you run?',
      '🤝 Volunteering': 'How can I become a volunteer and get field tasks?',
      '🪪 Humanity Smart ID': 'How does Humanity Smart ID card work?',
      '📞 Live Support': 'Connect me to a live support representative'
    },
    'hi': {
      '🏛️ मिशन और उद्देश्य': 'स्वीजन फाउंडेशन का मिशन और उद्देश्य क्या है?',
      '📜 80G टैक्स छूट': 'मैं अपने दान पर 80G टैक्स छूट कैसे प्राप्त कर सकता हूँ?',
      '🏥 स्वास्थ्य शिविर': 'आगामी मुफ्त स्वास्थ्य शिविरों के बारे में बताएं',
      '📚 शिक्षा कार्यक्रम': 'बच्चों के लिए शिक्षा और बाल कल्याण कार्यक्रम क्या हैं?',
      '🤝 स्वयंसेवा': 'मैं स्वयंसेवक कैसे बन सकता हूँ और कार्य प्राप्त कर सकता हूँ?',
      '🪪 ह्यूमैनिटी कार्ड': 'ह्यूमैनिटी स्मार्ट आईडी कार्ड कैसे काम करता है?',
      '📞 लाइव सहायता': 'मुझे लाइव सहायता प्रतिनिधि से जोड़ें'
    },
    'bn': {
      '🏛️ মিশন ও ভিশন': 'সুইজেন ফাউন্ডেশনের মিশন এবং ভিশন কী?',
      '📜 ৮০জি কর ছাড়': 'অনুদানে কীভাবে ৮০জি ট্যাক্স সুবিধা পাওয়া যাবে?',
      '🏥 স্বাস্থ্য শিবির': 'স্বাস্থ্য পরীক্ষার শিবির সম্পর্কে বিস্তারিত জানান',
      '📚 শিক্ষা কার্যক্রম': 'শিক্ষা এবং শিশু কল্যাণ প্রকল্পগুলি কী কী?',
      '🤝 স্বেচ্ছাসেবক': 'কীভাবে স্বেচ্ছাসেবক হিসেবে যোগ দেওয়া যাবে?',
      '🪪 স্মার্ট আইডি': 'হিউম্যানিটি স্মার্ট আইডি কীভাবে কাজ করে?',
      '📞 লাইভ সাপোর্ট': 'লাইভ সাপোর্ট প্রতিনিধির সাথে সংযোগ করুন'
    },
    'pa': {
      '🏛️ ਮਿਸ਼ਨ ਅਤੇ ਵਿਜ਼ਨ': 'ਸਵੀਜ਼ਨ ਫਾਊਂਡੇਸ਼ਨ ਦਾ ਮਿਸ਼ਨ ਕੀ ਹੈ?',
      '📜 80G ਟੈਕਸ ਛੋਟ': '80G ਟੈਕਸ ਛੋਟ ਕਿਵੇਂ ਪ੍ਰਾਪਤ ਕੀਤੀ ਜਾਵੇ?',
      '🏥 ਸਿਹਤ ਕੈਂਪ': 'ਮੁਫ਼ਤ ਮੈਡੀਕਲ ਕੈਂਪਾਂ ਬਾਰੇ ਜਾਣਕਾਰੀ ਦਿਓ',
      '📚 ਸਿੱਖਿਆ ਪ੍ਰੋਗਰਾਮ': 'ਸਿੱਖਿਆ ਅਤੇ ਬਾਲ ਭਲਾਈ ਪ੍ਰੋਗਰਾਮ ਕੀ ਹਨ?',
      '🤝 ਵਲੰਟੀਅਰਿੰਗ': 'ਮੈਂ ਵਲੰਟੀਅਰ ਕਿਵੇਂ ਬਣ ਸਕਦਾ ਹਾਂ?',
      '🪪 ਸਮਾਰਟ ਆਈਡੀ': 'ਹਿਊਮੈਨਿਟੀ ਸਮਾਰਟ ਆਈਡੀ ਕਾਰਡ ਕਿਵੇਂ ਕੰਮ ਕਰਦਾ ਹੈ?',
      '📞 ਲਾਈਵ ਸਪੋਰਟ': 'ਮੈਨੂੰ ਲਾਈਵ ਸਪੋਰਟ ਨਾਲ ਜੋੜੋ'
    }
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appLang = Provider.of<AppStateProvider>(context, listen: false).currentLanguage;
      if (_languages.containsKey(appLang)) {
        setState(() {
          _selectedLanguage = appLang;
        });
      }
    });
  }

  void _sendMessage(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': query, 'escalate': false});
      _isLoading = true;
    });
    _controller.clear();

    final response = await ApiService.askSweezenAi(query, _selectedLanguage);

    setState(() {
      _isLoading = false;
      _messages.add({
        'sender': 'bot',
        'text': response['answer'] ?? 'Thank you for reaching out to Sweezen Foundation. Our team is available 24/7.',
        'escalate': response['requires_escalation'] ?? false,
        'contact': response['escalation_contact'] ?? '+91 98765 43210'
      });
    });
  }

  void _openWhatsAppHelpline() async {
    final Uri url = Uri.parse('https://wa.me/919876543210?text=Hello%20Sweezen%20Support!%20I%20need%20assistance.');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final currentChips = _chipQueries[_selectedLanguage] ?? _chipQueries['en']!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: AppTheme.primaryNavy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.goldAccent, width: 1.5)),
      ),
      child: Column(
        children: [
          // Header with Language Selector
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sweezen AI Assistant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('24/7 Multi-Lingual Guidance (${_languages[_selectedLanguage]?.split(' ')[0]})', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                ),

                // 12-Language Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.4)),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    dropdownColor: AppTheme.cardNavy,
                    isDense: true,
                    style: const TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 11),
                    underline: const SizedBox(),
                    items: _languages.entries.map((e) {
                      return DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value, style: const TextStyle(fontSize: 11)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedLanguage = val;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.goldAccent, size: 20),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),

          // Upper Selection Chips (Topic Fill/Submit)
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: currentChips.entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: AppTheme.cardNavy,
                    side: BorderSide(color: AppTheme.goldAccent.withValues(alpha: 0.35)),
                    avatar: const Icon(Icons.auto_awesome, color: AppTheme.goldAccent, size: 13),
                    label: Text(
                      entry.key,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => _sendMessage(entry.value),
                  ),
                );
              }).toList(),
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
                final isEscalate = _messages[i]['escalate'] == true;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? AppTheme.amberGold : AppTheme.cardNavy,
                      borderRadius: BorderRadius.circular(16),
                      border: isUser ? null : Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _messages[i]['text']!,
                          style: TextStyle(
                            color: isUser ? Colors.black : Colors.white,
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: isUser ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (isEscalate) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              icon: const Icon(Icons.chat_bubble_outline, size: 16),
                              label: const Text('Connect via WhatsApp Helpline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              onPressed: _openWhatsAppHelpline,
                            ),
                          ),
                        ]
                      ],
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
                      hintText: 'Ask about 80G, Healthcare, Education...',
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
