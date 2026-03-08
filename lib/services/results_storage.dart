import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_result.dart';

/// Servicio de persistencia de resultados con SharedPreferences.
abstract final class ResultsStorage {
  static const _key = 'optoview_results';

  /// Carga todos los resultados guardados (más recientes primero).
  static Future<List<SavedResult>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SavedResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Guarda un resultado al principio de la lista.
  static Future<void> save(SavedResult result) async {
    try {
      final results = await loadAll();
      results.insert(0, result);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(results.map((r) => r.toJson()).toList()),
      );
    } catch (_) {}
  }

  /// Elimina un resultado por su id.
  static Future<void> delete(String id) async {
    try {
      final results = await loadAll();
      results.removeWhere((r) => r.id == id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(results.map((r) => r.toJson()).toList()),
      );
    } catch (_) {}
  }

  /// Elimina todos los resultados.
  static Future<void> deleteAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}
