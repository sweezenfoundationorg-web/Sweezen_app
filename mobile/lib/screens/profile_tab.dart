import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/app_state_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/document_upload_modal.dart';
import '../widgets/accessibility_dialog.dart';
import 'login_screen.dart';
import 'csr_partner_dashboard_screen.dart';
import 'hospital_education_portal_screen.dart';
import 'ai_analytics_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final List<Map<String, String>> _uploadedUserDocs = [
    {
      'title': 'Government ID Proof (Aadhaar)',
      'status': 'Approved & Verified',
      'fileName': 'aadhaar_card_sheetal.pdf',
    },
    {
      'title': 'Volunteer Training Cert',
      'status': 'Completed Level 1',
      'fileName': 'volunteer_cert_lvl1.pdf',
    },
  ];

  void _handleUploadNewDoc() async {
    final result = await DocumentUploadModal.show(context);
    if (!mounted) return;
    if (result != null) {
      setState(() {
        _uploadedUserDocs.add({
          'title': result.docType,
          'status': 'Verified (${result.uploadDate})',
          'fileName': result.fileName,
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.fileName} uploaded successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final user = state.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
            child: const Text('Login / Register'),
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Card Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardNavy,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.goldAccent.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.amberGold,
                    backgroundImage: NetworkImage(user.profilePhoto),
                  ),
                  const SizedBox(height: 12),
                  Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  Text(user.email, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.amberGold,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(user.role.toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Information List
            _buildSectionHeader('PERSONAL & ACCOUNT INFORMATION'),
            _buildInfoTile('Phone Number', user.phone, Icons.phone),
            _buildInfoTile('Primary Location', user.location, Icons.location_on),
            _buildInfoTile('Availability Schedule', user.availability, Icons.event_available),
            _buildInfoTile('Humanity Smart ID', user.humanityCardId, Icons.qr_code),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('VERIFIED DOCUMENTS'),
                GestureDetector(
                  onTap: _handleUploadNewDoc,
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, color: AppTheme.amberGold, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'UPLOAD NEW',
                          style: TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ..._uploadedUserDocs.map((doc) {
              return _buildDocTile(
                doc['title']!,
                doc['status']!,
                doc['fileName']!,
                Icons.verified_user,
              );
            }).toList(),
            const SizedBox(height: 20),

            _buildSectionHeader('SECURITY & APP LOCK'),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.cardNavy,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.goldAccent.withOpacity(0.2)),
              ),
              child: SwitchListTile(
                secondary: const Icon(Icons.fingerprint, color: AppTheme.goldAccent, size: 24),
                title: const Text('Fingerprint App Lock', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Lock app locally using biometric fingerprint / PIN', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                activeColor: AppTheme.goldAccent,
                value: state.isAppLockEnabled,
                onChanged: (val) async {
                  final success = await state.toggleAppLock(val);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.cardNavy,
                        content: Text(
                          val ? '🔒 Fingerprint App Lock Enabled' : '🔓 Fingerprint App Lock Disabled',
                          style: const TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardNavy,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.goldAccent.withOpacity(0.2)),
              ),
              child: ListTile(
                leading: const Icon(Icons.security, color: AppTheme.goldAccent, size: 22),
                title: const Text('Google 2FA Authenticator', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Bind 2FA TOTP QR code for account login', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.amberGold, size: 14),
                onTap: () => _showGoogle2FASetupModal(context, user.email),
              ),
            ),
            const SizedBox(height: 12),

            _buildSectionHeader('ACCESSIBILITY & ENTERPRISE PORTALS'),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.cardNavy,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.amberGold.withValues(alpha: 0.3)),
              ),
              child: ListTile(
                leading: const Icon(Icons.accessibility_new, color: AppTheme.amberGold, size: 22),
                title: const Text('Accessibility & Text Scaling', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Adjust text size scale, contrast & screen reader options', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.amberGold, size: 14),
                onTap: () => AccessibilityDialog.show(context),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.cardNavy,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.2)),
              ),
              child: ListTile(
                leading: const Icon(Icons.corporate_fare, color: AppTheme.goldAccent, size: 22),
                title: const Text('CSR Partner Dashboard', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Proposals, approved budgets, milestones & utilization', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.amberGold, size: 14),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CsrPartnerDashboardScreen())),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.cardNavy,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.2)),
              ),
              child: ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.lightBlueAccent, size: 22),
                title: const Text('Hospital & Education Portals', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Partner registrations, referrals, camps & student progress', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.amberGold, size: 14),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HospitalEducationPortalScreen())),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardNavy,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.2)),
              ),
              child: ListTile(
                leading: const Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 22),
                title: const Text('AI-assisted Analytics', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text('Report summaries, anomalies & draft impact approval', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.amberGold, size: 14),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAnalyticsScreen())),
              ),
            ),
            const SizedBox(height: 12),

            _buildSectionHeader('APP PREFERENCES & LANGUAGE'),
            ListTile(
              tileColor: AppTheme.cardNavy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.language, color: AppTheme.goldAccent),
              title: const Text('App Language', style: TextStyle(color: Colors.white, fontSize: 14)),
              trailing: DropdownButton<String>(
                value: state.currentLanguage,
                dropdownColor: AppTheme.cardNavy,
                style: const TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold, fontSize: 12),
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'hi', child: Text('हिन्दी (Hindi)')),
                  DropdownMenuItem(value: 'bn', child: Text('বাংলা (Bengali)')),
                  DropdownMenuItem(value: 'pa', child: Text('ਪੰਜਾਬੀ (Punjabi)')),
                  DropdownMenuItem(value: 'mr', child: Text('मराठी (Marathi)')),
                  DropdownMenuItem(value: 'gu', child: Text('ગુજરાતી (Gujarati)')),
                  DropdownMenuItem(value: 'ta', child: Text('தமிழ் (Tamil)')),
                  DropdownMenuItem(value: 'te', child: Text('తెలుగు (Telugu)')),
                  DropdownMenuItem(value: 'kn', child: Text('ಕನ್ನಡ (Kannada)')),
                  DropdownMenuItem(value: 'ml', child: Text('മലയാളം (Malayalam)')),
                  DropdownMenuItem(value: 'or', child: Text('ଓଡ଼ିଆ (Odia)')),
                  DropdownMenuItem(value: 'ur', child: Text('اردو (Urdu)')),
                ],
                onChanged: (val) {
                  if (val != null) state.toggleLanguage(val);
                },
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('LOGOUT ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  state.logoutUser();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, {bool isVerified = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.goldAccent.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.amberGold, size: 20),
        title: Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        subtitle: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        trailing: isVerified ? const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 18) : null,
      ),
    );
  }

  Widget _buildDocTile(String title, String status, String fileName, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.goldAccent.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.amberGold, size: 20),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text('File: $fileName • $status', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        trailing: const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 18),
      ),
    );
  }

  void _showGoogle2FASetupModal(BuildContext context, String userEmail) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: AppTheme.goldAccent),
      ),
    );

    final res = await ApiService.setup2FA(userEmail);
    if (!mounted) return;
    Navigator.of(context).pop(); // Close loader

    final secret = res['secret'] ?? 'JBSWY3DPEHPK3PXP';
    final otpauthUrl = res['otpauth_url'] ?? 'otpauth://totp/Sweezen:$userEmail?secret=$secret&issuer=Sweezen';

    final codeController = TextEditingController(text: '123456');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppTheme.primaryNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.goldAccent, width: 1.5),
          ),
          title: const Text(
            '📱 Bind Google Authenticator 2FA',
            style: TextStyle(color: AppTheme.goldAccent, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Scan this QR code using Google Authenticator or Authy app on your mobile device:',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: otpauthUrl,
                    version: QrVersions.auto,
                    size: 180.0,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardNavy,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Secret Key: ', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      SelectableText(
                        secret,
                        style: const TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4),
                  decoration: InputDecoration(
                    hintText: 'Enter 6-digit TOTP',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13, letterSpacing: 1),
                    filled: true,
                    fillColor: AppTheme.cardNavy,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.goldAccent)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.amberGold)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldAccent),
              onPressed: () async {
                final verifyRes = await ApiService.verify2FA(codeController.text, secret);
                if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: verifyRes['success'] == true ? AppTheme.cardNavy : AppTheme.errorRed,
                      content: Text(
                        verifyRes['message'] ?? '2FA Verified',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
              },
              child: const Text('VERIFY & BIND 2FA', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
