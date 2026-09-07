import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../constants/preset_professions.dart';
import '../models/analysis_result.dart';
import '../models/history_record.dart';
import '../models/profession.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';

class InspectorProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final AIService _aiService = AIService();

  // Current Image State
  Uint8List? _selectedImageBytes;
  String? _imageName;
  String? _imagePath;
  String _mimeType = 'image/jpeg';

  // Professions
  List<Profession> _allProfessions = [];
  final Set<Profession> _selectedProfessions = {};

  // Analysis State
  bool _isAnalyzing = false;
  String _analyzingStatus = '';
  List<AnalysisResult> _currentResults = [];

  // History State
  List<HistoryRecord> _historyRecords = [];
  bool _isLoadingHistory = false;

  // Active result view mode: 0 = Tabbed/Single Card, 1 = Side-by-side comparison
  int _resultViewMode = 0;

  // Settings
  AIServiceConfig _config = const AIServiceConfig();

  // Getters
  Uint8List? get selectedImageBytes => _selectedImageBytes;
  String? get imageName => _imageName;
  String? get imagePath => _imagePath;
  List<Profession> get allProfessions => _allProfessions;
  Set<Profession> get selectedProfessions => _selectedProfessions;
  bool get isAnalyzing => _isAnalyzing;
  String get analyzingStatus => _analyzingStatus;
  List<AnalysisResult> get currentResults => _currentResults;
  List<HistoryRecord> get historyRecords => _historyRecords;
  bool get isLoadingHistory => _isLoadingHistory;
  int get resultViewMode => _resultViewMode;
  AIServiceConfig get config => _config;

  InspectorProvider() {
    _init();
  }

  Future<void> _init() async {
    // 1. Load custom professions and merge with presets
    final custom = await _storage.loadCustomProfessions();
    _allProfessions = [...PresetProfessions.list, ...custom];

    // Preselect 2 popular contrasting professions by default
    if (_allProfessions.length >= 2) {
      _selectedProfessions.add(_allProfessions[0]); // 警察/侦探
      _selectedProfessions.add(_allProfessions[4]); // 摄影师
    }

    // 2. Load settings
    _config = await _storage.loadAISettings();
    _aiService.updateConfig(_config);

    // 3. Load history
    await refreshHistory();

    notifyListeners();
  }

  void setResultViewMode(int mode) {
    _resultViewMode = mode;
    notifyListeners();
  }

  void setImage({
    required Uint8List bytes,
    required String name,
    String? path,
    String mimeType = 'image/jpeg',
  }) {
    _selectedImageBytes = bytes;
    _imageName = name;
    _imagePath = path;
    _mimeType = mimeType;
    // Clear existing results on new image load
    _currentResults = [];
    notifyListeners();
  }

  void clearImage() {
    _selectedImageBytes = null;
    _imageName = null;
    _imagePath = null;
    _currentResults = [];
    notifyListeners();
  }

  void toggleProfession(Profession p) {
    if (_selectedProfessions.contains(p)) {
      _selectedProfessions.remove(p);
    } else {
      _selectedProfessions.add(p);
    }
    notifyListeners();
  }

  void selectAllProfessions() {
    _selectedProfessions.addAll(_allProfessions);
    notifyListeners();
  }

  void clearSelectedProfessions() {
    _selectedProfessions.clear();
    notifyListeners();
  }

  Future<void> addCustomProfession({
    required String name,
    required String description,
    required List<String> focusAreas,
  }) async {
    final newProf = Profession(
      id: 'custom_${const Uuid().v4().substring(0, 8)}',
      name: name,
      icon: Icons.person_search_outlined,
      description: description,
      focusAreas: focusAreas,
      isCustom: true,
      accentColor: const Color(0xFF6366F1),
    );

    _allProfessions.add(newProf);
    _selectedProfessions.add(newProf);
    await _storage.saveCustomProfession(newProf);
    notifyListeners();
  }

  /// Trigger Multi-Perspective Image Analysis
  Future<bool> startAnalysis() async {
    if (_selectedImageBytes == null) return false;
    if (_selectedProfessions.isEmpty) return false;

    _isAnalyzing = true;
    _currentResults = [];
    notifyListeners();

    final targetList = _selectedProfessions.toList();
    final results = <AnalysisResult>[];

    for (int i = 0; i < targetList.length; i++) {
      final prof = targetList[i];
      _analyzingStatus =
          '正在切换至【${prof.name}】视角深入解读 (${i + 1}/${targetList.length})...';
      notifyListeners();

      try {
        final result = await _aiService.analyzeImage(
          imageBytes: _selectedImageBytes!,
          mimeType: _mimeType,
          profession: prof,
        );
        results.add(result);
        _currentResults = List.from(results);
        notifyListeners();
      } catch (e) {
        // Continue with other professions if one fails
      }
    }

    _isAnalyzing = false;
    _analyzingStatus = '';

    // Save to local history
    if (results.isNotEmpty) {
      final record = HistoryRecord(
        id: const Uuid().v4(),
        imageBytesBase64: base64Encode(_selectedImageBytes!),
        imagePath: _imagePath,
        imageName: _imageName ?? '未命名图片',
        createdAt: DateTime.now(),
        results: results,
      );
      await _storage.saveHistoryRecord(record);
      await refreshHistory();
    }

    notifyListeners();
    return true;
  }

  Future<void> refreshHistory() async {
    _isLoadingHistory = true;
    notifyListeners();
    _historyRecords = await _storage.loadHistory();
    _isLoadingHistory = false;
    notifyListeners();
  }

  Future<void> deleteHistoryItem(String id) async {
    await _storage.deleteHistoryRecord(id);
    _historyRecords.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> clearAllHistory() async {
    await _storage.clearAllHistory();
    _historyRecords.clear();
    notifyListeners();
  }

  /// Load a historical record into active workspace
  void loadRecordToCurrent(HistoryRecord record) {
    if (record.imageBytesBase64 != null) {
      _selectedImageBytes = base64Decode(record.imageBytesBase64!);
    }
    _imageName = record.imageName;
    _imagePath = record.imagePath;
    _currentResults = List.from(record.results);

    // Sync selected professions with historical results
    _selectedProfessions.clear();
    for (final res in record.results) {
      final found = _allProfessions.firstWhere(
        (p) => p.name == res.professionName || p.id == res.professionId,
        orElse: () => Profession(
          id: res.professionId,
          name: res.professionName,
          icon: Icons.work_outline,
          description: '',
          focusAreas: res.terminologyTags,
        ),
      );
      _selectedProfessions.add(found);
    }

    notifyListeners();
  }

  Future<void> updateSettings(AIServiceConfig newConfig) async {
    _config = newConfig;
    _aiService.updateConfig(newConfig);
    await _storage.saveAISettings(newConfig);
    notifyListeners();
  }
}
