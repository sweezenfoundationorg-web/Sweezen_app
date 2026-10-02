import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class HospitalEducationPortalScreen extends StatefulWidget {
  const HospitalEducationPortalScreen({Key? key}) : super(key: key);

  @override
  State<HospitalEducationPortalScreen> createState() => _HospitalEducationPortalScreenState();
}

class _HospitalEducationPortalScreenState extends State<HospitalEducationPortalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showNewReferralDialog(BuildContext context, AppStateProvider state) {
    final nameController = TextEditingController();
    final needController = TextEditingController();
    String partnerName = state.portalPartners.isNotEmpty ? state.portalPartners.first['name'] : 'AIIMS Rishikesh';
    String refType = 'Medical Surgery';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppTheme.goldAccent)),
          title: const Text('Submit Beneficiary Referral', style: TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: partnerName,
                  dropdownColor: AppTheme.cardNavy,
                  decoration: const InputDecoration(labelText: 'Partner Institution'),
                  items: state.portalPartners.map((p) => DropdownMenuItem<String>(
                    value: p['name'].toString(),
                    child: Text(p['name'].toString(), style: const TextStyle(fontSize: 13)),
                  )).toList(),
                  onChanged: (val) => setDialogState(() => partnerName = val!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: refType,
                  dropdownColor: AppTheme.cardNavy,
                  decoration: const InputDecoration(labelText: 'Referral Type'),
                  items: const [
                    DropdownMenuItem(value: 'Medical Surgery', child: Text('Medical Surgery')),
                    DropdownMenuItem(value: 'Eye Care & Cataract', child: Text('Eye Care & Cataract')),
                    DropdownMenuItem(value: 'Education Scholarship', child: Text('Education Scholarship')),
                    DropdownMenuItem(value: 'Digital Learning Kit', child: Text('Digital Learning Kit')),
                  ],
                  onChanged: (val) => setDialogState(() => refType = val!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Patient / Student Full Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: needController,
                  decoration: const InputDecoration(labelText: 'Diagnosis or Educational Need'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && needController.text.isNotEmpty) {
                  final newRef = {
                    'id': 'REF-${Math.floor(1000 + (nameController.text.length * 99))}',
                    'partnerName': partnerName,
                    'type': refType,
                    'patientOrStudentName': nameController.text,
                    'diagnosisOrNeed': needController.text,
                    'status': 'Under Review',
                    'urgency': 'High',
                    'date': DateTime.now().toString().split(' ')[0]
                  };
                  state.addPortalReferral(newRef);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Referral submitted to Sweezen Partner Portal.')),
                  );
                }
              },
              child: const Text('Submit Referral'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewPartnerDialog(BuildContext context, AppStateProvider state) {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final phoneController = TextEditingController();
    String type = 'Hospital';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppTheme.goldAccent)),
          title: const Text('Register Partner Institution', style: TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: type,
                  dropdownColor: AppTheme.cardNavy,
                  decoration: const InputDecoration(labelText: 'Institution Type'),
                  items: const [
                    DropdownMenuItem(value: 'Hospital', child: Text('Hospital / Health Center')),
                    DropdownMenuItem(value: 'Education Institution', child: Text('School / College / Academy')),
                  ],
                  onChanged: (val) => setDialogState(() => type = val!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Institution Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: 'Contact Nodal Officer / Doctor'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && contactController.text.isNotEmpty) {
                  final newPartner = {
                    'id': state.portalPartners.length + 1,
                    'name': nameController.text,
                    'type': type,
                    'location': 'Haridwar, Uttarakhand',
                    'status': 'Verified',
                    'contactPerson': contactController.text,
                    'phone': phoneController.text.isNotEmpty ? phoneController.text : '+91-9876543210'
                  };
                  state.addPortalPartner(newPartner);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Institutional Partner registered successfully.')),
                  );
                }
              },
              child: const Text('Register Partner'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: const Text('Hospital & Education Portals'),
        backgroundColor: AppTheme.primaryNavy,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.amberGold,
          labelColor: AppTheme.amberGold,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.apartment), text: 'Partner Registrations'),
            Tab(icon: Icon(Icons.assignment_ind), text: 'Referrals'),
            Tab(icon: Icon(Icons.event_note), text: 'Camp Schedules'),
            Tab(icon: Icon(Icons.school), text: 'Student Progress'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Partner Registrations
          _buildPartnerRegistrationsTab(context, state),
          // 2. Referrals
          _buildReferralsTab(context, state),
          // 3. Camp Schedules
          _buildCampSchedulesTab(context, state),
          // 4. Student Progress
          _buildStudentProgressTab(context, state),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewReferralDialog(context, state),
        backgroundColor: AppTheme.amberGold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Submit Referral', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // 1. Partner Registrations Tab
  Widget _buildPartnerRegistrationsTab(BuildContext context, AppStateProvider state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Institutional Network', style: TextStyle(color: AppTheme.goldAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _showNewPartnerDialog(context, state),
              icon: const Icon(Icons.domain_add, size: 16),
              label: const Text('Register Partner', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...state.portalPartners.map((p) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: p['type'] == 'Hospital' ? Colors.red.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
              child: Icon(p['type'] == 'Hospital' ? Icons.local_hospital : Icons.school, color: p['type'] == 'Hospital' ? Colors.redAccent : Colors.lightBlueAccent),
            ),
            title: Text(p['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('${p['type']} • ${p['location']}\nContact: ${p['contactPerson']} (${p['phone']})', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            isThreeLine: true,
            trailing: Chip(
              backgroundColor: AppTheme.successGreen.withValues(alpha: 0.2),
              side: const BorderSide(color: AppTheme.successGreen),
              label: Text(p['status'] ?? 'Verified', style: const TextStyle(color: AppTheme.successGreen, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        )),
      ],
    );
  }

  // 2. Referrals Tab
  Widget _buildReferralsTab(BuildContext context, AppStateProvider state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.portalReferrals.length,
      itemBuilder: (context, idx) {
        final ref = state.portalReferrals[idx];
        final status = ref['status'] ?? 'Under Review';
        final isCompleted = status == 'Completed';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(ref['id'] ?? '', style: const TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                    Chip(
                      backgroundColor: isCompleted ? AppTheme.successGreen.withValues(alpha: 0.2) : Colors.amber.withValues(alpha: 0.2),
                      side: BorderSide(color: isCompleted ? AppTheme.successGreen : Colors.amber),
                      label: Text(status, style: TextStyle(color: isCompleted ? AppTheme.successGreen : Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(ref['patientOrStudentName'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Need: ${ref['diagnosisOrNeed']}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                Text('Referred By: ${ref['partnerName']} • Type: ${ref['type']}', style: const TextStyle(color: AppTheme.amberGold, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }

  // 3. Camp Schedules Tab
  Widget _buildCampSchedulesTab(BuildContext context, AppStateProvider state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.portalCamps.length,
      itemBuilder: (context, idx) {
        final camp = state.portalCamps[idx];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(camp['title'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.amberGold.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.amberGold)),
                      child: Text(camp['status'] ?? 'Upcoming', style: const TextStyle(color: AppTheme.amberGold, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.goldAccent, size: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text('${camp['facility']} (${camp['location']})', style: const TextStyle(color: Colors.white70, fontSize: 13))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: AppTheme.goldAccent, size: 16),
                    const SizedBox(width: 6),
                    Text('${camp['date']} | ${camp['time']}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
                const Divider(color: Colors.white12, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Registered: ${camp['registeredCount']} / ${camp['capacity']} slots', style: const TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Registered for ${camp['title']}! Notification sent to partner facility.')),
                        );
                      },
                      child: const Text('Book Slot / Join', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 4. Student Progress Tab
  Widget _buildStudentProgressTab(BuildContext context, AppStateProvider state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.portalStudentProgress.length,
      itemBuilder: (context, idx) {
        final stu = state.portalStudentProgress[idx];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppTheme.primaryNavy,
                          child: Icon(Icons.face, color: AppTheme.amberGold),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(stu['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('${stu['grade']} • ${stu['school']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    Text(stu['id'] ?? '', style: const TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const Divider(color: Colors.white12, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricCol('Attendance', stu['attendance'] ?? '', Colors.blueAccent),
                    _buildMetricCol('Academics', stu['academicScore'] ?? '', AppTheme.successGreen),
                    _buildMetricCol('Health Score', stu['healthScore'] ?? '', AppTheme.amberGold),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.primaryNavy, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.card_giftcard, color: AppTheme.goldAccent, size: 16),
                      const SizedBox(width: 8),
                      Text('Education Kit: ${stu['kitStatus']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCol(String title, String val, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
