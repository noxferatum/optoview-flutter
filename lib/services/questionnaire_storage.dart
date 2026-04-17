import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/questionnaire_result.dart';
import 'app_logger.dart';

abstract final class QuestionnaireStorage {
  static const _key = 'questionnaires';

  static Future<List<QuestionnaireResult>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => QuestionnaireResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      AppLogger.error('QuestionnaireStorage.loadAll failed',
          error: e, stackTrace: st);
      return [];
    }
  }

  static Future<void> saveAll(List<QuestionnaireResult> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(items.map((q) => q.toJson()).toList());
      await prefs.setString(_key, raw);
    } catch (e, st) {
      AppLogger.error('QuestionnaireStorage.saveAll failed',
          error: e, stackTrace: st);
    }
  }

  static Future<void> addOrUpdate(QuestionnaireResult q) async {
    final current = await loadAll();
    final idx = current.indexWhere((x) => x.id == q.id);
    if (idx >= 0) {
      current[idx] = q;
    } else {
      current.insert(0, q);
    }
    await saveAll(current);
  }

  static Future<void> delete(String id) async {
    final current = await loadAll();
    current.removeWhere((x) => x.id == id);
    await saveAll(current);
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e, st) {
      AppLogger.error('QuestionnaireStorage.clear failed',
          error: e, stackTrace: st);
    }
  }
}
