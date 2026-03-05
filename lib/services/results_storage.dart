import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/saved_result.dart';

/// Servicio de persistencia de resultados en archivo JSON local.
abstract final class ResultsStorage {
  static const _fileName = 'optoview_results.json';

  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Carga todos los resultados guardados (más recientes primero).
  static Future<List<SavedResult>> loadAll() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final list = jsonDecode(content) as List<dynamic>;
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
      final file = await _getFile();
      await file.writeAsString(jsonEncode(results.map((r) => r.toJson()).toList()));
    } catch (_) {}
  }

  /// Elimina un resultado por su id.
  static Future<void> delete(String id) async {
    try {
      final results = await loadAll();
      results.removeWhere((r) => r.id == id);
      final file = await _getFile();
      await file.writeAsString(jsonEncode(results.map((r) => r.toJson()).toList()));
    } catch (_) {}
  }

  /// Elimina todos los resultados.
  static Future<void> deleteAll() async {
    try {
      final file = await _getFile();
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}
