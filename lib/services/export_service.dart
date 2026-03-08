import 'dart:math';
import 'dart:typed_data';

import 'package:excel/excel.dart' as xl;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;

import '../l10n/app_localizations.dart';
import '../models/macdonald_result.dart';
import '../models/saved_result.dart';

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

  // ---------------------------------------------------------------------------
  // PDF individual
  // ---------------------------------------------------------------------------

  static Future<void> exportResultPdf(
    BuildContext context,
    SavedResult result,
    AppLocalizations l,
  ) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          _pdfHeader(result, l),
          pw.SizedBox(height: 16),
          _pdfMetrics(result, l),
          if (result.anillosCompletados != null ||
              (result.tiempoPorAnillo != null && result.tiempoPorAnillo!.isNotEmpty))
            _pdfRingTimes(result, l),
          pw.SizedBox(height: 12),
          _pdfConfigSummary(result, l),
          if (result.letterEvents != null && result.letterEvents!.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            _pdfScatterPlots(result, l),
          ],
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) => doc.save(),
      name: 'OptoView_${result.testType}_${result.id}',
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

  static pw.Widget _pdfMetrics(SavedResult result, AppLocalizations l) {
    final rows = <List<String>>[
      [l.statsActualDuration, '${result.durationActualSeconds}s'],
      [l.statsStimuliShown, '${result.totalStimuliShown}'],
    ];

    if (result.correctTouches != null) {
      rows.add([l.accuracyCorrect, '${result.correctTouches}']);
    }
    if (result.incorrectTouches != null) {
      rows.add([l.accuracyErrors, '${result.incorrectTouches}']);
    }
    if (result.missedStimuli != null) {
      rows.add([l.accuracyMissed, '${result.missedStimuli}']);
    }
    if (result.accuracy != null) {
      rows.add([l.accuracyPercent, '${(result.accuracy! * 100).toStringAsFixed(1)}%']);
    }
    if (result.avgReactionTimeMs != null) {
      rows.add([l.reactionAvg, '${result.avgReactionTimeMs!.toStringAsFixed(0)} ms']);
    }
    if (result.bestReactionTimeMs != null) {
      rows.add([l.reactionBest, '${result.bestReactionTimeMs!.toStringAsFixed(0)} ms']);
    }
    if (result.worstReactionTimeMs != null) {
      rows.add([l.reactionWorst, '${result.worstReactionTimeMs!.toStringAsFixed(0)} ms']);
    }
    if (result.stimuliPerMinute != null) {
      rows.add([l.statsStimuliPerMinute, result.stimuliPerMinute!.toStringAsFixed(1)]);
    }
    if (result.anillosCompletados != null) {
      rows.add([l.macStatsRingsCompleted, '${result.anillosCompletados}']);
    }

    return pw.TableHelper.fromTextArray(
      headerAlignment: pw.Alignment.centerLeft,
      cellAlignment: pw.Alignment.centerLeft,
      data: rows,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  static pw.Widget _pdfRingTimes(SavedResult result, AppLocalizations l) {
    if (result.tiempoPorAnillo == null || result.tiempoPorAnillo!.isEmpty) {
      return pw.SizedBox();
    }
    final rows = result.tiempoPorAnillo!
        .asMap()
        .entries
        .map((e) => [l.macRingLabel(e.key + 1), '${(e.value / 1000).toStringAsFixed(1)}s'])
        .toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 12),
        pw.Text(l.macStatsTimePerRing,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.TableHelper.fromTextArray(
          data: rows,
          border: pw.TableBorder.all(color: PdfColors.grey300),
          cellStyle: const pw.TextStyle(fontSize: 10),
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ],
    );
  }

  static pw.Widget _pdfConfigSummary(SavedResult result, AppLocalizations l) {
    if (result.configSummary.isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(l.configUsedTitle,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.TableHelper.fromTextArray(
          data: result.configSummary.entries
              .map((e) => [e.key, e.value])
              .toList(),
          border: pw.TableBorder.all(color: PdfColors.grey300),
          cellStyle: const pw.TextStyle(fontSize: 10),
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ],
    );
  }

  static pw.Widget _pdfScatterPlots(SavedResult result, AppLocalizations l) {
    final hits = result.letterEvents!.where((e) => e.isHit).toList();
    final misses = result.letterEvents!.where((e) => !e.isHit).toList();
    final numRings = result.anillosCompletados ?? 3;

    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Column(
            children: [
              pw.Text(l.macHitMapTitle,
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.SizedBox(
                width: 180,
                height: 180,
                child: pw.CustomPaint(
                  painter: (canvas, size) =>
                      _paintScatterPlot(canvas, size, hits, PdfColors.green, numRings),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 16),
        pw.Expanded(
          child: pw.Column(
            children: [
              pw.Text(l.macMissMapTitle,
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.SizedBox(
                width: 180,
                height: 180,
                child: pw.CustomPaint(
                  painter: (canvas, size) =>
                      _paintScatterPlot(canvas, size, misses, PdfColors.red, numRings),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static void _paintScatterPlot(
    PdfGraphics canvas,
    PdfPoint size,
    List<LetterEvent> events,
    PdfColor dotColor,
    int numRings,
  ) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    final radius = min(size.x, size.y) / 2 - 4;

    // Rings
    canvas.setStrokeColor(PdfColors.grey400);
    canvas.setLineWidth(0.5);
    for (int i = 1; i <= numRings; i++) {
      final r = radius * i / numRings;
      canvas.drawEllipse(cx, cy, r, r);
      canvas.strokePath();
    }

    // Cross
    canvas.setLineWidth(0.3);
    canvas.drawLine(cx - radius, cy, cx + radius, cy);
    canvas.strokePath();
    canvas.drawLine(cx, cy - radius, cx, cy + radius);
    canvas.strokePath();

    // Dots
    canvas.setFillColor(dotColor);
    for (final e in events) {
      final x = cx + e.dx * radius;
      final y = cy - e.dy * radius; // PDF y is bottom-up
      canvas.drawEllipse(x, y, 3, 3);
      canvas.fillPath();
    }
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
    final doc = pw.Document();
    final now = _dateFmt.format(DateTime.now());

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          pw.Text(l.exportPatientReport(patientName),
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(l.exportReportGenerated(now),
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: [
              l.exportTestDate,
              l.exportTestType,
              l.exportAccuracy,
              l.exportReactionTime,
              l.exportDuration,
            ],
            data: results.map((r) {
              final acc = r.accuracy != null
                  ? '${(r.accuracy! * 100).toStringAsFixed(1)}%'
                  : '-';
              final rt = r.avgReactionTimeMs != null
                  ? '${r.avgReactionTimeMs!.toStringAsFixed(0)} ms'
                  : '-';
              return [
                _dateFmt.format(r.startedAt),
                _testTypeLabel(r.testType, l),
                acc,
                rt,
                '${r.durationActualSeconds}s',
              ];
            }).toList(),
            border: pw.TableBorder.all(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerAlignment: pw.Alignment.centerLeft,
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) => doc.save(),
      name: 'OptoView_resumen_$patientName',
    );
  }

  // ---------------------------------------------------------------------------
  // Excel individual
  // ---------------------------------------------------------------------------

  static Future<void> exportResultExcel(
    SavedResult result,
    AppLocalizations l,
  ) async {
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
    if (bytes == null) return;

    await Share.shareXFiles([
      XFile.fromData(
        Uint8List.fromList(bytes),
        name: 'OptoView_${result.testType}_${result.id}.xlsx',
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      ),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Excel resumen por paciente
  // ---------------------------------------------------------------------------

  static Future<void> exportPatientSummaryExcel(
    String patientName,
    List<SavedResult> results,
    AppLocalizations l,
  ) async {
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
    if (bytes == null) return;

    await Share.shareXFiles([
      XFile.fromData(
        Uint8List.fromList(bytes),
        name: 'OptoView_resumen_$patientName.xlsx',
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      ),
    ]);
  }

  // ---------------------------------------------------------------------------
  // CSV individual
  // ---------------------------------------------------------------------------

  static Future<void> exportResultCsv(
    SavedResult result,
    AppLocalizations l,
  ) async {
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

    final bytes = Uint8List.fromList(buf.toString().codeUnits);
    await Share.shareXFiles([
      XFile.fromData(
        bytes,
        name: 'OptoView_${result.testType}_${result.id}.csv',
        mimeType: 'text/csv',
      ),
    ]);
  }

  // ---------------------------------------------------------------------------
  // CSV resumen por paciente
  // ---------------------------------------------------------------------------

  static Future<void> exportPatientSummaryCsv(
    String patientName,
    List<SavedResult> results,
    AppLocalizations l,
  ) async {
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

    final bytes = Uint8List.fromList(buf.toString().codeUnits);
    await Share.shareXFiles([
      XFile.fromData(
        bytes,
        name: 'OptoView_resumen_$patientName.csv',
        mimeType: 'text/csv',
      ),
    ]);
  }
}
