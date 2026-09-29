import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'custom_gold_button.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onDonateTap;
  final VoidCallback? onTap;

  const ProjectCard({
    Key? key,
    required this.project,
    required this.onDonateTap,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.cardNavy,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.goldAccent.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Image Banner with Category Badge
            Stack(
              children: [
                Image.network(
                  project.imageUrl,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) {
                    final cat = project.category.toLowerCase();
                    String assetPath = 'assets/images/onboarding_healthcare.png';
                    if (cat.contains('edu')) {
                      assetPath = 'assets/images/onboarding_education.png';
                    } else if (cat.contains('envir') || cat.contains('green')) {
                      assetPath = 'assets/images/onboarding_environment.png';
                    }
                    return Image.asset(
                      assetPath,
                      height: 170,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
                Container(
                  height: 170,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, AppTheme.primaryNavy.withOpacity(0.85)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.amberGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      project.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.goldAccent, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          project.location,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.people_outline, color: AppTheme.amberGold, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${project.beneficiaryCount} Beneficiaries',
                        style: const TextStyle(color: AppTheme.lightGold, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            ),

            // Card Body Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    project.description,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),

                  // Funding Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: project.progressPercentage,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.amberGold),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Funding Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('RAISED', style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text(
                            currencyFormatter.format(project.fundingRaised),
                            style: const TextStyle(color: AppTheme.amberGold, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('GOAL', style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text(
                            currencyFormatter.format(project.fundingGoal),
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomGoldButton(
                      text: 'DONATE TO THIS PROGRAM',
                      icon: Icons.favorite,
                      onPressed: onDonateTap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
