import 'package:flutter/material.dart';
import '../constants/preset_professions.dart';
import '../constants/theme_constants.dart';
import '../models/analysis_result.dart';
import 'perspective_card.dart';

class ComparisonSliderView extends StatelessWidget {
  final List<AnalysisResult> results;

  const ComparisonSliderView({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top comparison difference summary banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              const Icon(Icons.compare_arrows_rounded,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '多视角对比模式：横向并排对比 ${results.length} 种职业针对同一画面的关注点分歧与认知盲区',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E40AF),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Horizontal comparison scroll container
        SizedBox(
          height: 640,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: results.length,
            separatorBuilder: (ctx, i) => const SizedBox(width: 16),
            itemBuilder: (ctx, index) {
              final result = results[index];
              return SizedBox(
                width: isDesktop ? 400 : screenWidth * 0.85,
                child: SingleChildScrollView(
                  child: PerspectiveCard(
                    result: result,
                    isCompact: true,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
