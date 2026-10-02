import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class CsrPartnerDashboardScreen extends StatefulWidget {
  const CsrPartnerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CsrPartnerDashboardScreen> createState() => _CsrPartnerDashboardScreenState();
}

class _CsrPartnerDashboardScreenState extends State<CsrPartnerDashboardScreen> with SingleTickerProviderStateMixin {
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

  void _showSubmitProposalDialog(BuildContext context, AppStateProvider state) {
    final titleController = TextEditingController();
    final partnerController = TextEditingController();
    final budgetController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppTheme.goldAccent)),
        title: const Text('Submit CSR Project Proposal', style: TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: partnerController,
                decoration: const InputDecoration(labelText: 'CSR Partner Name (e.g. Reliance Foundation)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Project Proposal Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Proposed Budget (₹)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && partnerController.text.isNotEmpty) {
                final newProp = {
                  'id': 'CSR-2026-00${state.csrProposals.length + 1}',
                  'partnerName': partnerController.text,
                  'projectTitle': titleController.text,
                  'budgetProposed': double.tryParse(budgetController.text) ?? 1000000.0,
                  'budgetApproved': 0,
                  'status': 'Under Review',
                  'submittedDate': DateTime.now().toString().split(' ')[0],
                  'approvalDate': null,
                  'milestones': [
                    {'phase': 'Phase 1', 'title': 'Project Scope & Feasibility Review', 'status': 'In Progress', 'percentage': 25},
                    {'phase': 'Phase 2', 'title': 'Fund Disbursal & Execution', 'status': 'Pending', 'percentage': 0}
                  ],
                  'utilization': [
                    {'category': 'Field Operations', 'allocated': (double.tryParse(budgetController.text) ?? 1000000.0) * 0.7, 'spent': 0},
                    {'category': 'Administration & Audits', 'allocated': (double.tryParse(budgetController.text) ?? 1000000.0) * 0.3, 'spent': 0}
                  ]
                };
                state.addCsrProposal(newProp);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CSR Proposal submitted successfully for evaluation.')),
                );
              }
            },
            child: const Text('Submit Proposal'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: const Text('CSR Partner Dashboard'),
        backgroundColor: AppTheme.primaryNavy,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.amberGold,
          labelColor: AppTheme.amberGold,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.description), text: 'Proposals'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Approved Budgets'),
            Tab(icon: Icon(Icons.flag), text: 'Milestones'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Utilization Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Proposals Tab
          _buildProposalsTab(context, state),
          // 2. Approved Budgets Tab
          _buildApprovedBudgetsTab(context, state),
          // 3. Milestones Tab
          _buildMilestonesTab(context, state),
          // 4. Utilization Reports Tab
          _buildUtilizationTab(context, state),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSubmitProposalDialog(context, state),
        backgroundColor: AppTheme.amberGold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('New CSR Proposal', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // 1. Proposals Tab
  Widget _buildProposalsTab(BuildContext context, AppStateProvider state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.csrProposals.length,
      itemBuilder: (context, idx) {
        final prop = state.csrProposals[idx];
        final status = prop['status'] ?? 'Under Review';
        final isApproved = status == 'Approved';

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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.goldAccent),
                      ),
                      child: Text(
                        prop['id'] ?? '',
                        style: const TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Chip(
                      backgroundColor: isApproved ? AppTheme.successGreen.withValues(alpha: 0.2) : Colors.amber.withValues(alpha: 0.2),
                      side: BorderSide(color: isApproved ? AppTheme.successGreen : Colors.amber),
                      label: Text(
                        status,
                        style: TextStyle(
                          color: isApproved ? AppTheme.successGreen : Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  prop['projectTitle'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Partner: ${prop['partnerName']}',
                  style: const TextStyle(color: AppTheme.amberGold, fontSize: 13),
                ),
                const Divider(color: Colors.white12, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Proposed Budget', style: TextStyle(color: Colors.white54, fontSize: 11)),
                        Text('₹${(prop['budgetProposed'] ?? 0).toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Approved Budget', style: TextStyle(color: Colors.white54, fontSize: 11)),
                        Text('₹${(prop['budgetApproved'] ?? 0).toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
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

  // 2. Approved Budgets Tab
  Widget _buildApprovedBudgetsTab(BuildContext context, AppStateProvider state) {
    double totalSanctioned = 0;
    state.csrProposals.forEach((p) => totalSanctioned += (p['budgetApproved'] ?? 0));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            color: AppTheme.cardNavy,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Total Sanctioned CSR Capital', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('₹${totalSanctioned.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.amberGold, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.72,
                    backgroundColor: Colors.white12,
                    color: AppTheme.goldAccent,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('72% Committed & Utilized', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      Text('28% Available Balance', style: TextStyle(color: AppTheme.successGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Corporate Partner Allocations', style: TextStyle(color: AppTheme.goldAccent, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...state.csrProposals.map((p) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.corporate_fare, color: AppTheme.amberGold),
              title: Text(p['partnerName'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(p['projectTitle'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              trailing: Text('₹${p['budgetApproved']}', style: const TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          )),
        ],
      ),
    );
  }

  // 3. Milestones Tab
  Widget _buildMilestonesTab(BuildContext context, AppStateProvider state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.csrProposals.length,
      itemBuilder: (context, idx) {
        final prop = state.csrProposals[idx];
        final milestones = prop['milestones'] as List? ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prop['projectTitle'] ?? '', style: const TextStyle(color: AppTheme.amberGold, fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Partner: ${prop['partnerName']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const Divider(color: Colors.white12, height: 20),
                ...milestones.map((m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        m['status'] == 'Completed' ? Icons.check_circle : (m['status'] == 'In Progress' ? Icons.timelapse : Icons.radio_button_unchecked),
                        color: m['status'] == 'Completed' ? AppTheme.successGreen : (m['status'] == 'In Progress' ? AppTheme.amberGold : Colors.white38),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${m['phase']}: ${m['title']}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: (m['percentage'] ?? 0) / 100,
                              backgroundColor: Colors.white10,
                              color: m['status'] == 'Completed' ? AppTheme.successGreen : AppTheme.amberGold,
                              minHeight: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${m['percentage']}%', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  // 4. Utilization Reports Tab
  Widget _buildUtilizationTab(BuildContext context, AppStateProvider state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.csrProposals.length,
      itemBuilder: (context, idx) {
        final prop = state.csrProposals[idx];
        final utilization = prop['utilization'] as List? ?? [];

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
                    Expanded(child: Text(prop['projectTitle'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Downloading official CSR utilization audit report for ${prop['id']}...')),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf, size: 16),
                      label: const Text('Export Report', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 20),
                ...utilization.map((u) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(u['category'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      Text('Spent: ₹${u['spent']} / ₹${u['allocated']}', style: const TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}
