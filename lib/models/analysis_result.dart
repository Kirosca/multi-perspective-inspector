import 'observation_item.dart';

class AnalysisResult {
  final String professionId;
  final String professionName;
  final String oneSentenceSummary;
  final List<ObservationItem> keyObservations;
  final String risksAndRecommendations;
  final List<String> terminologyTags;
  final int latencyMs;
  final DateTime timestamp;

  AnalysisResult({
    required this.professionId,
    required this.professionName,
    required this.oneSentenceSummary,
    required this.keyObservations,
    required this.risksAndRecommendations,
    required this.terminologyTags,
    this.latencyMs = 0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'professionId': professionId,
      'professionName': professionName,
      'oneSentenceSummary': oneSentenceSummary,
      'keyObservations': keyObservations.map((e) => e.toJson()).toList(),
      'risksAndRecommendations': risksAndRecommendations,
      'terminologyTags': terminologyTags,
      'latencyMs': latencyMs,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    var rawObs = json['keyObservations'] as List<dynamic>? ?? [];
    return AnalysisResult(
      professionId: json['professionId'] as String? ?? 'unknown',
      professionName: json['professionName'] as String? ?? '专业视角',
      oneSentenceSummary: json['oneSentenceSummary'] as String? ?? '未提取到核心总结',
      keyObservations: rawObs
          .map((item) => ObservationItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      risksAndRecommendations:
          json['risksAndRecommendations'] as String? ?? '无特别风险预警',
      terminologyTags: (json['terminologyTags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      latencyMs: json['latencyMs'] as int? ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toFormattedText() {
    final sb = StringBuffer();
    sb.writeln('【$professionName 视角解读】');
    sb.writeln('总体判断：$oneSentenceSummary');
    sb.writeln('\n关键观察：');
    for (int i = 0; i < keyObservations.length; i++) {
      final obs = keyObservations[i];
      sb.writeln('${i + 1}. [${obs.location}] ${obs.title}：${obs.description}');
    }
    sb.writeln('\n专业风险与建议：\n$risksAndRecommendations');
    if (terminologyTags.isNotEmpty) {
      sb.writeln('\n专业术语：${terminologyTags.map((t) => "#$t").join(" ")}');
    }
    return sb.toString();
  }
}
