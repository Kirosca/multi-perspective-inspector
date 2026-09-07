import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme_constants.dart';
import '../providers/inspector_provider.dart';
import '../services/ai_service.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _endpointController;
  late TextEditingController _apiKeyController;
  late TextEditingController _modelController;
  bool _isMockMode = true;

  @override
  void initState() {
    super.initState();
    final config = context.read<InspectorProvider>().config;
    _endpointController = TextEditingController(text: config.endpoint);
    _apiKeyController = TextEditingController(text: config.apiKey);
    _modelController = TextEditingController(text: config.model);
    _isMockMode = config.isMockMode;
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final newConfig = AIServiceConfig(
      endpoint: _endpointController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      model: _modelController.text.trim(),
      isMockMode: _isMockMode,
    );

    context.read<InspectorProvider>().updateSettings(newConfig);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI 配置已成功保存！'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('系统配置与 AI 接入'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mode Toggle Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
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
                            child: const Icon(Icons.tune_rounded,
                                color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              '运行模式选择',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          '免 Key 智能演示体验模式 (Mock Mode)',
                          style: TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          '内置各行业资深专家画像模拟引擎，无需消耗任何 Token 即可体验 15 个职业的全流程分析。',
                          style: TextStyle(
                              fontSize: 12.5, color: AppColors.textSecondary),
                        ),
                        value: _isMockMode,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() => _isMockMode = val);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // API Config Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.cloud_queue_rounded,
                                color: AppColors.accentIndigo, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '多模态大模型接入设置 (OpenAI 协议)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '支持接入任何兼容 OpenAI Chat Completions 视觉能力的服务端点（包括官方 OpenAI、OneAPI、NewAPI 或第三方多模态网关）。',
                        style: TextStyle(
                            fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _endpointController,
                        decoration: const InputDecoration(
                          labelText: 'API 端点 URL (Endpoint)',
                          hintText:
                              'https://api.openai.com/v1/chat/completions',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _apiKeyController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'API Key',
                          hintText: 'sk-...',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _modelController,
                        decoration: const InputDecoration(
                          labelText: '视觉模型名称 (Vision Model)',
                          hintText: 'gpt-4o / gpt-4o-mini / claude-3-5-sonnet',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: _saveSettings,
                          icon: const Icon(Icons.save_outlined, size: 18),
                          label: const Text('保存配置'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Product Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '关于《多职业视角图像解读器》',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '本项目通过预置的 15 种专业领域视角（医生、律师、摄影师、建筑师、消防安全检查员、室内设计师、警察等），利用视觉大语言模型结构化提示词矩阵，帮助用户洞察图像中不同专业背景下所能观察到的隐秘信息与价值差异。',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Flutter 3.x 跨端',
                                style: TextStyle(
                                    fontSize: 11, color: AppColors.primary)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('结构化 JSON Schema',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.accentEmerald)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Web + Mobile 自适应',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.accentIndigo)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
