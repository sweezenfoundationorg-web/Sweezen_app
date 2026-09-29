import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'custom_gold_button.dart';

class HumanityQrDialog extends StatefulWidget {
  final String cardNumber;
  final String beneficiaryName;

  const HumanityQrDialog({
    Key? key,
    required this.cardNumber,
    required this.beneficiaryName,
  }) : super(key: key);

  @override
  State<HumanityQrDialog> createState() => _HumanityQrDialogState();
}

class _HumanityQrDialogState extends State<HumanityQrDialog> {
  String _selectedService = 'Health Service';
  bool _isLogging = false;

  void _logServiceAtCamp() async {
    setState(() => _isLogging = true);

    final res = await ApiService.logHumanityCardService(
      cardNumber: widget.cardNumber,
      serviceType: _selectedService,
      location: 'Camp 4 Distribution Center',
      notes: 'Logged by field volunteer scanner.',
    );

    setState(() => _isLogging = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Service logged to Cloud DB!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrData = 'SWEEZEN:CARD:${widget.cardNumber}:${widget.beneficiaryName}';

    return Dialog(
      backgroundColor: AppTheme.cardNavy,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.goldAccent.withOpacity(0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.qr_code_2, color: AppTheme.amberGold, size: 26),
                      SizedBox(width: 8),
                      Text('Humanity Smart ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const Divider(color: Colors.white12),
              const SizedBox(height: 10),

              // Smart Card UI Display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.darkNavyGradient,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.goldAccent.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10)
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('HUMANITY CARD', style: TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                        Text(widget.cardNumber, style: const TextStyle(color: AppTheme.lightGold, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // QR Code rendering
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 140.0,
                        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(widget.beneficiaryName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text('Registered Community Member', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Field Volunteer Service Point Scan Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('VOLUNTEER SERVICE SCAN POINT:', style: TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _selectedService,
                dropdownColor: AppTheme.cardNavy,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Select Service Provided',
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                items: const [
                  DropdownMenuItem(value: 'Health Service', child: Text('Health Consultation / Camp')),
                  DropdownMenuItem(value: 'Education Kit', child: Text('Education Kit / Smart Pod')),
                  DropdownMenuItem(value: 'Ration & Food', child: Text('Ration / Food Pack')),
                  DropdownMenuItem(value: 'Emergency Shelter', child: Text('Emergency Shelter Access')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedService = val);
                },
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: CustomGoldButton(
                  text: _isLogging ? 'LOGGING TO CLOUD...' : 'SCAN & RECORD SERVICE',
                  icon: Icons.cloud_upload,
                  onPressed: _logServiceAtCamp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
