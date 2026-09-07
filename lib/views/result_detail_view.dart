import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import '../models/history_record.dart';
import '../services/export_service.dart';
import '../widgets/comparison_slider_view.dart';
import '../widgets/exportable_summary_card.dart';
import '../widgets/perspective_card.dart';

class ResultDetailView extends StatefulWidget {
  final HistoryRecord record;

  const ResultDetailView({super.key, required this.record});

  @override
  State<ResultDetailView> createState() => _ResultDetailViewState();
}

class _ResultDetailViewState extends State<ResultDetailView> {
  int _viewMode = 0; // 0 = cards, 1 = comparison

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    Uint8List? imageBytes;
    if (record.imageBytesBase64 != null) {
      imageBytes = base64Decode(record.imageBytesBase64!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(record.imageName),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: '复制完整报告',
            onPressed: () async {
              final ok = await ExportService.copyReportToClipboard(
                imageName: record.imageName,
                results: record.results,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? '全职业解读报告已复制！' : '复制失败'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: '导出图文卡片',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => ExportCardDialog(
                  imageBytes: imageBytes,
                  imageName: record.imageName,
                  results: record.results,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Image Preview
                if (imageBytes != null)
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Center(
                      child: Image.memory(
                        imageBytes,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Switcher
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '包含 ${record.results.length} 个职业视角的历史研判',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(
                          value: 0,
                          label: Text('列表', style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.view_agenda_outlined, size: 16),
                        ),
                        ButtonSegment(
                          value: 1,
                          label: Text('并排对比', style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.compare_arrows_rounded, size: 16),
                        ),
                      ],
                      selected: {_viewMode},
                      onSelectionChanged: (val) =>
                          setState(() => _viewMode = val.first),
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                if (_viewMode == 0) ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: record.results.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 18),
                    itemBuilder: (ctx, index) {
                      return PerspectiveCard(result: record.results[index]);
                    },
                  ),
                ] else ...[
                  ComparisonSliderView(results: record.results),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
