import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class SweezenHeader extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const SweezenHeader({Key? key, this.scaffoldKey}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(65);

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
            children: [
              Text(
                'SWEEZEN',
                style: TextStyle(
                  color: AppTheme.goldAccent,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
              const Text(
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
        // Language Toggle Switcher (EN ↔ HI)
        Container(
          margin: const EdgeInsets.only(right: 6),
          child: TextButton.icon(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              backgroundColor: AppTheme.cardNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppTheme.goldAccent.withOpacity(0.4)),
              ),
            ),
            icon: const Icon(Icons.language, color: AppTheme.amberGold, size: 16),
            label: Text(
              state.currentLanguage == 'en' ? 'HI' : 'EN',
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            onPressed: () {
              final newLang = state.currentLanguage == 'en' ? 'hi' : 'en';
              state.toggleLanguage(newLang);
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
            side: BorderSide(color: AppTheme.goldAccent.withOpacity(0.5)),
          ),
          title: Row(
            children: const [
              Icon(Icons.notifications_active, color: AppTheme.amberGold),
              SizedBox(width: 10),
              Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 18)),
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
