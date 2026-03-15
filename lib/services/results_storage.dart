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

  /// Actualiza un resultado existente (por su id).
  static Future<void> update(SavedResult updated) async {
    try {
      final results = await loadAll();
      final idx = results.indexWhere((r) => r.id == updated.id);
      if (idx == -1) return;
      results[idx] = updated;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(results.map((r) => r.toJson()).toList()),
      );
    } catch (_) {}
  }

  /// Exporta todos los resultados como JSON string.
  static Future<String> exportAllJson() async {
    final results = await loadAll();
    return jsonEncode({
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'results': results.map((r) => r.toJson()).toList(),
    });
  }

  /// Importa resultados desde JSON string. Devuelve el nº de resultados importados.
  /// Evita duplicados por id.
  static Future<int> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final imported = (data['results'] as List<dynamic>)
          .map((e) => SavedResult.fromJson(e as Map<String, dynamic>))
          .toList();
      if (imported.isEmpty) return 0;

      final existing = await loadAll();
      final existingIds = existing.map((r) => r.id).toSet();
      final newResults =
          imported.where((r) => !existingIds.contains(r.id)).toList();
      if (newResults.isEmpty) return 0;

      existing.addAll(newResults);
      existing.sort((a, b) => b.startedAt.compareTo(a.startedAt));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(existing.map((r) => r.toJson()).toList()),
      );
      return newResults.length;
    } catch (_) {
      return -1;
    }
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
