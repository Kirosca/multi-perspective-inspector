import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/theme_constants.dart';
import '../models/history_record.dart';
import '../providers/inspector_provider.dart';
import 'result_detail_view.dart';

class HistoryView extends StatelessWidget {
  final VoidCallback onNavigateToInspect;

  const HistoryView({super.key, required this.onNavigateToInspect});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InspectorProvider>();
    final history = provider.historyRecords;
    final isLoading = provider.isLoadingHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('解读历史档案'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
              tooltip: '清空历史',
              onPressed: () => _confirmClearAll(context),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: '刷新',
            onPressed: () => provider.refreshHistory(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: history.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 14),
                  itemBuilder: (ctx, index) {
                    final record = history[index];
                    return _buildHistoryCard(context, record);
                  },
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_toggle_off_rounded,
              size: 48,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无解读历史记录',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '上传一张图片并选择职业视角，分析结果将自动归档在此',
            style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onNavigateToInspect,
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
            label: const Text('立即开始分析'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, HistoryRecord record) {
    final provider = context.read<InspectorProvider>();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => ResultDetailView(record: record),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 80,
                  height: 80,
                  color: const Color(0xFFF1F5F9),
                  child: record.imageBytesBase64 != null
                      ? Image.memory(
                          base64Decode(record.imageBytesBase64!),
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_outlined,
                          color: AppColors.textTertiary),
                ),
              ),

              const SizedBox(width: 14),

              // Info Area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            record.imageName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          dateFormat.format(record.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '包含 ${record.results.length} 个职业视角的深度研判',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: record.professionNames.map((name) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Action Options
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    size: 18, color: AppColors.textTertiary),
                onSelected: (val) {
                  if (val == 'restore') {
                    provider.loadRecordToCurrent(record);
                    onNavigateToInspect();
                  } else if (val == 'delete') {
                    provider.deleteHistoryItem(record.id);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'restore',
                    child: Row(
                      children: [
                        Icon(Icons.open_in_browser_rounded, size: 16),
                        SizedBox(width: 8),
                        Text('载入到解读台'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('删除记录', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空解读历史'),
        content: const Text('确定要清空全部保存的历史解读记录吗？此操作无法撤回。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<InspectorProvider>().clearAllHistory();
              Navigator.pop(ctx);
            },
            child: const Text('确认清空'),
          ),
        ],
      ),
    );
  }
}
