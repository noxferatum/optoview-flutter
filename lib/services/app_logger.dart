import 'dart:collection';

import 'package:flutter/foundation.dart';

/// Logger sencillo que escribe a consola y a fichero rotativo.
///
/// Uso:
/// ```dart
/// AppLogger.info('Exportación iniciada');
/// AppLogger.error('Fallo al generar PDF', error: e, stackTrace: st);
/// ```
abstract final class AppLogger {
  static const _maxMemoryEntries = 200;

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
    // En release no loguear nada.
    if (kReleaseMode) return;

    final now = DateTime.now().toIso8601String();
    final line = '[$now] $level: $message';

    // Consola (solo debug/profile)
    debugPrint(line);

    // Memoria (solo debug/profile)
    _memoryLog.addLast(line);
    while (_memoryLog.length > _maxMemoryEntries) {
      _memoryLog.removeFirst();
    }
  }
}
