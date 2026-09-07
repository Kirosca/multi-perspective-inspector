import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../models/analysis_result.dart';

class ExportService {
  /// Copy formatted full report to system clipboard
  static Future<bool> copyReportToClipboard({
    required String imageName,
    required List<AnalysisResult> results,
  }) async {
    final sb = StringBuffer();
    sb.writeln('====================================');
    sb.writeln(' 多职业视角图像解读报告');
    sb.writeln(' 图片名称：$imageName');
    sb.writeln(' 解读时间：${DateTime.now().toLocal()}');
    sb.writeln('====================================\n');

    for (final res in results) {
      sb.writeln(res.toFormattedText());
      sb.writeln('\n------------------------------------\n');
    }

    try {
      await Clipboard.setData(ClipboardData(text: sb.toString()));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Capture a widget wrapped in RepaintBoundary to PNG bytes
  static Future<Uint8List?> captureBoundaryToImage(
      GlobalKey boundaryKey) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }
}
