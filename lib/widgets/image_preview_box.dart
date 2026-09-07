import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../constants/theme_constants.dart';
import '../providers/inspector_provider.dart';

class ImagePreviewBox extends StatelessWidget {
  const ImagePreviewBox({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final name = picked.name;
        final mime = picked.mimeType ?? 'image/jpeg';
        if (context.mounted) {
          context.read<InspectorProvider>().setImage(
                bytes: bytes,
                name: name,
                path: picked.path,
                mimeType: mime,
              );
        }
      }
    } catch (_) {
      // Fallback to FilePicker if image_picker encounters platform issues
      _pickWithFilePicker(context);
    }
  }

  Future<void> _pickWithFilePicker(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null && context.mounted) {
          context.read<InspectorProvider>().setImage(
                bytes: file.bytes!,
                name: file.name,
                path: file.path,
                mimeType: 'image/${file.extension ?? "jpeg"}',
              );
        }
      }
    } catch (_) {}
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  '选择图片获取方式',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEFF6FF),
                    child: Icon(Icons.photo_library_outlined,
                        color: AppColors.primary),
                  ),
                  title: const Text('从相册选取'),
                  subtitle: const Text('支持 JPG, PNG, WEBP 等格式'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(context, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF0FDF4),
                    child: Icon(Icons.camera_alt_outlined,
                        color: AppColors.accentEmerald),
                  ),
                  title: const Text('手机拍照上传'),
                  subtitle: const Text('即拍即析，适合现场环境巡查'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(context, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF5F3FF),
                    child: Icon(Icons.folder_open_outlined,
                        color: AppColors.accentIndigo),
                  ),
                  title: const Text('选择本地文件'),
                  subtitle: const Text('适用于电脑端或云端盘选取'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickWithFilePicker(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InspectorProvider>();
    final imageBytes = provider.selectedImageBytes;

    if (imageBytes != null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 340),
                  child: Center(
                    child: Image.memory(
                      imageBytes,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFloatingActionBtn(
                        icon: Icons.refresh_rounded,
                        tooltip: '更换图片',
                        onTap: () => _showImageSourceSheet(context),
                      ),
                      const SizedBox(width: 8),
                      _buildFloatingActionBtn(
                        icon: Icons.close_rounded,
                        tooltip: '清空图片',
                        color: Colors.red.shade50,
                        iconColor: Colors.red,
                        onTap: () => provider.clearImage(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(
                  top: BorderSide(color: AppColors.cardBorder),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.image_outlined,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.imageName ?? '已选图像',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    '${(imageBytes.lengthInBytes / 1024).toStringAsFixed(1)} KB',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Empty state upload box
    return InkWell(
      onTap: () => _showImageSourceSheet(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.35),
            width: 1.8,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_rounded,
                size: 38,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '上传一张图，开启多职业视角深度解读',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '点击选取 / 手机拍照 / 拖拽图片至此',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = Colors.white,
    Color iconColor = AppColors.textPrimary,
  }) {
    return Material(
      color: color,
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, size: 18, color: iconColor),
          ),
        ),
      ),
    );
  }
}
