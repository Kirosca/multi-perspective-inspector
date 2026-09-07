import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme_constants.dart';
import '../providers/inspector_provider.dart';
import '../services/export_service.dart';
import '../widgets/comparison_slider_view.dart';
import '../widgets/exportable_summary_card.dart';
import '../widgets/image_preview_box.dart';
import '../widgets/perspective_card.dart';
import '../widgets/profession_chip_grid.dart';

class UploadAndInspectView extends StatelessWidget {
  const UploadAndInspectView({super.key});

  void _openExportDialog(BuildContext context) {
    final provider = context.read<InspectorProvider>();
    showDialog(
      context: context,
      builder: (ctx) => ExportCardDialog(
        imageBytes: provider.selectedImageBytes,
        imageName: provider.imageName ?? '未命名图片',
        results: provider.currentResults,
      ),
    );
  }

  void _copyAllReport(BuildContext context) async {
    final provider = context.read<InspectorProvider>();
    final ok = await ExportService.copyReportToClipboard(
      imageName: provider.imageName ?? '未命名图片',
      results: provider.currentResults,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? '全职业解读报告已复制到剪贴板！' : '复制失败'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ok ? AppColors.success : AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InspectorProvider>();
    final hasImage = provider.selectedImageBytes != null;
    final hasSelectedProfessions = provider.selectedProfessions.isNotEmpty;
    final isAnalyzing = provider.isAnalyzing;
    final results = provider.currentResults;
    final hasResults = results.isNotEmpty;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.remove_red_eye_outlined,
                          color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '多职业视角图像解读器',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '上传图片 · 多职业视角矩阵 · 深度解构画面事实与认知差异',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 1. Upload Box
                const ImagePreviewBox(),

                const SizedBox(height: 28),

                // 2. Profession Grid Selector
                const ProfessionChipGrid(),

                const SizedBox(height: 24),

                // 3. Action Button / Analysis Status
                if (isAnalyzing) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Column(
                      children: [
                        const LinearProgressIndicator(
                          backgroundColor: Color(0xFFDBEAFE),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          provider.analyzingStatus,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: (hasImage && hasSelectedProfessions)
                          ? () => provider.startAnalysis()
                          : null,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                      label: Text(
                        hasImage
                            ? '开始解读 (${provider.selectedProfessions.length} 个视角)'
                            : '请先上传一张图片',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],

                // 4. Results Section
                if (hasResults) ...[
                  const SizedBox(height: 36),
                  const Divider(color: AppColors.cardBorder),
                  const SizedBox(height: 20),

                  // Results Header & Mode Switcher
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.insights_rounded,
                              color: AppColors.primary, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            '解读成果 (${results.length} 个视角已完成)',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Toggle View Mode: 0 = Cards, 1 = Comparison Slider
                          SegmentedButton<int>(
                            segments: const [
                              ButtonSegment(
                                value: 0,
                                label: Text('列表卡片',
                                    style: TextStyle(fontSize: 12)),
                                icon: Icon(Icons.view_agenda_outlined, size: 16),
                              ),
                              ButtonSegment(
                                value: 1,
                                label: Text('并排对比',
                                    style: TextStyle(fontSize: 12)),
                                icon:
                                    Icon(Icons.compare_arrows_rounded, size: 16),
                              ),
                            ],
                            selected: {provider.resultViewMode},
                            onSelectionChanged: (val) =>
                                provider.setResultViewMode(val.first),
                            style: const ButtonStyle(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: () => _copyAllReport(context),
                            icon: const Icon(Icons.copy_rounded, size: 15),
                            label: const Text('复制报告',
                                style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _openExportDialog(context),
                            icon: const Icon(Icons.photo_album_outlined,
                                size: 15),
                            label: const Text('导出长图',
                                style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Rendering results according to View Mode
                  if (provider.resultViewMode == 0) ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: results.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 20),
                      itemBuilder: (ctx, index) {
                        return PerspectiveCard(result: results[index]);
                      },
                    ),
                  ] else ...[
                    ComparisonSliderView(results: results),
                  ],
                ],

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
