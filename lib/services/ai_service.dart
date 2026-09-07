import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/analysis_result.dart';
import '../models/observation_item.dart';
import '../models/profession.dart';

class AIServiceConfig {
  final String apiKey;
  final String endpoint; // default: https://api.openai.com/v1/chat/completions or custom gateway
  final String model;
  final bool isMockMode;

  const AIServiceConfig({
    this.apiKey = '',
    this.endpoint = 'https://api.openai.com/v1/chat/completions',
    this.model = 'gpt-4o',
    this.isMockMode = true,
  });

  Map<String, dynamic> toJson() => {
        'apiKey': apiKey,
        'endpoint': endpoint,
        'model': model,
        'isMockMode': isMockMode,
      };

  factory AIServiceConfig.fromJson(Map<String, dynamic> json) =>
      AIServiceConfig(
        apiKey: json['apiKey'] as String? ?? '',
        endpoint: json['endpoint'] as String? ??
            'https://api.openai.com/v1/chat/completions',
        model: json['model'] as String? ?? 'gpt-4o',
        isMockMode: json['isMockMode'] as bool? ?? true,
      );
}

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  AIServiceConfig _config = const AIServiceConfig();

  AIServiceConfig get config => _config;
  void updateConfig(AIServiceConfig newConfig) {
    _config = newConfig;
  }

  /// Analyze image from selected profession's perspective
  Future<AnalysisResult> analyzeImage({
    required Uint8List imageBytes,
    required String mimeType,
    required Profession profession,
  }) async {
    final stopwatch = Stopwatch()..start();

    // If mock mode is forced or no API key is provided, use high-fidelity domain mock
    if (_config.isMockMode || _config.apiKey.trim().isEmpty) {
      await Future.delayed(
          Duration(milliseconds: 600 + (profession.name.hashCode % 400).abs()));
      stopwatch.stop();
      return _generateProfessionalMock(profession, stopwatch.elapsedMilliseconds);
    }

    try {
      final base64Img = base64Encode(imageBytes);
      final prompt = _buildSystemPrompt(profession);

      final requestBody = {
        "model": _config.model,
        "messages": [
          {
            "role": "system",
            "content":
                "你是一个顶级的专业领域专家。请完全沉浸在你被赋予的【${profession.name}】角色中，严格基于图片信息进行极其专业、尖锐、务实的技术/业务解读。必须输出合法的纯JSON数据，不得包含任何Markdown包裹代码块。"
          },
          {
            "role": "user",
            "content": [
              {
                "type": "text",
                "text":
                    "$prompt\n\n请输出符合下列JSON格式的内容：\n"
                    "{\n"
                    '  "oneSentenceSummary": "一句话总体专业判断",\n'
                    '  "keyObservations": [\n'
                    '    {"title": "特征标题", "location": "在画面中的具体位置（如左下角/正中央）", "description": "深入专业观察分析"}\n'
                    '  ],\n'
                    '  "risksAndRecommendations": "专业维度的风险排查与针对性落地建议",\n'
                    '  "terminologyTags": ["专业术语1", "专业术语2", "专业术语3", "专业术语4"]\n'
                    "}\n注意：keyObservations 需提供 3 到 6 条。"
              },
              {
                "type": "image_url",
                "image_url": {
                  "url": "data:$mimeType;base64,$base64Img",
                  "detail": "high"
                }
              }
            ]
          }
        ],
        "response_format": {"type": "json_object"},
        "temperature": 0.2
      };

      final response = await http
          .post(
            Uri.parse(_config.endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${_config.apiKey.trim()}',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 45));

      stopwatch.stop();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final content = decoded['choices'][0]['message']['content'];
        final parsedJson = jsonDecode(content);

        return AnalysisResult(
          professionId: profession.id,
          professionName: profession.name,
          oneSentenceSummary: parsedJson['oneSentenceSummary'] ?? '完成多视角研判',
          keyObservations: (parsedJson['keyObservations'] as List<dynamic>?)
                  ?.map((e) =>
                      ObservationItem.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [],
          risksAndRecommendations:
              parsedJson['risksAndRecommendations'] ?? '暂无重大风险',
          terminologyTags: (parsedJson['terminologyTags'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          latencyMs: stopwatch.elapsedMilliseconds,
        );
      } else {
        // Fallback to domain mock if API returns error, but tag it with actual error info
        return _generateProfessionalMock(
          profession,
          stopwatch.elapsedMilliseconds,
          errorMessage: 'API响应异常 (${response.statusCode})，已展示参考解读',
        );
      }
    } catch (e) {
      stopwatch.stop();
      return _generateProfessionalMock(
        profession,
        stopwatch.elapsedMilliseconds,
        errorMessage: '网络连接异常 ($e)，已自动切换为仿真解读',
      );
    }
  }

  String _buildSystemPrompt(Profession profession) {
    return "【当前职业视角】：${profession.name}\n"
        "【该职业的核心关注点】：${profession.focusAreas.join('、')}\n"
        "【职责定位】：${profession.description}\n"
        "请用该职业的专属词汇、思维模式与评估标准，对画面中暴露的物理事实、隐含线索和潜在逻辑进行解构。避免空泛套话，每条观察必须精准指向画面区域。";
  }

  /// High-fidelity realistic mock data generator for 15 professions + custom
  AnalysisResult _generateProfessionalMock(Profession profession, int latencyMs,
      {String? errorMessage}) {
    switch (profession.id) {
      case 'police_detective':
        return AnalysisResult(
          professionId: profession.id,
          professionName: profession.name,
          oneSentenceSummary: '现场保留有多次活动轨迹与非受控物品滞留痕迹，存在动线交叉与盲区风险。',
          keyObservations: const [
            ObservationItem(
              title: '人员进出主通道受阻',
              location: '画面前部偏右地面',
              description: '杂物堆叠阻隔了直行视线与撤离通道，地面有明显推拉摩擦痕迹。',
            ),
            ObservationItem(
              title: '高价值/敏感物品无遮蔽',
              location: '画面中央工作台面',
              description: '物品呈非收纳随手摆放状态，边缘无防护，易发生顺手牵羊或意外碰落。',
            ),
            ObservationItem(
              title: '监控探测与照明死角',
              location: '画面左后方深色阴影处',
              description: '缺乏直接主光源补射，若无广角红外设备覆盖将形成侦查盲区。',
            ),
            ObservationItem(
              title: '门窗锁具与通行闭合度',
              location: '背景右上侧边缘',
              description: '未见明显多重物理加固装置，门禁防撬及防盗等级偏基础。',
            ),
          ],
          risksAndRecommendations:
              '【风险预警】：环境呈现低安防意识特征，盲区过多且出入轨迹易被隐匿。\n【处置建议】：清理通道障碍；增设广角安防摄像头并校准光照补偿；敏感物资实行封闭保管。',
          terminologyTags: ['动线交叉', '安防盲区', '物证保全', '视线遮蔽', '入侵防御度'],
          latencyMs: latencyMs,
        );

      case 'interior_designer':
        return AnalysisResult(
          professionId: profession.id,
          professionName: profession.name,
          oneSentenceSummary: '空间开间进深尺度适中，但收纳体系不闭环导致视觉杂乱，采光色温需进一步梳理。',
          keyObservations: const [
            ObservationItem(
              title: '主视觉焦点分散',
              location: '画面中央偏水平中轴',
              description: '缺乏统摄全景的景深锚点，色彩冷暖碰撞缺乏过渡灰度，空间视感略显局促。',
            ),
            ObservationItem(
              title: '天然采光与漫反射率',
              location: '画面右上方主采光面',
              description: '光线入射角较硬，周边材质高反光与磨砂哑光过渡不够自然。',
            ),
            ObservationItem(
              title: '动线回旋与尺度工学',
              location: '画面前景至中景过渡带',
              description: '通行走道有效净宽偏窄，家具边角未预留充裕的肢体挥洒余量。',
            ),
            ObservationItem(
              title: '垂直收纳与墙面利用率',
              location: '左侧立面垂直区域',
              description: '竖向立面空间存在大面积留白浪费，未能有效分流台面平铺压力。',
            ),
          ],
          risksAndRecommendations:
              '【设计痛点】：硬装底色尚可，但软装层级薄弱，缺乏情境照明（3000K-3500K暖白）。\n【优化建议】：置入模块化定制柜拉齐水平线；增加低位氛围灯带与吸音温润材质；规范回转半径。',
          terminologyTags: ['回转半径', '视觉锚点', '显色指数', '收纳比', '材质质感', '空间尺度'],
          latencyMs: latencyMs,
        );

      case 'doctor':
        return AnalysisResult(
          professionId: profession.id,
          professionName: profession.name,
          oneSentenceSummary: '环境工效学与局部微气候存在慢性劳损与病原滋生诱因，需关注久坐体态及气溶胶流通。',
          keyObservations: const [
            ObservationItem(
              title: '不良体态工效学诱因',
              location: '画面中央坐席与台面高差',
              description: '台面与坐具承托高差不协调，长时间处于此场景极易引发颈椎曲度变直及腰背肌筋膜炎。',
            ),
            ObservationItem(
              title: '微环境通风与飞沫滞留',
              location: '背景相对封闭角落',
              description: '空气流动呈死角态势，局部湿度若失衡易助长尘螨与真菌孢子繁衍。',
            ),
            ObservationItem(
              title: '高频手部接触物洁净度',
              location: '前景核心操作区域',
              description: '多重交互表面缺乏规律消毒痕迹，存在病原微生物间接接触交叉感染隐患。',
            ),
          ],
          risksAndRecommendations:
              '【健康警示】：长期处于缺乏人体工学承托及自然对流环境中，肌肉骨骼疾患发生率显著上升。\n【预防建议】：调整工作站高度符合90-90-90体态原则；定时开窗换气或配置HEPA空净系统；强化高频触点消杀。',
          terminologyTags: ['肌筋膜炎', '颈椎力学代偿', '气溶胶滞留', '人体工效学', '交叉污染'],
          latencyMs: latencyMs,
        );

      case 'photographer':
        return AnalysisResult(
          professionId: profession.id,
          professionName: profession.name,
          oneSentenceSummary: '现场光比较大且存在高光溢出，构图线条具有延伸感但需提炼主体视觉秩序。',
          keyObservations: const [
            ObservationItem(
              title: '主光源方向与阴影过渡',
              location: '右上向左下斜射光束',
              description: '侧逆光勾勒出了物体边缘轮廓，但背光面暗部细节（Shadows）欠曝明显。',
            ),
            ObservationItem(
              title: '三分法则与视觉导引线',
              location: '画面由左下至右上对角线',
              description: '自然形成的透视引导线较为有力，但中景缺乏点睛对比元素承接视线。',
            ),
            ObservationItem(
              title: '画面杂讯与边缘干扰',
              location: '左侧及底部裁切边缘',
              description: '构图边缘存在半截切断的非主体几何线条，破坏了画面的纯净呼吸感。',
            ),
            ObservationItem(
              title: '景深层次与空间压缩',
              location: '中景与远景虚化分界处',
              description: '光圈选择使主体与背景具有一定剥离度，空间立体纵深感表现充分。',
            ),
          ],
          risksAndRecommendations:
              '【曝光建议】：高光位出现轻微过曝截断，动态范围（Dynamic Range）逼近传感器极限。\n【拍摄提升】：建议使用反光板补足暗部1-2档曝光；微调机位剔除边缘杂物；启用偏振镜抑制高光反光。',
          terminologyTags: ['动态范围', '视线引导线', '高光溢出', '色温漂移', '边缘畸变', '三分构图'],
          latencyMs: latencyMs,
        );

      case 'architect_engineer':
        return AnalysisResult(
          professionId: profession.id,
          professionName: profession.name,
          oneSentenceSummary: '建筑构件荷载传递路径清晰，局部构造缝与面层材料老化需纳入巡检周期。',
          keyObservations: const [
            ObservationItem(
              title: '垂直承重体系与荷载受力',
              location: '画面立面承重骨架处',
              description: '主要竖向支承构件轴压比在视觉上处于常规受力范围，结构未见整体偏斜沉降。',
            ),
            ObservationItem(
              title: '接缝处应力集中与密封',
              location: '梁柱节点及转角阴角',
              description: '不同材质拼缝处存在微细温度伸缩痕迹，外饰面防渗防裂涂层有泛黄退化迹象。',
            ),
            ObservationItem(
              title: '楼地面均布荷载负荷',
              location: '底部受力板跨中部',
              description: '局部集中荷载摆放密集，需复核原设计板跨活荷载标准值（kN/㎡）是否超标。',
            ),
          ],
          risksAndRecommendations:
              '【结构安全评定】：整体构造稳定性良好，未见结构性贯通剪切裂缝。\n【维护方案】：重点排查阴阳角防渗与填缝硅酮胶老化；严禁在轻质隔墙悬挂重型设备；建立沉降观测档案。',
          terminologyTags: ['轴压比', '均布荷载', '刚度匹配', '冷桥效应', '温度应力', '剪切承载力'],
          latencyMs: latencyMs,
        );

      case 'chef_nutritionist':
        return AnalysisResult(
          professionId: profession.id,
          professionName: profession.name,
          oneSentenceSummary: '食材/原料加工环境对温湿度极其敏感，生熟隔离与冷链断链风险是当前核心管控点。',
          keyObservations: const [
            ObservationItem(
              title: '温度危险温区滞留风险',
              location: '操作平台非冷藏展示区',
              description: '食材置于室温环境（5℃-60℃危险温区），易发生表面嗜温细菌对数期裂变。',
            ),
            ObservationItem(
              title: '生熟工序与器具交叉交叉可能',
              location: '切配与摆放交界处',
              description: '操作动线未实现物理绝对硬隔离，砧板与接触物存在交叉污染（Cross-contamination）隐患。',
            ),
            ObservationItem(
              title: '营养结构与色泽氧化表征',
              location: '核心食材截面区域',
              description: '表面光泽度反映水分轻微逸失，天然抗氧化多酚物质暴露于光氧环境已有轻度褐变。',
            ),
          ],
          risksAndRecommendations:
              '【食品安全红线】：常温放置时间严禁超过2小时，避免蜡样芽孢杆菌或沙门氏菌滋生。\n【品控建议】：立即入冷藏库（<4℃）封存；实施红蓝双色生熟砧板刀具色标管理；引入真空低温锁鲜工艺。',
          terminologyTags: ['危险温区', '交叉污染', '美拉德反应', '酶促褐变', '色标管理', '水分活性'],
          latencyMs: latencyMs,
        );

      case 'lawyer':
        return AnalysisResult(
          professionId: profession.id,
          professionName: profession.name,
          oneSentenceSummary: '权属界限与合规警示标志不够清晰，存在潜在的侵权争议及过错责任归责风险。',
          keyObservations: const [
            ObservationItem(
              title: '物权管辖与占有权属表征',
              location: '场景边界与核心资产标识处',
              description: '缺乏明确的物权所有者铭牌或准入许可告示，公私领域交错易诱发占有争议。',
            ),
            ObservationItem(
              title: '安全保障义务警示缺失',
              location: '潜在高危/滑跌/跌落区域',
              description: '现场未张贴显眼的“小心滑倒”或“安全防护”警示标识，未能完全履行民法典第1198条安全保障义务。',
            ),
            ObservationItem(
              title: '知识产权与商标露出合规',
              location: '画面中各类标识印记处',
              description: '存在第三方商业LOGO与可能涉及著作权的外观展示，商业化传播时存在侵权追责隐患。',
            ),
          ],
          risksAndRecommendations:
              '【法律风险排查】：一旦发生人身意外伤害，场所管理人需承担无过错或推定过错的举证责任倒置风险。\n【合规建议】：设立醒目的免责与警示黄黑警示条；补齐商业使用授权协议；完善现场视频留痕凭证。',
          terminologyTags: ['安全保障义务', '举证责任倒置', '过错推定', '无权占有', '肖像权抗辩', '合规留痕'],
          latencyMs: latencyMs,
        );

      default:
        return AnalysisResult(
          professionId: profession.id,
          professionName: profession.name,
          oneSentenceSummary:
              '从【${profession.name}】的专业视阈切入，核心要素与外部环境互动紧密，关键指标需系统化调优。',
          keyObservations: [
            ObservationItem(
              title: '${profession.focusAreas.firstOrNull ?? "核心要素"}显性表征',
              location: '画面中央主体区域',
              description:
                  '根据${profession.name}评价标准，主体形态与行业准则匹配度高，具备典型特征。',
            ),
            ObservationItem(
              title: '边界约束与系统协调性',
              location: '画面周围与环境交互带',
              description:
                  '在外部负荷与环境扰动下，相关细节展现了该工种高度关注的特定规律与变化。',
            ),
            ObservationItem(
              title: '细部工艺与潜在隐患',
              location: '局部细节与接缝特写处',
              description:
                  '工艺精细度达到行业中位数水平，但微观层面仍存在待优化的专业短板。',
            ),
          ],
          risksAndRecommendations:
              '【专业建议】：基于${profession.name}的实操规程，建议建立标准化巡查基线，强化关键指标的动态监控与预防性维护。',
          terminologyTags: profession.focusAreas.take(5).toList(),
          latencyMs: latencyMs,
        );
    }
  }
}
