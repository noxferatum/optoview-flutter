import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart' as xl;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart' show Share, XFile;

import '../l10n/app_localizations.dart';
import '../models/questionnaire_result.dart';
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
        'field_detection' => l.historyTestFieldDetection,
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
  // Cuestionario individual (PDF / Excel / CSV)
  // ---------------------------------------------------------------------------

  static Future<void> exportQuestionnairePdf(
    BuildContext context,
    QuestionnaireResult q,
    AppLocalizations l,
  ) async {
    AppLogger.info('exportQuestionnairePdf: inicio (id=${q.id})');
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      maxPages: 10,
      build: (ctx) => [
        pw.Text(l.exportQuestionnaireTitle,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        if (q.patientName.isNotEmpty)
          pw.Text('${l.patientName}: ${q.patientName}',
              style: const pw.TextStyle(fontSize: 12)),
        pw.Text(_dateFmt.format(q.completedAt),
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 8),
        pw.Text('${l.questionnaireScoreLabel}: ${q.cvsqTotalScore}',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Divider(),
        pw.SizedBox(height: 8),

        // CVS-Q table header
        pw.Text(l.questionnaireCvsqSection,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400)),
          ),
          child: pw.Row(children: [
            pw.SizedBox(width: 20, child: pw.Text(l.exportItemNumber, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 5, child: pw.Text(l.exportItemName, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 3, child: pw.Text(l.exportFrequency, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text(l.exportIntensity, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(width: 30, child: pw.Text(l.exportScore, textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
          ]),
        ),
        ...List.generate(q.cvsqAnswers.length, (i) {
          final a = q.cvsqAnswers[i];
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
            ),
            child: pw.Row(children: [
              pw.SizedBox(width: 20, child: pw.Text('${i + 1}', style: const pw.TextStyle(fontSize: 9))),
              pw.Expanded(flex: 5, child: pw.Text(_cvsqItemPdfLabel(i, l), style: const pw.TextStyle(fontSize: 9))),
              pw.Expanded(flex: 3, child: pw.Text(_freqPdfLabel(a.frequency, l), style: const pw.TextStyle(fontSize: 9))),
              pw.Expanded(flex: 2, child: pw.Text(a.intensity == null ? '-' : _intPdfLabel(a.intensity!, l), style: const pw.TextStyle(fontSize: 9))),
              pw.SizedBox(width: 30, child: pw.Text('${a.score}', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 9))),
            ]),
          );
        }),

        pw.SizedBox(height: 16),
        pw.Text(l.questionnaireFssSection,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400)),
          ),
          child: pw.Row(children: [
            pw.Expanded(flex: 5, child: pw.Text(l.exportItemName, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text(l.exportValueScale, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
          ]),
        ),
        ...List.generate(q.fssAnswers.length, (i) {
          final v = q.fssAnswers[i];
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
            ),
            child: pw.Row(children: [
              pw.Expanded(flex: 5, child: pw.Text(_fssItemPdfLabel(i, l), style: const pw.TextStyle(fontSize: 9))),
              pw.Expanded(flex: 2, child: pw.Text(v == null ? '-' : '$v / 7', style: const pw.TextStyle(fontSize: 9))),
            ]),
          );
        }),
      ],
    ));
    final bytes = await doc.save();
    await _shareFile(bytes, 'OptoView_cuestionario_${q.id}.pdf', 'application/pdf');
    AppLogger.info('exportQuestionnairePdf: OK');
  }

  static Future<void> exportQuestionnaireExcel(
    QuestionnaireResult q,
    AppLocalizations l,
  ) async {
    AppLogger.info('exportQuestionnaireExcel: inicio (id=${q.id})');
    final excel = xl.Excel.createExcel();
    final sheet = excel['Cuestionario'];
    if (excel.sheets.containsKey('Sheet1')) excel.delete('Sheet1');

    int row = 0;
    void set(int c, int r, String v) =>
        sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r)).value = xl.TextCellValue(v);

    set(0, row, l.patientName); set(1, row, q.patientName); row++;
    set(0, row, l.exportTestDate); set(1, row, _dateFmt.format(q.completedAt)); row++;
    set(0, row, l.questionnaireScoreLabel); set(1, row, '${q.cvsqTotalScore}'); row++;
    row++;
    set(0, row, l.questionnaireCvsqSection); row++;
    set(0, row, l.exportItemNumber); set(1, row, l.exportItemName);
    set(2, row, l.exportFrequency); set(3, row, l.exportIntensity); set(4, row, l.exportScore);
    row++;
    for (int i = 0; i < q.cvsqAnswers.length; i++) {
      final a = q.cvsqAnswers[i];
      set(0, row, '${i + 1}');
      set(1, row, _cvsqItemPdfLabel(i, l));
      set(2, row, _freqPdfLabel(a.frequency, l));
      set(3, row, a.intensity == null ? '-' : _intPdfLabel(a.intensity!, l));
      set(4, row, '${a.score}');
      row++;
    }
    row++;
    set(0, row, l.questionnaireFssSection); row++;
    set(0, row, l.exportItemName); set(1, row, l.exportValueScale);
    row++;
    for (int i = 0; i < q.fssAnswers.length; i++) {
      final v = q.fssAnswers[i];
      set(0, row, _fssItemPdfLabel(i, l));
      set(1, row, v == null ? '-' : '$v / 7');
      row++;
    }

    final bytes = excel.encode();
    if (bytes == null) return;
    await _shareFile(Uint8List.fromList(bytes),
        'OptoView_cuestionario_${q.id}.xlsx',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    AppLogger.info('exportQuestionnaireExcel: OK');
  }

  static Future<void> exportQuestionnaireCsv(
    QuestionnaireResult q,
    AppLocalizations l,
  ) async {
    AppLogger.info('exportQuestionnaireCsv: inicio (id=${q.id})');
    final buf = StringBuffer();
    buf.writeln('${l.patientName};${q.patientName}');
    buf.writeln('${l.exportTestDate};${_dateFmt.format(q.completedAt)}');
    buf.writeln('${l.questionnaireScoreLabel};${q.cvsqTotalScore}');
    buf.writeln();
    buf.writeln(l.questionnaireCvsqSection);
    buf.writeln([l.exportItemNumber, l.exportItemName, l.exportFrequency, l.exportIntensity, l.exportScore].join(';'));
    for (int i = 0; i < q.cvsqAnswers.length; i++) {
      final a = q.cvsqAnswers[i];
      buf.writeln([
        i + 1,
        _cvsqItemPdfLabel(i, l),
        _freqPdfLabel(a.frequency, l),
        a.intensity == null ? '-' : _intPdfLabel(a.intensity!, l),
        a.score,
      ].join(';'));
    }
    buf.writeln();
    buf.writeln(l.questionnaireFssSection);
    buf.writeln([l.exportItemName, l.exportValueScale].join(';'));
    for (int i = 0; i < q.fssAnswers.length; i++) {
      final v = q.fssAnswers[i];
      buf.writeln([_fssItemPdfLabel(i, l), v == null ? '-' : '$v / 7'].join(';'));
    }
    await _shareFile(
      Uint8List.fromList(utf8.encode(buf.toString())),
      'OptoView_cuestionario_${q.id}.csv',
      'text/csv',
    );
    AppLogger.info('exportQuestionnaireCsv: OK');
  }

  // ---------------------------------------------------------------------------
  // PDF resumen por paciente
  // ---------------------------------------------------------------------------

  static Future<void> exportPatientSummaryPdf(
    BuildContext context,
    String patientName,
    List<Object> items,
    AppLocalizations l,
  ) async {
    final tests = items.whereType<SavedResult>().toList();
    final questionnaires = items.whereType<QuestionnaireResult>().toList();
    AppLogger.info('exportPatientSummaryPdf: inicio (paciente=$patientName, '
        'tests=${tests.length}, cuestionarios=${questionnaires.length})');

    final doc = pw.Document();
    final now = _dateFmt.format(DateTime.now());

    if (tests.isNotEmpty) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          maxPages: 100,
          build: (ctx) => [
            pw.Text(l.exportPatientReport(patientName),
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(l.exportReportGenerated(now),
                style: const pw.TextStyle(
                    fontSize: 10, color: PdfColors.grey700)),
            pw.Divider(),
            pw.SizedBox(height: 8),
            // Cabecera
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              decoration: const pw.BoxDecoration(
                border:
                    pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400)),
              ),
              child: pw.Row(children: [
                pw.Expanded(
                    flex: 3,
                    child: pw.Text(l.exportTestDate,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Expanded(
                    flex: 3,
                    child: pw.Text(l.exportTestType,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Expanded(
                    flex: 2,
                    child: pw.Text(l.exportAccuracy,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Expanded(
                    flex: 2,
                    child: pw.Text(l.exportReactionTime,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Expanded(
                    flex: 2,
                    child: pw.Text(l.exportDuration,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
              ]),
            ),
            // Filas individuales (paginables por MultiPage)
            ...tests.map((r) {
              final acc = r.accuracy != null
                  ? '${(r.accuracy! * 100).toStringAsFixed(1)}%'
                  : '-';
              final rt = r.avgReactionTimeMs != null
                  ? '${r.avgReactionTimeMs!.toStringAsFixed(0)} ms'
                  : '-';
              return pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 3),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey200)),
                ),
                child: pw.Row(children: [
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text(_dateFmt.format(r.startedAt),
                          style: const pw.TextStyle(fontSize: 9))),
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text(_testTypeLabel(r.testType, l),
                          style: const pw.TextStyle(fontSize: 9))),
                  pw.Expanded(
                      flex: 2,
                      child:
                          pw.Text(acc, style: const pw.TextStyle(fontSize: 9))),
                  pw.Expanded(
                      flex: 2,
                      child:
                          pw.Text(rt, style: const pw.TextStyle(fontSize: 9))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text('${r.durationActualSeconds}s',
                          style: const pw.TextStyle(fontSize: 9))),
                ]),
              );
            }),
          ],
        ),
      );
    }

    if (questionnaires.isNotEmpty) {
      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        maxPages: 100,
        build: (ctx) => [
          pw.Text(l.exportQuestionnaireBulkTitle,
              style:
                  pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(l.exportReportGenerated(now),
              style:
                  const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Divider(),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            decoration: const pw.BoxDecoration(
              border:
                  pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400)),
            ),
            child: pw.Row(children: [
              pw.Expanded(
                  flex: 3,
                  child: pw.Text(l.exportTestDate,
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold))),
              pw.Expanded(
                  flex: 3,
                  child: pw.Text(l.patientName,
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text(l.questionnaireScoreLabel,
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold))),
            ]),
          ),
          ...questionnaires.map((q) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 3),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey200)),
                ),
                child: pw.Row(children: [
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text(_dateFmt.format(q.completedAt),
                          style: const pw.TextStyle(fontSize: 9))),
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                          q.patientName.isNotEmpty ? q.patientName : '-',
                          style: const pw.TextStyle(fontSize: 9))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text('${q.cvsqTotalScore}',
                          style: const pw.TextStyle(fontSize: 9))),
                ]),
              )),
        ],
      ));
    }

    final bytes = await doc.save();
    AppLogger.info(
        'exportPatientSummaryPdf: documento generado (${bytes.length} bytes)');

    await _shareFile(
      bytes,
      'OptoView_resumen_$patientName.pdf',
      'application/pdf',
    );
    AppLogger.info('exportPatientSummaryPdf: compartido OK');
  }

  // ---------------------------------------------------------------------------
  // PDF bulk (selected results)
  // ---------------------------------------------------------------------------

  static Future<void> exportBulkPdf(
    BuildContext context,
    List<Object> items,
    AppLocalizations l,
  ) async {
    final tests = items.whereType<SavedResult>().toList();
    final questionnaires = items.whereType<QuestionnaireResult>().toList();
    AppLogger.info('exportBulkPdf: inicio (tests=${tests.length}, '
        'cuestionarios=${questionnaires.length})');

    final doc = pw.Document();
    final now = _dateFmt.format(DateTime.now());

    if (tests.isNotEmpty) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          maxPages: 100,
          build: (ctx) => [
            pw.Text(l.bulkReportTitle,
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(l.exportReportGenerated(now),
                style: const pw.TextStyle(
                    fontSize: 10, color: PdfColors.grey700)),
            pw.Text('${tests.length} resultados',
                style: const pw.TextStyle(
                    fontSize: 10, color: PdfColors.grey700)),
            pw.Divider(),
            pw.SizedBox(height: 8),
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              decoration: const pw.BoxDecoration(
                border:
                    pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400)),
              ),
              child: pw.Row(children: [
                pw.Expanded(
                    flex: 3,
                    child: pw.Text(l.patientName,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Expanded(
                    flex: 3,
                    child: pw.Text(l.exportTestDate,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Expanded(
                    flex: 2,
                    child: pw.Text(l.exportTestType,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Expanded(
                    flex: 2,
                    child: pw.Text(l.exportAccuracy,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Expanded(
                    flex: 2,
                    child: pw.Text(l.exportReactionTime,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Expanded(
                    flex: 1,
                    child: pw.Text(l.exportDuration,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
              ]),
            ),
            // Rows
            ...tests.map((r) {
              final acc = r.accuracy != null
                  ? '${(r.accuracy! * 100).toStringAsFixed(1)}%'
                  : '-';
              final rt = r.avgReactionTimeMs != null
                  ? '${r.avgReactionTimeMs!.toStringAsFixed(0)} ms'
                  : '-';
              return pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 3),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey200)),
                ),
                child: pw.Row(children: [
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                          r.patientName.isNotEmpty ? r.patientName : '-',
                          style: const pw.TextStyle(fontSize: 9))),
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text(_dateFmt.format(r.startedAt),
                          style: const pw.TextStyle(fontSize: 9))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text(_testTypeLabel(r.testType, l),
                          style: const pw.TextStyle(fontSize: 9))),
                  pw.Expanded(
                      flex: 2,
                      child:
                          pw.Text(acc, style: const pw.TextStyle(fontSize: 9))),
                  pw.Expanded(
                      flex: 2,
                      child:
                          pw.Text(rt, style: const pw.TextStyle(fontSize: 9))),
                  pw.Expanded(
                      flex: 1,
                      child: pw.Text('${r.durationActualSeconds}s',
                          style: const pw.TextStyle(fontSize: 9))),
                ]),
              );
            }),
          ],
        ),
      );
    }

    if (questionnaires.isNotEmpty) {
      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        maxPages: 100,
        build: (ctx) => [
          pw.Text(l.exportQuestionnaireBulkTitle,
              style:
                  pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(l.exportReportGenerated(now),
              style:
                  const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Divider(),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            decoration: const pw.BoxDecoration(
              border:
                  pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400)),
            ),
            child: pw.Row(children: [
              pw.Expanded(
                  flex: 3,
                  child: pw.Text(l.exportTestDate,
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold))),
              pw.Expanded(
                  flex: 3,
                  child: pw.Text(l.patientName,
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text(l.questionnaireScoreLabel,
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold))),
            ]),
          ),
          ...questionnaires.map((q) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 3),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey200)),
                ),
                child: pw.Row(children: [
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text(_dateFmt.format(q.completedAt),
                          style: const pw.TextStyle(fontSize: 9))),
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                          q.patientName.isNotEmpty ? q.patientName : '-',
                          style: const pw.TextStyle(fontSize: 9))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text('${q.cvsqTotalScore}',
                          style: const pw.TextStyle(fontSize: 9))),
                ]),
              )),
        ],
      ));
    }

    final bytes = await doc.save();
    AppLogger.info('exportBulkPdf: documento generado (${bytes.length} bytes)');

    final now2 = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    await _shareFile(
      bytes,
      'OptoView_seleccion_$now2.pdf',
      'application/pdf',
    );
    AppLogger.info('exportBulkPdf: compartido OK');
  }

  // ---------------------------------------------------------------------------
  // Excel bulk (selected results)
  // ---------------------------------------------------------------------------

  static Future<void> exportBulkExcel(
    List<Object> items,
    AppLocalizations l,
  ) async {
    final tests = items.whereType<SavedResult>().toList();
    final questionnaires = items.whereType<QuestionnaireResult>().toList();
    AppLogger.info('exportBulkExcel: inicio (tests=${tests.length}, '
        'cuestionarios=${questionnaires.length})');
    final excel = xl.Excel.createExcel();

    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    if (tests.isNotEmpty) {
      final sheet = excel['Tests'];
      final headers = [
        l.patientName,
        l.exportTestDate,
        l.exportTestType,
        l.exportAccuracy,
        l.exportReactionTime,
        l.exportDuration,
        l.statsStimuliShown,
      ];
      for (int c = 0; c < headers.length; c++) {
        sheet
            .cell(xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0))
            .value = xl.TextCellValue(headers[c]);
      }

      for (int r = 0; r < tests.length; r++) {
        final res = tests[r];
        final row = r + 1;
        final acc = res.accuracy != null
            ? '${(res.accuracy! * 100).toStringAsFixed(1)}%'
            : '-';
        final rt = res.avgReactionTimeMs != null
            ? '${res.avgReactionTimeMs!.toStringAsFixed(0)} ms'
            : '-';
        final values = [
          res.patientName.isNotEmpty ? res.patientName : '-',
          _dateFmt.format(res.startedAt),
          _testTypeLabel(res.testType, l),
          acc,
          rt,
          '${res.durationActualSeconds}s',
          '${res.totalStimuliShown}',
        ];
        for (int c = 0; c < values.length; c++) {
          sheet
              .cell(xl.CellIndex.indexByColumnRow(
                  columnIndex: c, rowIndex: row))
              .value = xl.TextCellValue(values[c]);
        }
      }
    }

    if (questionnaires.isNotEmpty) {
      final sheet = excel['Cuestionarios'];
      final headers = [
        l.exportTestDate,
        l.patientName,
        l.questionnaireScoreLabel,
      ];
      for (int c = 0; c < headers.length; c++) {
        sheet
            .cell(xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0))
            .value = xl.TextCellValue(headers[c]);
      }
      for (int r = 0; r < questionnaires.length; r++) {
        final q = questionnaires[r];
        final row = r + 1;
        final values = [
          _dateFmt.format(q.completedAt),
          q.patientName.isNotEmpty ? q.patientName : '-',
          '${q.cvsqTotalScore}',
        ];
        for (int c = 0; c < values.length; c++) {
          sheet
              .cell(xl.CellIndex.indexByColumnRow(
                  columnIndex: c, rowIndex: row))
              .value = xl.TextCellValue(values[c]);
        }
      }
    }

    final bytes = excel.encode();
    if (bytes == null) {
      AppLogger.warning('exportBulkExcel: encode() devolvió null');
      return;
    }

    final now = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    await _shareFile(
      Uint8List.fromList(bytes),
      'OptoView_seleccion_$now.xlsx',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    AppLogger.info('exportBulkExcel: compartido OK');
  }

  // ---------------------------------------------------------------------------
  // CSV bulk (selected results)
  // ---------------------------------------------------------------------------

  static String _buildTestsBulkCsv(
      List<SavedResult> results, AppLocalizations l) {
    final buf = StringBuffer();
    buf.writeln([
      l.patientName,
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
        r.patientName.isNotEmpty ? r.patientName : '-',
        _dateFmt.format(r.startedAt),
        _testTypeLabel(r.testType, l),
        acc,
        rt,
        '${r.durationActualSeconds}',
        '${r.totalStimuliShown}',
      ].join(';'));
    }
    return buf.toString();
  }

  static String _buildQuestionnaireBulkCsv(
      List<QuestionnaireResult> qs, AppLocalizations l) {
    final buf = StringBuffer();
    buf.writeln(
        [l.exportTestDate, l.patientName, l.questionnaireScoreLabel].join(';'));
    for (final q in qs) {
      buf.writeln([
        _dateFmt.format(q.completedAt),
        q.patientName.isNotEmpty ? q.patientName : '-',
        q.cvsqTotalScore,
      ].join(';'));
    }
    return buf.toString();
  }

  static Future<void> exportBulkCsv(
    List<Object> items,
    AppLocalizations l,
  ) async {
    final tests = items.whereType<SavedResult>().toList();
    final questionnaires = items.whereType<QuestionnaireResult>().toList();
    AppLogger.info('exportBulkCsv: inicio (tests=${tests.length}, '
        'cuestionarios=${questionnaires.length})');

    final now = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());

    if (tests.isNotEmpty && questionnaires.isNotEmpty) {
      final testsCsv = _buildTestsBulkCsv(tests, l);
      final qCsv = _buildQuestionnaireBulkCsv(questionnaires, l);
      final archive = Archive();
      final testsBytes = utf8.encode(testsCsv);
      final qBytes = utf8.encode(qCsv);
      archive
          .addFile(ArchiveFile('tests.csv', testsBytes.length, testsBytes));
      archive.addFile(
          ArchiveFile('cuestionarios.csv', qBytes.length, qBytes));
      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes == null) {
        AppLogger.warning('exportBulkCsv: ZipEncoder.encode() devolvió null');
        return;
      }
      await _shareFile(Uint8List.fromList(zipBytes),
          'OptoView_seleccion_$now.zip', 'application/zip');
      AppLogger.info('exportBulkCsv: compartido OK (ZIP)');
      return;
    }

    if (tests.isNotEmpty) {
      final csv = _buildTestsBulkCsv(tests, l);
      await _shareFile(Uint8List.fromList(utf8.encode(csv)),
          'OptoView_seleccion_$now.csv', 'text/csv');
      AppLogger.info('exportBulkCsv: compartido OK (tests)');
      return;
    }

    if (questionnaires.isNotEmpty) {
      final csv = _buildQuestionnaireBulkCsv(questionnaires, l);
      await _shareFile(Uint8List.fromList(utf8.encode(csv)),
          'OptoView_cuestionarios_$now.csv', 'text/csv');
      AppLogger.info('exportBulkCsv: compartido OK (cuestionarios)');
      return;
    }
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
    List<Object> items,
    AppLocalizations l,
  ) async {
    final tests = items.whereType<SavedResult>().toList();
    final questionnaires = items.whereType<QuestionnaireResult>().toList();
    AppLogger.info('exportPatientSummaryExcel: inicio (paciente=$patientName, '
        'tests=${tests.length}, cuestionarios=${questionnaires.length})');
    final excel = xl.Excel.createExcel();

    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    if (tests.isNotEmpty) {
      final sheet = excel['Tests'];
      final headers = [
        l.exportTestDate,
        l.exportTestType,
        l.exportAccuracy,
        l.exportReactionTime,
        l.exportDuration,
        l.statsStimuliShown,
      ];
      for (int c = 0; c < headers.length; c++) {
        sheet
            .cell(xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0))
            .value = xl.TextCellValue(headers[c]);
      }

      for (int r = 0; r < tests.length; r++) {
        final res = tests[r];
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
          sheet
              .cell(xl.CellIndex.indexByColumnRow(
                  columnIndex: c, rowIndex: row))
              .value = xl.TextCellValue(values[c]);
        }
      }
    }

    if (questionnaires.isNotEmpty) {
      final sheet = excel['Cuestionarios'];
      final headers = [
        l.exportTestDate,
        l.patientName,
        l.questionnaireScoreLabel,
      ];
      for (int c = 0; c < headers.length; c++) {
        sheet
            .cell(xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0))
            .value = xl.TextCellValue(headers[c]);
      }
      for (int r = 0; r < questionnaires.length; r++) {
        final q = questionnaires[r];
        final row = r + 1;
        final values = [
          _dateFmt.format(q.completedAt),
          q.patientName.isNotEmpty ? q.patientName : '-',
          '${q.cvsqTotalScore}',
        ];
        for (int c = 0; c < values.length; c++) {
          sheet
              .cell(xl.CellIndex.indexByColumnRow(
                  columnIndex: c, rowIndex: row))
              .value = xl.TextCellValue(values[c]);
        }
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
      Uint8List.fromList(utf8.encode(buf.toString())),
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
    List<Object> items,
    AppLocalizations l,
  ) async {
    final tests = items.whereType<SavedResult>().toList();
    final questionnaires = items.whereType<QuestionnaireResult>().toList();
    AppLogger.info('exportPatientSummaryCsv: inicio (paciente=$patientName, '
        'tests=${tests.length}, cuestionarios=${questionnaires.length})');
    final buf = StringBuffer();

    if (tests.isNotEmpty) {
      buf.writeln(l.bulkReportTitle);
      buf.writeln([
        l.exportTestDate,
        l.exportTestType,
        l.exportAccuracy,
        l.exportReactionTime,
        l.exportDuration,
        l.statsStimuliShown,
      ].join(';'));

      for (final r in tests) {
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
    }

    if (questionnaires.isNotEmpty) {
      if (tests.isNotEmpty) buf.writeln();
      buf.writeln(l.exportQuestionnaireBulkTitle);
      buf.writeln([
        l.exportTestDate,
        l.patientName,
        l.questionnaireScoreLabel,
      ].join(';'));
      for (final q in questionnaires) {
        buf.writeln([
          _dateFmt.format(q.completedAt),
          q.patientName.isNotEmpty ? q.patientName : '-',
          q.cvsqTotalScore,
        ].join(';'));
      }
    }

    await _shareFile(
      Uint8List.fromList(utf8.encode(buf.toString())),
      'OptoView_resumen_$patientName.csv',
      'text/csv',
    );
    AppLogger.info('exportPatientSummaryCsv: compartido OK');
  }

  // ---------------------------------------------------------------------------
  // Helpers cuestionario
  // ---------------------------------------------------------------------------

  static String _cvsqItemPdfLabel(int i, AppLocalizations l) {
    switch (i) {
      case 0: return l.cvsqItem1; case 1: return l.cvsqItem2;
      case 2: return l.cvsqItem3; case 3: return l.cvsqItem4;
      case 4: return l.cvsqItem5; case 5: return l.cvsqItem6;
      case 6: return l.cvsqItem7; case 7: return l.cvsqItem8;
      case 8: return l.cvsqItem9; case 9: return l.cvsqItem10;
      case 10: return l.cvsqItem11; case 11: return l.cvsqItem12;
      case 12: return l.cvsqItem13; case 13: return l.cvsqItem14;
      case 14: return l.cvsqItem15; case 15: return l.cvsqItem16;
      default: throw StateError('invalid CVS-Q index $i');
    }
  }

  static String _fssItemPdfLabel(int i, AppLocalizations l) {
    switch (i) {
      case 0: return l.fssItem1; case 1: return l.fssItem2;
      case 2: return l.fssItem3; case 3: return l.fssItem4;
      case 4: return l.fssItem5;
      default: throw StateError('invalid FSS index $i');
    }
  }

  static String _freqPdfLabel(CvsqFrequency f, AppLocalizations l) => switch (f) {
        CvsqFrequency.never => l.cvsqFreqNever,
        CvsqFrequency.occasional => l.cvsqFreqOccasional,
        CvsqFrequency.habitual => l.cvsqFreqHabitual,
      };

  static String _intPdfLabel(CvsqIntensity i, AppLocalizations l) => switch (i) {
        CvsqIntensity.moderate => l.cvsqIntModerate,
        CvsqIntensity.intense => l.cvsqIntIntense,
      };
}
