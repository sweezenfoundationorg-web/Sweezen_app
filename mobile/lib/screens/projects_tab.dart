import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_gold_button.dart';
import '../widgets/project_card.dart';

class ProjectsTab extends StatefulWidget {
  final Function(int) onNavigateTab;

  const ProjectsTab({Key? key, required this.onNavigateTab}) : super(key: key);

  @override
  State<ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<ProjectsTab> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = ['All', 'Healthcare', 'Education', 'Environment'];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    List<ProjectModel> filtered = state.projects;
    if (_selectedCategory != 'All') {
      filtered = filtered.where((p) => p.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()) || p.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return Scaffold(
      body: Column(
        children: [
          // Search & Category Chips Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.cardNavy,
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search healthcare, education, environment drives...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.goldAccent),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppTheme.textMuted),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 12),

                // Category Chips
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (ctx, i) {
                      final cat = _categories[i];
                      final isSelected = _selectedCategory == cat;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          selected: isSelected,
                          label: Text(cat),
                          selectedColor: AppTheme.amberGold,
                          backgroundColor: AppTheme.primaryNavy,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = cat);
                              state.loadProjects(category: cat);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Project List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('No programs match your search query.', style: TextStyle(color: AppTheme.textMuted)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final p = filtered[i];
                      return ProjectCard(
                        project: p,
                        onDonateTap: () => widget.onNavigateTab(2),
                        onTap: () => _showProjectDetailModal(context, p),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showProjectDetailModal(BuildContext context, ProjectModel project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardNavy,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final double budgetLakhs = project.fundingGoal / 100000.0;
        final double raisedLakhs = project.fundingRaised / 100000.0;
        final int toGoPct = project.fundingGoal > 0 ? (100 - (project.progressPercentage * 100)).toInt() : 100;

        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),

                // Program Title & Category
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.amberGold, borderRadius: BorderRadius.circular(12)),
                      child: Text(project.category.toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        project.name,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 3 Detail Cards (Problem, Solution, Impact)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Problem Box
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFB3C1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('THE PROBLEM', style: TextStyle(color: Color(0xFFC9184A), fontWeight: FontWeight.bold, fontSize: 10)),
                            const SizedBox(height: 6),
                            Text(
                              'Limited access to ${project.category.toLowerCase()} services in rural communities.',
                              style: const TextStyle(color: Color(0xFF590D22), fontSize: 11, height: 1.2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Solution Box
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('OUR SOLUTION', style: TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.bold, fontSize: 10)),
                            const SizedBox(height: 6),
                            Text(
                              '${project.description} We implement evidence-based interventions.',
                              style: const TextStyle(color: Color(0xFF78350F), fontSize: 11, height: 1.2),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Impact Box
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('MEASURABLE IMPACT', style: TextStyle(color: Color(0xFF047857), fontWeight: FontWeight.bold, fontSize: 10)),
                            const SizedBox(height: 6),
                            Text(
                              '${project.beneficiaryCount} beneficiaries empowered with real-time tracking.',
                              style: const TextStyle(color: Color(0xFF064E3B), fontSize: 11, height: 1.2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Description
                Text(project.description, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                const SizedBox(height: 18),

                // 4 Metric Stats Grid
                Row(
                  children: [
                    _buildMetricStat('₹${budgetLakhs.toStringAsFixed(1)}L', 'Budget', AppTheme.goldAccent),
                    const SizedBox(width: 8),
                    _buildMetricStat('₹${raisedLakhs.toStringAsFixed(1)}L', 'Raised', const Color(0xFFFF4D6D)),
                    const SizedBox(width: 8),
                    _buildMetricStat('$toGoPct%', 'To Go', AppTheme.successGreen),
                    const SizedBox(width: 8),
                    _buildMetricStat('${project.beneficiaryCount}', 'Beneficiaries', Colors.white),
                  ],
                ),
                const SizedBox(height: 20),

                // Funding Progress
                const Text('FUNDING PROGRESS', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold, fontSize: 11)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: project.progressPercentage,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.amberGold),
                          minHeight: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${(project.progressPercentage * 100).toInt()}%', style: const TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 24),

                // Donate Button
                SizedBox(
                  width: double.infinity,
                  child: CustomGoldButton(
                    text: 'DONATE TO THIS PROJECT',
                    icon: Icons.favorite,
                    onPressed: () {
                      Navigator.pop(ctx);
                      widget.onNavigateTab(2);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryNavy,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
