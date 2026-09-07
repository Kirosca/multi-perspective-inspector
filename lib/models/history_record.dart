import 'dart:convert';
import 'analysis_result.dart';

class HistoryRecord {
  final String id;
  final String? imageBytesBase64;
  final String? imagePath;
  final String imageName;
  final DateTime createdAt;
  final List<AnalysisResult> results;

  HistoryRecord({
    required this.id,
    this.imageBytesBase64,
    this.imagePath,
    required this.imageName,
    required this.createdAt,
    required this.results,
  });

  List<String> get professionNames =>
      results.map((r) => r.professionName).toList();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageBytesBase64': imageBytesBase64,
      'imagePath': imagePath,
      'imageName': imageName,
      'createdAt': createdAt.toIso8601String(),
      'results': results.map((r) => r.toJson()).toList(),
    };
  }

  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    var rawResults = json['results'] as List<dynamic>? ?? [];
    return HistoryRecord(
      id: json['id'] as String,
      imageBytesBase64: json['imageBytesBase64'] as String?,
      imagePath: json['imagePath'] as String?,
      imageName: json['imageName'] as String? ?? '未命名图片',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      results: rawResults
          .map((item) => AnalysisResult.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
