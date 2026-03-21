import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Logger sencillo que escribe a consola y a fichero rotativo.
///
/// Uso:
/// ```dart
/// AppLogger.info('Exportación iniciada');
/// AppLogger.error('Fallo al generar PDF', error: e, stackTrace: st);
/// ```
abstract final class AppLogger {
  static const _maxMemoryEntries = 200;
  static const _maxFileSizeBytes = 512 * 1024; // 512 KB

  /// Últimas entradas en memoria (accesible para una futura pantalla de debug).
  static final Queue<String> _memoryLog = Queue();
  static UnmodifiableListView<String> get entries =>
      UnmodifiableListView(_memoryLog.toList());

  // -- Niveles -----------------------------------------------------------------

  static void info(String message) => _log('INFO', message);

  static void warning(String message) => _log('WARN', message);

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final buf = StringBuffer(message);
    if (error != null) buf.write(' | $error');
    if (stackTrace != null) buf.write('\n$stackTrace');
    _log('ERROR', buf.toString());
  }

  // -- Internos ----------------------------------------------------------------

  static void _log(String level, String message) {
    final now = DateTime.now().toIso8601String();
    final line = '[$now] $level: $message';

    // Consola (debug)
    debugPrint(line);

    // Memoria
    _memoryLog.addLast(line);
    while (_memoryLog.length > _maxMemoryEntries) {
      _memoryLog.removeFirst();
    }

    // Fichero (fire-and-forget, no bloquea)
    _writeToFile(line);
  }

  static Future<void> _writeToFile(String line) async {
    try {
      if (kIsWeb) return; // En web no hay filesystem
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/optoview_log.txt');

      // Rotación: si supera el tamaño máximo, truncar
      if (await file.exists() && await file.length() > _maxFileSizeBytes) {
        final lines = await file.readAsLines();
        final half = lines.length ~/ 2;
        await file.writeAsString('${lines.skip(half).join('\n')}\n');
      }

      await file.writeAsString('$line\n', mode: FileMode.append);
    } catch (_) {
      // No propagar errores del logger
    }
  }
}
