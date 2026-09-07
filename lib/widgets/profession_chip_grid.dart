import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme_constants.dart';
import '../models/profession.dart';
import '../providers/inspector_provider.dart';
import 'custom_profession_dialog.dart';

class ProfessionChipGrid extends StatelessWidget {
  const ProfessionChipGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InspectorProvider>();
    final allProfessions = provider.allProfessions;
    final selected = provider.selectedProfessions;

    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (screenWidth > 1100) {
      crossAxisCount = 5;
    } else if (screenWidth > 750) {
      crossAxisCount = 3;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  '选择解读视角',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '已选 ${selected.length} 个',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _openCustomDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('自定义视角', style: TextStyle(fontSize: 13)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: selected.length == allProfessions.length
                      ? provider.clearSelectedProfessions
                      : provider.selectAllProfessions,
                  child: Text(
                    selected.length == allProfessions.length ? '清空' : '全选',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: screenWidth > 600 ? 2.4 : 2.0,
          ),
          itemCount: allProfessions.length,
          itemBuilder: (context, index) {
            final prof = allProfessions[index];
            final isSelected = selected.contains(prof);

            return _buildProfessionCard(
              context: context,
              profession: prof,
              isSelected: isSelected,
              onTap: () => provider.toggleProfession(prof),
            );
          },
        ),
      ],
    );
  }

  void _openCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const CustomProfessionDialog(),
    );
  }

  Widget _buildProfessionCard({
    required BuildContext context,
    required Profession profession,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final themeColor = profession.accentColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? themeColor.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? themeColor : AppColors.cardBorder,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: themeColor.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? themeColor : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                profession.icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          profession.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? themeColor
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (profession.isCustom) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '自定义',
                            style: TextStyle(
                                fontSize: 9, color: Colors.indigo),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    profession.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: themeColor,
              ),
          ],
        ),
      ),
    );
  }
}
