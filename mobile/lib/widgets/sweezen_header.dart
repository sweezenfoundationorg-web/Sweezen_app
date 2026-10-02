import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import 'accessibility_dialog.dart';

class SweezenHeader extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const SweezenHeader({Key? key, this.scaffoldKey}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(65);

  static const Map<String, String> _languagesMap = {
    'en': 'English',
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

  void _showLanguagePickerModal(BuildContext context, AppStateProvider state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.amberGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.language, color: AppTheme.amberGold, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Select App Language (12 Languages)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  itemCount: _languagesMap.length,
                  separatorBuilder: (c, i) => const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (c, i) {
                    final code = _languagesMap.keys.elementAt(i);
                    final name = _languagesMap.values.elementAt(i);
                    final isSelected = state.currentLanguage == code;

                    return ListTile(
                      dense: true,
                      title: Text(
                        name,
                        style: TextStyle(
                          color: isSelected ? AppTheme.goldAccent : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppTheme.amberGold, size: 20)
                          : const Icon(Icons.radio_button_unchecked, color: Colors.white30, size: 18),
                      onTap: () {
                        state.toggleLanguage(code);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return AppBar(
      backgroundColor: AppTheme.primaryNavy,
      elevation: 4,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppTheme.goldAccent, size: 26),
        onPressed: () {
          if (scaffoldKey != null && scaffoldKey!.currentState != null) {
            scaffoldKey!.currentState!.openDrawer();
          } else {
            Scaffold.of(context).openDrawer();
          }
        },
      ),
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, stack) {
              return const Icon(Icons.shield, color: AppTheme.goldAccent, size: 32);
            },
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'SWEEZEN',
                style: TextStyle(
                  color: AppTheme.goldAccent,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'FOUNDATION',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Accessibility Quick Toggle Button
        IconButton(
          tooltip: 'Accessibility & Font Scale',
          icon: const Icon(Icons.accessibility_new, color: AppTheme.amberGold, size: 22),
          onPressed: () {
            AccessibilityDialog.show(context);
          },
        ),

        // 12-Language Selector Button in Header
        Container(
          margin: const EdgeInsets.only(right: 6),
          child: TextButton.icon(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              backgroundColor: AppTheme.cardNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppTheme.goldAccent.withValues(alpha: 0.4)),
              ),
            ),
            icon: const Icon(Icons.language, color: AppTheme.amberGold, size: 16),
            label: Text(
              state.currentLanguage.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            onPressed: () {
              _showLanguagePickerModal(context, state);
            },
          ),
        ),

        // Notifications Bell Icon
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppTheme.goldAccent, size: 24),
              onPressed: () {
                _showNotificationsDialog(context, state);
              },
            ),
            if (state.notifications.isNotEmpty)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.errorRed,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${state.notifications.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              )
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  void _showNotificationsDialog(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppTheme.goldAccent.withValues(alpha: 0.5)),
          ),
          title: const Row(
            children: [
              Icon(Icons.notifications_active, color: AppTheme.amberGold),
              SizedBox(width: 10),
              Text('Smart Notifications', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: state.notifications.length,
              separatorBuilder: (c, i) => const Divider(color: Colors.white12),
              itemBuilder: (c, i) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline, color: AppTheme.goldAccent, size: 20),
                  title: Text(
                    state.notifications[i],
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CLOSE', style: TextStyle(color: AppTheme.amberGold)),
            )
          ],
        );
      },
    );
  }
}
