import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/document_upload_modal.dart';
import 'login_screen.dart';

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

            _buildSectionHeader('APP PREFERENCES & LANGUAGE'),
            ListTile(
              tileColor: AppTheme.cardNavy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.language, color: AppTheme.goldAccent),
              title: const Text('App Language', style: TextStyle(color: Colors.white, fontSize: 14)),
              trailing: DropdownButton<String>(
                value: state.currentLanguage,
                dropdownColor: AppTheme.cardNavy,
                style: const TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold),
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English (EN)')),
                  DropdownMenuItem(value: 'hi', child: Text('हिन्दी (HI)')),
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
}
