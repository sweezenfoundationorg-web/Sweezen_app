import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../localization/app_localizations.dart';

class AccessibilityDialog extends StatelessWidget {
  const AccessibilityDialog({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AccessibilityDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final loc = AppLocalizations(state.currentLanguage);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.cardNavy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.goldAccent, width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.accessibility_new, color: AppTheme.amberGold, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    loc.translate('accessibility_title'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const Divider(color: Colors.white12, height: 24),

          // 1. Text Size Scale Controls
          Semantics(
            label: 'Adjustable text size scale control',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate('text_scale_title'),
                  style: const TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  'Current Scale: ${(state.textScaleFactor * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildScaleOption(context, state, 0.85, 'Small'),
                    _buildScaleOption(context, state, 1.0, 'Normal'),
                    _buildScaleOption(context, state, 1.15, 'Large'),
                    _buildScaleOption(context, state, 1.3, 'XL'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. High Contrast Mode
          Semantics(
            label: 'High contrast mode toggle switch',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: state.isHighContrast ? Colors.yellow : Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.contrast, color: AppTheme.amberGold, size: 26),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.translate('high_contrast_title'),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.translate('high_contrast_sub'),
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: state.isHighContrast,
                    activeColor: AppTheme.amberGold,
                    onChanged: (val) => state.toggleHighContrast(val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Screen Reader Labels & Simple Forms Info Badge
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.record_voice_over, color: AppTheme.goldAccent, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loc.translate('screen_reader_notice'),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildScaleOption(BuildContext context, AppStateProvider state, double scale, String label) {
    final isSelected = (state.textScaleFactor == scale);
    return InkWell(
      onTap: () => state.setTextScaleFactor(scale),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.amberGold : AppTheme.primaryNavy,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.white : AppTheme.goldAccent.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
