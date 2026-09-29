import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/humanity_qr_dialog.dart';

class HumanityCardScreen extends StatelessWidget {
  const HumanityCardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final user = state.currentUser;

    final cardNumber = user?.humanityCardId ?? 'SWZ-CARD-8849';
    final name = user?.name ?? 'Sunita Devi';

    return Scaffold(
      appBar: AppBar(title: const Text('Humanity Smart ID & Service Point')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Humanity Workflow Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardNavy,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.goldAccent.withOpacity(0.4)),
              ),
              child: Column(
                children: const [
                  Text('HUMANITY SMART ID WORKFLOW', style: TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.0)),
                  SizedBox(height: 8),
                  Text(
                    'Village / Camp ➔ Smart ID Issued ➔ QR Scanned at Field Service Point ➔ Health/Education Service Captured ➔ Synchronized to Cloud Impact DB',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card Display
            Card(
              color: AppTheme.primaryNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppTheme.goldAccent.withOpacity(0.6), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/images/logo.png', height: 32, errorBuilder: (c, e, s) => const Icon(Icons.shield, color: AppTheme.amberGold)),
                        Text(cardNumber, style: const TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Icon(Icons.qr_code_2, color: Colors.white, size: 100),
                    const SizedBox(height: 16),
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                    const Text('Registered Rural Beneficiary', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amberGold, foregroundColor: Colors.black),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('OPEN SMART ID QR & SCAN SERVICE POINT', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => HumanityQrDialog(cardNumber: cardNumber, beneficiaryName: name),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
