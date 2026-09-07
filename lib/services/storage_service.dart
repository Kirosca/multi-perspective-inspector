import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_record.dart';
import '../models/profession.dart';
import 'ai_service.dart';

class StorageService {
  static const String _keyHistory = 'mpi_history_records';
  static const String _keySettings = 'mpi_ai_settings';
  static const String _keyCustomProfessions = 'mpi_custom_professions';

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  /// Load all history records ordered by newest first
  Future<List<HistoryRecord>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyHistory) ?? [];
      return list
          .map((item) => HistoryRecord.fromJson(jsonDecode(item)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  /// Save a new history record
  Future<void> saveHistoryRecord(HistoryRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyHistory) ?? [];
      list.insert(0, jsonEncode(record.toJson()));
      // Limit to latest 50 records to manage storage
      if (list.length > 50) {
        list.removeRange(50, list.length);
      }
      await prefs.setStringList(_keyHistory, list);
    } catch (_) {}
  }

  /// Delete a single history record
  Future<void> deleteHistoryRecord(String recordId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyHistory) ?? [];
      list.removeWhere((item) {
        try {
          final decoded = jsonDecode(item);
          return decoded['id'] == recordId;
        } catch (_) {
          return false;
        }
      });
      await prefs.setStringList(_keyHistory, list);
    } catch (_) {}
  }

  /// Clear all history
  Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistory);
  }

  /// Load AI settings
  Future<AIServiceConfig> loadAISettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keySettings);
      if (jsonString != null) {
        return AIServiceConfig.fromJson(jsonDecode(jsonString));
      }
    } catch (_) {}
    return const AIServiceConfig();
  }

  /// Save AI settings
  Future<void> saveAISettings(AIServiceConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySettings, jsonEncode(config.toJson()));
    } catch (_) {}
  }

  /// Load custom professions
  Future<List<Profession>> loadCustomProfessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyCustomProfessions) ?? [];
      return list
          .map((item) => Profession.fromJson(jsonDecode(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Save custom profession
  Future<void> saveCustomProfession(Profession profession) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyCustomProfessions) ?? [];
      list.add(jsonEncode(profession.toJson()));
      await prefs.setStringList(_keyCustomProfessions, list);
    } catch (_) {}
  }
}
