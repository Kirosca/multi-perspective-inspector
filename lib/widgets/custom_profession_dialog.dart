import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme_constants.dart';
import '../providers/inspector_provider.dart';

class CustomProfessionDialog extends StatefulWidget {
  const CustomProfessionDialog({super.key});

  @override
  State<CustomProfessionDialog> createState() => _CustomProfessionDialogState();
}

class _CustomProfessionDialogState extends State<CustomProfessionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _focusAreasController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _focusAreasController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final desc = _descController.text.trim();
      final rawFocus = _focusAreasController.text.trim();
      final focusAreas = rawFocus
          .split(RegExp(r'[,，、\s]+'))
          .where((e) => e.isNotEmpty)
          .toList();

      context.read<InspectorProvider>().addCustomProfession(
            name: name,
            description: desc,
            focusAreas: focusAreas.isEmpty ? [name, '专业研判', '行业合规'] : focusAreas,
          );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_moderator_outlined,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '添加自定义职业视角',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '职业名称',
                  hintText: '如：宠物行为分析师 / UI体验专家',
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? '请输入职业名称' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: '职责视角定位',
                  hintText: '简述该职业面对图像时最关心的维度与评价准则',
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? '请输入视角职责' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _focusAreasController,
                decoration: const InputDecoration(
                  labelText: '核心关注词 / 术语（逗号隔开）',
                  hintText: '如：应激反应、动线舒适度、交互闭环',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('确认添加并勾选'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
