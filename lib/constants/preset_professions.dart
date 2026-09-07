import 'package:flutter/material.dart';
import '../models/profession.dart';

class PresetProfessions {
  static const List<Profession> list = [
    Profession(
      id: 'police_detective',
      name: '警察 / 侦探',
      icon: Icons.policy_outlined,
      description: '剖析物证痕迹、可疑点、人员动线及安全风险推断',
      focusAreas: ['物证痕迹', '可疑物品', '动线还原', '安全盲区', '合规与嫌疑证据链'],
      accentColor: Color(0xFF1E3A8A), // Dark Blue
    ),
    Profession(
      id: 'interior_designer',
      name: '室内设计师',
      icon: Icons.chair_outlined,
      description: '空间尺度比例、动线布局、采光色彩搭配及人体工效软装',
      focusAreas: ['空间动线', '光影采光', '材质质感', '色彩搭配', '收纳与软装布局'],
      accentColor: Color(0xFF0D9488), // Teal
    ),
    Profession(
      id: 'doctor',
      name: '医生',
      icon: Icons.medical_services_outlined,
      description: '卫生健康隐患、人体体态工学代偿、病理/生理特征及感染防控',
      focusAreas: ['卫生环境', '不良姿态/骨骼工学', '外伤/病理特征', '致敏与交叉污染', '健康隐患'],
      accentColor: Color(0xFFE11D48), // Rose
    ),
    Profession(
      id: 'lawyer',
      name: '律师',
      icon: Icons.gavel_outlined,
      description: '权属边界争议、合规风险、侵权取证与免责证据链分析',
      focusAreas: ['物权归属', '侵权合规', '肖像与隐私', '免责警示标识', '诉讼留痕取证'],
      accentColor: Color(0xFF4338CA), // Indigo
    ),
    Profession(
      id: 'photographer',
      name: '摄影师',
      icon: Icons.camera_alt_outlined,
      description: '构图法则、光影质感、色温宽容度、景深控制及视觉视觉重心',
      focusAreas: ['构图与视线引导', '光比与阴影质感', '色彩与白平衡', '景深与虚化', '画面杂质剔除'],
      accentColor: Color(0xFFD97706), // Amber
    ),
    Profession(
      id: 'architect_engineer',
      name: '建筑师 / 结构工程师',
      icon: Icons.foundation_outlined,
      description: '承重荷载传力路径、结构形式稳定性、建筑物理及沉降防裂',
      focusAreas: ['荷载分布', '梁柱受力节点', '结构开裂与形变', '建筑材料老化', '规范合规性'],
      accentColor: Color(0xFFEA580C), // Orange
    ),
    Profession(
      id: 'chef_nutritionist',
      name: '厨师 / 营养师',
      icon: Icons.restaurant_outlined,
      description: '食材新鲜度表征、烹饪熟化火候、膳食营养均衡与交叉污染防控',
      focusAreas: ['食材新鲜度与熟化度', '三大宏量营养配比', '烹饪技法与美拉德反应', '生熟分区与卫安', '风味口感搭配'],
      accentColor: Color(0xFF16A34A), // Emerald
    ),
    Profession(
      id: 'psychologist',
      name: '心理咨询师',
      icon: Icons.psychology_outlined,
      description: '情绪投射、微表情与肢体语言、环境压力源及隐性心理诉求',
      focusAreas: ['微表情与眼神接触', '肢体防御/开放态', '环境给人的心理压力', '色彩情绪投射', '人际亲密距离'],
      accentColor: Color(0xFF9333EA), // Purple
    ),
    Profession(
      id: 'marketing_advertiser',
      name: '市场营销 / 广告',
      icon: Icons.campaign_outlined,
      description: '视觉锚点吸引力、品牌心智占领、受众情绪共鸣与转化催化点',
      focusAreas: ['首屏视觉抓眼度', '品牌露出与辨识度', '痛点刺激与购买欲', '目标受众画像匹配', 'CTA行动号召'],
      accentColor: Color(0xFFDC2626), // Red
    ),
    Profession(
      id: 'agronomist',
      name: '农艺师',
      icon: Icons.eco_outlined,
      description: '植物长势长相、病虫害发病表征、土壤水分光照与田间管理建议',
      focusAreas: ['叶片/茎干营养长势', '病虫害与缺素表征', '光照与温湿度条件', '土壤墒情', '植保与肥水管理'],
      accentColor: Color(0xFF65A30D), // Lime
    ),
    Profession(
      id: 'fire_safety_inspector',
      name: '消防安全检查员',
      icon: Icons.local_fire_department_outlined,
      description: '疏散通道阻碍、易燃易爆物堆积、电气火灾隐患及灭火设施就位',
      focusAreas: ['疏散通道与安全出口', '可燃易燃物荷载', '电气线路违规与过载', '消防设施遮挡与巡检', '防火分隔完整性'],
      accentColor: Color(0xFFB91C1C), // Deep Red
    ),
    Profession(
      id: 'geologist_naturalist',
      name: '地质学家 / 自然学家',
      icon: Icons.terrain_outlined,
      description: '岩石矿物构造、风化侵蚀痕迹、水文地貌演化及生态群落特征',
      focusAreas: ['岩层产状与层理', '地质营力与风化作用', '矿物风貌与水系侵蚀', '微生态与伴生物种', '地质灾害风险'],
      accentColor: Color(0xFF78350F), // Warm Brown
    ),
    Profession(
      id: 'fashion_designer',
      name: '服装设计师',
      icon: Icons.checkroom_outlined,
      description: '版型剪裁廓形、面料垂坠肌理、撞色呼应与工艺车线细节',
      focusAreas: ['人体廓形包容度', '面料克重与垂坠光泽', '剪裁结构线与缝位', '色彩色相呼应', '配饰与风格完成度'],
      accentColor: Color(0xFFDB2777), // Pink
    ),
    Profession(
      id: 'mechanical_engineer',
      name: '机械工程师',
      icon: Icons.precision_manufacturing_outlined,
      description: '机械传动机构、装配公差间隙、润滑磨损与机械运转安全防范',
      focusAreas: ['运动自由度与传动链', '紧固件松动与配合公差', '疲劳损伤与润滑密封', '防护罩与干涉风险', '加工工艺合理性'],
      accentColor: Color(0xFF475569), // Slate
    ),
    Profession(
      id: 'historian_archeologist',
      name: '历史学家 / 考古学家',
      icon: Icons.auto_stories_outlined,
      description: '器物纹样断代、历史年代痕迹、文化层沉淀及传统工艺技术考证',
      focusAreas: ['形制与纹样时代特征', '材质风化与年代包浆', '制造工艺与技术遗存', '历史生活场景还原', '文物保护价值'],
      accentColor: Color(0xFF854D0E), // Yellow Brown
    ),
  ];

  static Profession? findById(String id) {
    try {
      return list.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
