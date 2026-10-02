import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class AiAnalyticsScreen extends StatefulWidget {
  const AiAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AiAnalyticsScreen> createState() => _AiAnalyticsScreenState();
}

class _AiAnalyticsScreenState extends State<AiAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.auto_awesome, color: AppTheme.amberGold),
            SizedBox(width: 8),
            Text('AI-assisted Analytics'),
          ],
        ),
        backgroundColor: AppTheme.primaryNavy,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.amberGold,
          labelColor: AppTheme.amberGold,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.summarize), text: 'Report Summaries'),
            Tab(icon: Icon(Icons.warning_amber), text: 'Data Anomalies'),
            Tab(icon: Icon(Icons.approval), text: 'Draft Impact Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Report Summaries
          _buildReportSummariesTab(context, state),
          // 2. Data Anomalies
          _buildDataAnomaliesTab(context, state),
          // 3. Draft Impact Reports
          _buildDraftImpactReportsTab(context, state),
        ],
      ),
    );
  }

  // 1. Report Summaries Tab
  Widget _buildReportSummariesTab(BuildContext context, AppStateProvider state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.aiReportSummaries.length,
      itemBuilder: (context, idx) {
        final item = state.aiReportSummaries[idx];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: AppTheme.amberGold, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item['topic'] ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 20),
                Text(
                  item['summaryText'] ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(Icons.verified, color: AppTheme.successGreen, size: 16),
                    SizedBox(width: 4),
                    Text('Verified by Ask Sweezen AI', style: TextStyle(color: AppTheme.successGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 2. Data Anomalies Tab
  Widget _buildDataAnomaliesTab(BuildContext context, AppStateProvider state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.aiAnomalies.length,
      itemBuilder: (context, idx) {
        final ano = state.aiAnomalies[idx];
        final severity = ano['severity'] ?? 'Medium';
        final isHigh = severity == 'High';

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
                    Chip(
                      backgroundColor: isHigh ? AppTheme.errorRed.withValues(alpha: 0.2) : Colors.amber.withValues(alpha: 0.2),
                      side: BorderSide(color: isHigh ? AppTheme.errorRed : Colors.amber),
                      label: Text(
                        '${ano['id']} • $severity Severity',
                        style: TextStyle(color: isHigh ? AppTheme.errorRed : Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Text(
                      ano['status'] ?? '',
                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Area: ${ano['area']}',
                  style: const TextStyle(color: AppTheme.amberGold, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  ano['description'] ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Anomaly ${ano['id']} resolved and marked clean.')),
                        );
                      },
                      child: const Text('Resolve / Dismiss', style: TextStyle(fontSize: 11)),
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

  // 3. Draft Impact Reports (Human-in-the-Loop Approval)
  Widget _buildDraftImpactReportsTab(BuildContext context, AppStateProvider state) {
    final report = state.aiDraftReport;
    final bool isApproved = report['isHumanApproved'] == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Notice
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardNavy,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.amberGold),
            ),
            child: Row(
              children: const [
                Icon(Icons.shield_outlined, color: AppTheme.amberGold, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Human-in-the-Loop Governance: AI generates draft impact reports which require explicit human review and approval before publication.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main Draft Report Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.primaryNavy, borderRadius: BorderRadius.circular(6)),
                        child: Text(report['id'] ?? '', style: const TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      Chip(
                        backgroundColor: isApproved ? AppTheme.successGreen.withValues(alpha: 0.2) : Colors.amber.withValues(alpha: 0.2),
                        side: BorderSide(color: isApproved ? AppTheme.successGreen : Colors.amber),
                        label: Text(
                          report['status'] ?? 'Pending Review',
                          style: TextStyle(color: isApproved ? AppTheme.successGreen : Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    report['title'] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Drafted by: ${report['author']}',
                    style: const TextStyle(color: AppTheme.amberGold, fontSize: 12),
                  ),
                  const Divider(color: Colors.white12, height: 24),

                  const Text('Executive Summary', style: TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(
                    report['executiveSummary'] ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),

                  const Text('AI Key Findings & Highlights', style: TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  ...(report['highlights'] as List? ?? []).map((h) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold, fontSize: 16)),
                        Expanded(child: Text(h.toString(), style: const TextStyle(color: Colors.white70, fontSize: 13))),
                      ],
                    ),
                  )),

                  const Divider(color: Colors.white12, height: 24),

                  // Human Approval Controller
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Human Reviewer Signature', style: TextStyle(color: Colors.white54, fontSize: 11)),
                          Text(
                            isApproved ? (report['approvedBy'] ?? 'Sheetal (Director)') : 'Not Approved Yet',
                            style: TextStyle(
                              color: isApproved ? AppTheme.successGreen : Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          state.toggleApproveDraftReport(approve: !isApproved);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                !isApproved
                                    ? 'Draft Impact Report Approved & Published to Sweezen Public Portal!'
                                    : 'Report Approval Status Reset.',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isApproved ? AppTheme.errorRed : AppTheme.successGreen,
                        ),
                        icon: Icon(isApproved ? Icons.cancel : Icons.check_circle),
                        label: Text(isApproved ? 'Revoke Approval' : 'Approve & Publish Report'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
