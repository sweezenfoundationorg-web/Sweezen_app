import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
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
        return Container(
          height: MediaQuery.of(context).size.height * 0.82,
          padding: const EdgeInsets.all(20),
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

                Text(project.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.amberGold, size: 16),
                    const SizedBox(width: 4),
                    Text(project.location, style: const TextStyle(color: AppTheme.lightGold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),

                const Text('PROGRAM OBJECTIVES:', style: TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                ...project.objectives.map((obj) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: AppTheme.amberGold, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(obj, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),

                const Text('FINANCIAL UTILIZATION & RAISED:', style: TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppTheme.primaryNavy, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Funding Raised:', style: TextStyle(color: AppTheme.textMuted)),
                          Text('₹${project.fundingRaised}', style: const TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Funding Utilized:', style: TextStyle(color: AppTheme.textMuted)),
                          Text('₹${project.fundingUtilized}', style: const TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
                        ],
                      ),
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
}
