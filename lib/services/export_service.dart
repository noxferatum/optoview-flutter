import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart' as xl;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart' show Share, XFile;

import '../l10n/app_localizations.dart';
import '../models/saved_result.dart';
import '../utils/hit_map_renderer.dart';
import '../utils/web_download_stub.dart'
    if (dart.library.js_interop) '../utils/web_download.dart';
import 'app_logger.dart';

/// Servicio de exportación de resultados en PDF, Excel y CSV.
abstract final class ExportService {
  static final _dateFmt = DateFormat('dd/MM/yyyy HH:mm');

  // ---------------------------------------------------------------------------
  // Helpers comunes
  // ---------------------------------------------------------------------------

  static String _testTypeLabel(String type, AppLocalizations l) => switch (type) {
        'peripheral' => l.historyTestPeripheral,
        'localization' => l.historyTestLocalization,
        'macdonald' => l.historyTestMacdonald,
        _ => type,
      };

  /// Escribe bytes en un archivo temporal y lo comparte.
  /// En web usa descarga directa del navegador (no hay filesystem).
  static Future<void> _shareFile(
    Uint8List bytes,
    String filename,
    String mimeType,
  ) async {
    if (kIsWeb) {
      downloadFileWeb(bytes, filename, mimeType);
      return;
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path, mimeType: mimeType)]);
  }

  // ---------------------------------------------------------------------------
  // PDF individual
  // ---------------------------------------------------------------------------

  static Future<void> exportResultPdf(
    BuildContext context,
    SavedResult result,
    AppLocalizations l,
  ) async {
    AppLogger.info('exportResultPdf: inicio (test=${result.testType}, id=${result.id})');

    final doc = pw.Document();

    // Página principal con métricas y configuración.
    doc.addPage(_buildResultPage(result, l));

    // Página dedicada para los mapas de aciertos/fallos (pw.Image no soporta
    // paginación en MultiPage, así que van en su propia pw.Page).
    if (result.letterEvents != null && result.letterEvents!.isNotEmpty) {
      try {
        final mapsPage = await _buildHitMapsPage(result, l);
        doc.addPage(mapsPage);
        AppLogger.info('exportResultPdf: página de mapas añadida');
      } catch (e, st) {
        AppLogger.error('exportResultPdf: fallo al generar mapas, se omiten',
            error: e, stackTrace: st);
      }
    }

    final bytes = await doc.save();
    AppLogger.info('exportResultPdf: documento generado (${bytes.length} bytes)');

    await _shareFile(
      bytes,
      'OptoView_${result.testType}_${result.id}.pdf',
      'application/pdf',
    );
    AppLogger.info('exportResultPdf: compartido OK');
  }

  static pw.MultiPage _buildResultPage(SavedResult result, AppLocalizations l) {
    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      maxPages: 40,
      build: (ctx) => [
        _pdfHeader(result, l),
        pw.SizedBox(height: 16),
        ..._pdfMetrics(result, l),
        ..._pdfRingTimes(result, l),
        pw.SizedBox(height: 12),
        ..._pdfConfigSummary(result, l),
      ],
    );
  }

  /// Página dedicada con los mapas de aciertos/fallos como imágenes PNG.
  /// Usa pw.Page (no MultiPage) porque pw.Image no es SpanningWidget y no
  /// soporta paginación.
  static Future<pw.Page> _buildHitMapsPage(
    SavedResult result,
    AppLocalizations l,
  ) async {
    final events = result.letterEvents!;
    final numRings = result.anillosCompletados ?? 3;
    final hits = events.where((e) => e.isHit).toList();
    final misses = events.where((e) => !e.isHit).toList();

    const double imgSize = 200;

    final hitsPng = await renderHitMapToPng(
      events: hits,
      dotColor: const Color(0xFF69F0AE),
      numRings: numRings,
      size: 400,
    );
    final missesPng = await renderHitMapToPng(
      events: misses,
      dotColor: const Color(0xFFFF5252),
      numRings: numRings,
      size: 400,
    );

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            '${l.macHitMapTitle} / ${l.macMissMapTitle}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(children: [
                pw.Text(
                  l.macHitMapTitle,
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Image(pw.MemoryImage(hitsPng), width: imgSize, height: imgSize),
                pw.SizedBox(height: 4),
                pw.Text('${hits.length}',
                    style: const pw.TextStyle(fontSize: 10)),
              ]),
              pw.Column(children: [
                pw.Text(
                  l.macMissMapTitle,
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Image(pw.MemoryImage(missesPng), width: imgSize, height: imgSize),
                pw.SizedBox(height: 4),
                pw.Text('${misses.length}',
                    style: const pw.TextStyle(fontSize: 10)),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _pdfHeader(SavedResult result, AppLocalizations l) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          l.exportReportTitle,
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          _testTypeLabel(result.testType, l),
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        if (result.patientName.isNotEmpty)
          pw.Text('${l.patientName}: ${result.patientName}',
              style: const pw.TextStyle(fontSize: 12)),
        pw.Text(_dateFmt.format(result.startedAt),
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Divider(),
      ],
    );
  }

  /// Fila clave-valor ligera para el PDF (evita TableHelper que no es
  /// SpanningWidget y causa TooManyPagesException en MultiPage).
  static pw.Widget _kvRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          ),
          pw.Text(value,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static List<pw.Widget> _pdfMetrics(SavedResult result, AppLocalizations l) {
    return [
      _kvRow(l.statsActualDuration, '${result.durationActualSeconds}s'),
      _kvRow(l.statsStimuliShown, '${result.totalStimuliShown}'),
      if (result.correctTouches != null)
        _kvRow(l.accuracyCorrect, '${result.correctTouches}'),
      if (result.incorrectTouches != null)
        _kvRow(l.accuracyErrors, '${result.incorrectTouches}'),
      if (result.missedStimuli != null)
        _kvRow(l.accuracyMissed, '${result.missedStimuli}'),
      if (result.accuracy != null)
        _kvRow(l.accuracyPercent, '${(result.accuracy! * 100).toStringAsFixed(1)}%'),
      if (result.avgReactionTimeMs != null)
        _kvRow(l.reactionAvg, '${result.avgReactionTimeMs!.toStringAsFixed(0)} ms'),
      if (result.bestReactionTimeMs != null)
        _kvRow(l.reactionBest, '${result.bestReactionTimeMs!.toStringAsFixed(0)} ms'),
      if (result.worstReactionTimeMs != null)
        _kvRow(l.reactionWorst, '${result.worstReactionTimeMs!.toStringAsFixed(0)} ms'),
      if (result.stimuliPerMinute != null)
        _kvRow(l.statsStimuliPerMinute, result.stimuliPerMinute!.toStringAsFixed(1)),
      if (result.anillosCompletados != null)
        _kvRow(l.macStatsRingsCompleted, '${result.anillosCompletados}'),
    ];
  }

  static List<pw.Widget> _pdfRingTimes(SavedResult result, AppLocalizations l) {
    if (result.tiempoPorAnillo == null || result.tiempoPorAnillo!.isEmpty) {
      return [];
    }
    return [
      pw.SizedBox(height: 12),
      pw.Text(l.macStatsTimePerRing,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 4),
      ...result.tiempoPorAnillo!.asMap().entries.map(
            (e) => _kvRow(
                l.macRingLabel(e.key + 1), '${(e.value / 1000).toStringAsFixed(1)}s'),
          ),
    ];
  }

  static List<pw.Widget> _pdfConfigSummary(SavedResult result, AppLocalizations l) {
    if (result.configSummary.isEmpty) return [];
    return [
      pw.Text(l.configUsedTitle,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 4),
      ...result.configSummary.entries.map((e) => _kvRow(e.key, e.value)),
    ];
  }

  // ---------------------------------------------------------------------------
  // PDF resumen por paciente
  // ---------------------------------------------------------------------------

  static Future<void> exportPatientSummaryPdf(
    BuildContext context,
    String patientName,
    List<SavedResult> results,
    AppLocalizations l,
  ) async {
    AppLogger.info('exportPatientSummaryPdf: inicio (paciente=$patientName, '
        'resultados=${results.length})');

    final doc = pw.Document();
    final now = _dateFmt.format(DateTime.now());

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        maxPages: 100,
        build: (ctx) => [
          pw.Text(l.exportPatientReport(patientName),
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(l.exportReportGenerated(now),
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Divider(),
          pw.SizedBox(height: 8),
          // Cabecera
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400)),
            ),
            child: pw.Row(children: [
              pw.Expanded(flex: 3, child: pw.Text(l.exportTestDate,
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
              pw.Expanded(flex: 3, child: pw.Text(l.exportTestType,
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
              pw.Expanded(flex: 2, child: pw.Text(l.exportAccuracy,
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
              pw.Expanded(flex: 2, child: pw.Text(l.exportReactionTime,
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
              pw.Expanded(flex: 2, child: pw.Text(l.exportDuration,
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
            ]),
          ),
          // Filas individuales (paginables por MultiPage)
          ...results.map((r) {
            final acc = r.accuracy != null
                ? '${(r.accuracy! * 100).toStringAsFixed(1)}%'
                : '-';
            final rt = r.avgReactionTimeMs != null
                ? '${r.avgReactionTimeMs!.toStringAsFixed(0)} ms'
                : '-';
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
              ),
              child: pw.Row(children: [
                pw.Expanded(flex: 3, child: pw.Text(_dateFmt.format(r.startedAt),
                    style: const pw.TextStyle(fontSize: 9))),
                pw.Expanded(flex: 3, child: pw.Text(_testTypeLabel(r.testType, l),
                    style: const pw.TextStyle(fontSize: 9))),
                pw.Expanded(flex: 2, child: pw.Text(acc,
                    style: const pw.TextStyle(fontSize: 9))),
                pw.Expanded(flex: 2, child: pw.Text(rt,
                    style: const pw.TextStyle(fontSize: 9))),
                pw.Expanded(flex: 2, child: pw.Text('${r.durationActualSeconds}s',
                    style: const pw.TextStyle(fontSize: 9))),
              ]),
            );
          }),
        ],
      ),
    );

    final bytes = await doc.save();
    AppLogger.info('exportPatientSummaryPdf: documento generado (${bytes.length} bytes)');

    await _shareFile(
      bytes,
      'OptoView_resumen_$patientName.pdf',
      'application/pdf',
    );
    AppLogger.info('exportPatientSummaryPdf: compartido OK');
  }

  // ---------------------------------------------------------------------------
  // Excel individual
  // ---------------------------------------------------------------------------

  static Future<void> exportResultExcel(
    SavedResult result,
    AppLocalizations l,
  ) async {
    AppLogger.info('exportResultExcel: inicio (test=${result.testType}, id=${result.id})');
    final excel = xl.Excel.createExcel();
    final sheet = excel['Resultado'];

    // Remove default Sheet1
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    int row = 0;

    void addRow(String label, String value) {
      sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
          xl.TextCellValue(label);
      sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
          xl.TextCellValue(value);
      row++;
    }

    addRow(l.exportTestType, _testTypeLabel(result.testType, l));
    addRow(l.patientName, result.patientName);
    addRow(l.exportTestDate, _dateFmt.format(result.startedAt));
    addRow(l.statsActualDuration, '${result.durationActualSeconds}s');
    addRow(l.statsStimuliShown, '${result.totalStimuliShown}');

    if (result.correctTouches != null) addRow(l.accuracyCorrect, '${result.correctTouches}');
    if (result.incorrectTouches != null) addRow(l.accuracyErrors, '${result.incorrectTouches}');
    if (result.missedStimuli != null) addRow(l.accuracyMissed, '${result.missedStimuli}');
    if (result.accuracy != null) {
      addRow(l.accuracyPercent, '${(result.accuracy! * 100).toStringAsFixed(1)}%');
    }
    if (result.avgReactionTimeMs != null) {
      addRow(l.reactionAvg, '${result.avgReactionTimeMs!.toStringAsFixed(0)} ms');
    }
    if (result.bestReactionTimeMs != null) {
      addRow(l.reactionBest, '${result.bestReactionTimeMs!.toStringAsFixed(0)} ms');
    }
    if (result.worstReactionTimeMs != null) {
      addRow(l.reactionWorst, '${result.worstReactionTimeMs!.toStringAsFixed(0)} ms');
    }
    if (result.stimuliPerMinute != null) {
      addRow(l.statsStimuliPerMinute, result.stimuliPerMinute!.toStringAsFixed(1));
    }
    if (result.anillosCompletados != null) {
      addRow(l.macStatsRingsCompleted, '${result.anillosCompletados}');
    }

    row++;
    addRow(l.configUsedTitle, '');
    for (final entry in result.configSummary.entries) {
      addRow(entry.key, entry.value);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      AppLogger.warning('exportResultExcel: encode() devolvió null');
      return;
    }

    await _shareFile(
      Uint8List.fromList(bytes),
      'OptoView_${result.testType}_${result.id}.xlsx',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    AppLogger.info('exportResultExcel: compartido OK');
  }

  // ---------------------------------------------------------------------------
  // Excel resumen por paciente
  // ---------------------------------------------------------------------------

  static Future<void> exportPatientSummaryExcel(
    String patientName,
    List<SavedResult> results,
    AppLocalizations l,
  ) async {
    AppLogger.info('exportPatientSummaryExcel: inicio (paciente=$patientName, '
        'resultados=${results.length})');
    final excel = xl.Excel.createExcel();
    final sheet = excel['Resumen'];

    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    // Header
    final headers = [
      l.exportTestDate,
      l.exportTestType,
      l.exportAccuracy,
      l.exportReactionTime,
      l.exportDuration,
      l.statsStimuliShown,
    ];
    for (int c = 0; c < headers.length; c++) {
      sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0)).value =
          xl.TextCellValue(headers[c]);
    }

    for (int r = 0; r < results.length; r++) {
      final res = results[r];
      final row = r + 1;
      final acc = res.accuracy != null
          ? '${(res.accuracy! * 100).toStringAsFixed(1)}%'
          : '-';
      final rt = res.avgReactionTimeMs != null
          ? '${res.avgReactionTimeMs!.toStringAsFixed(0)} ms'
          : '-';
      final values = [
        _dateFmt.format(res.startedAt),
        _testTypeLabel(res.testType, l),
        acc,
        rt,
        '${res.durationActualSeconds}s',
        '${res.totalStimuliShown}',
      ];
      for (int c = 0; c < values.length; c++) {
        sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row)).value =
            xl.TextCellValue(values[c]);
      }
    }

    final bytes = excel.encode();
    if (bytes == null) {
      AppLogger.warning('exportPatientSummaryExcel: encode() devolvió null');
      return;
    }

    await _shareFile(
      Uint8List.fromList(bytes),
      'OptoView_resumen_$patientName.xlsx',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    AppLogger.info('exportPatientSummaryExcel: compartido OK');
  }

  // ---------------------------------------------------------------------------
  // CSV individual
  // ---------------------------------------------------------------------------

  static Future<void> exportResultCsv(
    SavedResult result,
    AppLocalizations l,
  ) async {
    AppLogger.info('exportResultCsv: inicio (test=${result.testType}, id=${result.id})');
    final buf = StringBuffer();

    void addRow(String label, String value) {
      buf.writeln('$label;$value');
    }

    addRow(l.exportTestType, _testTypeLabel(result.testType, l));
    addRow(l.patientName, result.patientName);
    addRow(l.exportTestDate, _dateFmt.format(result.startedAt));
    addRow(l.statsActualDuration, '${result.durationActualSeconds}');
    addRow(l.statsStimuliShown, '${result.totalStimuliShown}');

    if (result.correctTouches != null) addRow(l.accuracyCorrect, '${result.correctTouches}');
    if (result.incorrectTouches != null) addRow(l.accuracyErrors, '${result.incorrectTouches}');
    if (result.missedStimuli != null) addRow(l.accuracyMissed, '${result.missedStimuli}');
    if (result.accuracy != null) {
      addRow(l.accuracyPercent, '${(result.accuracy! * 100).toStringAsFixed(1)}');
    }
    if (result.avgReactionTimeMs != null) {
      addRow(l.reactionAvg, '${result.avgReactionTimeMs!.toStringAsFixed(0)}');
    }
    if (result.bestReactionTimeMs != null) {
      addRow(l.reactionBest, '${result.bestReactionTimeMs!.toStringAsFixed(0)}');
    }
    if (result.worstReactionTimeMs != null) {
      addRow(l.reactionWorst, '${result.worstReactionTimeMs!.toStringAsFixed(0)}');
    }
    if (result.stimuliPerMinute != null) {
      addRow(l.statsStimuliPerMinute, result.stimuliPerMinute!.toStringAsFixed(1));
    }
    if (result.anillosCompletados != null) {
      addRow(l.macStatsRingsCompleted, '${result.anillosCompletados}');
    }

    for (final entry in result.configSummary.entries) {
      addRow(entry.key, entry.value);
    }

    await _shareFile(
      Uint8List.fromList(buf.toString().codeUnits),
      'OptoView_${result.testType}_${result.id}.csv',
      'text/csv',
    );
    AppLogger.info('exportResultCsv: compartido OK');
  }

  // ---------------------------------------------------------------------------
  // CSV resumen por paciente
  // ---------------------------------------------------------------------------

  static Future<void> exportPatientSummaryCsv(
    String patientName,
    List<SavedResult> results,
    AppLocalizations l,
  ) async {
    AppLogger.info('exportPatientSummaryCsv: inicio (paciente=$patientName, '
        'resultados=${results.length})');
    final buf = StringBuffer();

    // Header
    buf.writeln([
      l.exportTestDate,
      l.exportTestType,
      l.exportAccuracy,
      l.exportReactionTime,
      l.exportDuration,
      l.statsStimuliShown,
    ].join(';'));

    for (final r in results) {
      final acc = r.accuracy != null
          ? (r.accuracy! * 100).toStringAsFixed(1)
          : '';
      final rt = r.avgReactionTimeMs != null
          ? r.avgReactionTimeMs!.toStringAsFixed(0)
          : '';
      buf.writeln([
        _dateFmt.format(r.startedAt),
        _testTypeLabel(r.testType, l),
        acc,
        rt,
        '${r.durationActualSeconds}',
        '${r.totalStimuliShown}',
      ].join(';'));
    }

    await _shareFile(
      Uint8List.fromList(buf.toString().codeUnits),
      'OptoView_resumen_$patientName.csv',
      'text/csv',
    );
    AppLogger.info('exportPatientSummaryCsv: compartido OK');
  }
}
