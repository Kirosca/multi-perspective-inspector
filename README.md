# 多职业视角图像解读器 (Multi-Perspective Image Inspector)

基于 **Flutter 3.x** 构建的跨平台智能视觉研判应用（支持 **Web / Android / iOS / Windows / macOS**）。

用户上传一张图片后，可自由挑选一个或多个专业职业视角，系统将运用该职业的专业术语、关注点、风险判断输出深度结构化解读，并支持多视角横向并排对比、历史档案回看以及生成高清图文长图卡片。

---

## 🌟 核心功能一览

1. **图片上传与跨平台获取**：
   - 手机拍照上传（现场即时巡检）
   - 相册选取（本地图库）
   - 拖拽 / 电脑本地文件选取
   - 图片格式支持 JPG, PNG, WEBP

2. **15 种预置专业职业视角卡片 + 自定义职业扩展**：
   - **警察 / 侦探**：物证痕迹、可疑物品、人员动线、安防盲区、证据链
   - **室内设计师**：空间尺度、动线布局、天然采光、材质质感、色彩搭配
   - **医生**：人体工学、姿势代偿、慢性劳损、微环境通风、感染交叉污染
   - **律师**：物权权属、安全保障义务、侵权合规、知识产权、责任归责
   - **摄影师**：三分构图、动态范围、光比阴影、色温白平衡、景深控制
   - **建筑师 / 结构工程师**：承重荷载传递、受力节点、构造裂缝、沉降变形
   - **厨师 / 营养师**：食材新鲜度、危险温区（5-60℃）、美拉德反应、生熟交叉污染
   - **心理咨询师**：情绪投射、微表情与肢体语言、环境压力源、防御心理
   - **市场营销 / 广告**：视觉锚点、首屏抓眼度、品牌露出、购买欲激发、受众心智
   - **农艺师**：植物营养长势、缺素表征、病虫害发病点、光温土壤墒情
   - **消防安全检查员**：疏散通道畅通、可燃物荷载、电气违规过载、消防设施遮挡
   - **地质学家 / 自然学家**：岩层产状、风化侵蚀痕迹、水文地貌演化、微生态
   - **服装设计师**：人体廓形包容、面料克重垂坠、剪裁结构线、色彩色相搭配
   - **机械工程师**：运动自由度、紧固件与装配公差、磨损润滑、机械干涉防护
   - **历史学家 / 考古学家**：器物形制纹样断代、时代包浆痕迹、传统工艺遗存
   - **自定义职业视角**：支持随时通过弹窗输入任意职业（如“宠物行为学家”、“UI体验师”等），系统自动建档并即时纳入多视角研判。

3. **四位一体深度结构化输出**：
   - **一句话总体判断**：高度凝练的行业核心研判。
   - **3~6 条关键观察**：每条均包含【画面具体位置描述】（如“画面左下角”、“正中央操作台”、“背景右上侧”）以及详细的技术剖析。
   - **专业风险与建议**：警示框形态的高优先级风险排查与针对性落地操作指引。
   - **专业术语标签（Badge Tags）**：提炼行业核心专业词汇。

4. **多视角并排对比视图 (Comparison Mode)**：
   - 支持同时勾选多个职业视角（例如“警察 + 摄影师 + 室内设计师”），一键横向并排对比各自在同一画面的关注点差异与认知盲区。

5. **本地历史档案库**：
   - 本地自动离线存图与结构化结果，支持时间轴回看、一键重新载入解读台或删除记录。

6. **一键复制与高清长图卡片导出**：
   - 支持一键导出格式化纯文本报告。
   - 内置基于 `RepaintBoundary` 的图文长图渲染组件，一键生成精美海报式卡片。

7. **双模式引擎**：
   - **免 Key 智能演示模式 (Mock Mode)**：开箱即用，无需配置 API Key 即可体验专业逼真的 15 职业分析流程。
   - **多模态大模型接入模式**：支持配置任何兼容 OpenAI 协议端点（OpenAI GPT-4o、Claude 3.5 Sonnet、Gemini 1.5 Pro 等）。

---

## 🎨 视觉风格设计

- **基调**：简洁专业（浅色卡片式）。
- **色彩**：
  - 底色：`#F8FAFC`（柔和 Slate 50）
  - 卡片：纯白 `#FFFFFF` 配搭 `#E2E8F0` 微边框与 `16px` 大圆角
  - 品牌主色：`#2563EB`（专业科技蓝）
  - 各职业专属辨识色（如警察深蓝、设计水青、医生玫瑰红、律师靛蓝、摄影琥珀金等）

---

## 📁 目录结构

```
multi_perspective_inspector/
├── pubspec.yaml
├── README.md
├── web/
│   ├── index.html
│   └── manifest.json
└── lib/
    ├── main.dart                          // 应用启动入口
    ├── constants/
    │   ├── preset_professions.dart        // 15 个预置职业定义与词库
    │   └── theme_constants.dart          // 浅色卡片式主题与色板
    ├── models/
    │   ├── profession.dart                // 职业数据模型
    │   ├── observation_item.dart          // 关键观察（含画面位置定位）
    │   ├── analysis_result.dart           // 结构化解读结果模型
    │   └── history_record.dart            // 历史记录持久化模型
    ├── services/
    │   ├── ai_service.dart                // 多模态 LLM 客户端与智能 Mock 引擎
    │   ├── storage_service.dart           // 本地 SharedPreferences 存储服务
    │   └── export_service.dart            // 报告复制与长图捕获服务
    ├── providers/
    │   └── inspector_provider.dart        // 全局状态管理 (ChangeNotifier)
    ├── views/
    │   ├── main_navigation_shell.dart     // 响应式双端适配导航壳 (Web / Mobile)
    │   ├── upload_and_inspect_view.dart   // 上传选图与多职业研判工作台
    │   ├── result_detail_view.dart        // 历史单项详情与对比复盘
    │   ├── history_view.dart              // 历史档案管理列表
    │   └── settings_view.dart             // AI 接入设置与运行模式切换
    └── widgets/
        ├── image_preview_box.dart         // 图像选取/拍摄/预览卡片
        ├── profession_chip_grid.dart      // 职业多选卡片网格与自适应列
        ├── perspective_card.dart          // 单职业结构化成果卡片
        ├── comparison_slider_view.dart    // 横向并排对比滚动容器
        ├── exportable_summary_card.dart   // 导出高清长图海报组件
        └── custom_profession_dialog.dart  // 自定义职业添加弹窗
```

---

## 🚀 运行与构建方式

### 1. 依赖安装
在安装了 Flutter SDK 的环境下执行：
```bash
flutter pub get
```

### 2. 本地运行
- **运行 Web 端（推荐体验）**：
  ```bash
  flutter run -d chrome
  ```
- **运行 Windows 桌面端**：
  ```bash
  flutter run -d windows
  ```
- **运行移动端（Android / iOS）**：
  ```bash
  flutter run -d <device-id>
  ```

### 3. 构建发布
- **打包 Web 静态文件**：
  ```bash
  flutter build web --release
  ```
- **打包 Android APK**：
  ```bash
  flutter build apk --release
  ```
