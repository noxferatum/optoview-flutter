import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import '../l10n/app_localizations.dart';
import '../models/macdonald_result.dart';
import '../models/saved_result.dart';
import '../services/app_logger.dart';
import '../services/export_service.dart';
import '../services/results_storage.dart';
import '../theme/opto_colors.dart';
import '../theme/opto_spacing.dart';

enum _HistoryViewMode { byPatient, byDate }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<SavedResult> _results = [];
  bool _isLoading = true;
  String _searchQuery = '';
  _HistoryViewMode _viewMode = _HistoryViewMode.byPatient;
  final _searchController = TextEditingController();

  // Selection mode
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  // Master-detail
  String? _selectedResultId;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadResults() async {
    final results = await ResultsStorage.loadAll();
    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  /// Filtra resultados por nombre de paciente o tipo de test.
  List<SavedResult> get _filteredResults {
    if (_searchQuery.isEmpty) return _results;
    final q = _searchQuery.toLowerCase();
    final l = AppLocalizations.of(context)!;
    return _results.where((r) {
      final name = r.patientName.toLowerCase();
      final type = _testTypeLabel(r.testType, l).toLowerCase();
      return name.contains(q) || type.contains(q);
    }).toList();
  }

  /// Agrupa resultados por paciente, ordenados: primero con nombre, luego sin nombre.
  Map<String, List<SavedResult>> _groupByPatient(List<SavedResult> results) {
    final groups = <String, List<SavedResult>>{};
    for (final r in results) {
      final key = r.patientName.isNotEmpty ? r.patientName : '';
      groups.putIfAbsent(key, () => []).add(r);
    }
    // Ordenar cada grupo por fecha descendente.
    for (final list in groups.values) {
      list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    }
    return groups;
  }

  void _confirmDeleteAll(AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.historyClearAllTitle),
        content: Text(l.historyClearAllMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.historyCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ResultsStorage.deleteAll();
              setState(() {
                _results.clear();
                _selectedResultId = null;
              });
            },
            child: Text(l.historyClearAllConfirm),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(SavedResult result, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.historyDeleteTitle),
        content: Text(l.historyDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.historyCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ResultsStorage.delete(result.id);
              setState(() {
                _results.removeWhere((r) => r.id == result.id);
                if (_selectedResultId == result.id) {
                  _selectedResultId = null;
                }
              });
            },
            child: Text(l.historyDelete),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Selection mode
  // ---------------------------------------------------------------------------

  void _enterSelectionMode(SavedResult result) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(result.id);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(SavedResult result) {
    setState(() {
      if (_selectedIds.contains(result.id)) {
        _selectedIds.remove(result.id);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(result.id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIds.addAll(_filteredResults.map((r) => r.id));
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedIds.clear();
      _selectionMode = false;
    });
  }

  List<SavedResult> get _selectedResults =>
      _results.where((r) => _selectedIds.contains(r.id)).toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  Future<void> _bulkExport(String format, AppLocalizations l) async {
    final selected = _selectedResults;
    if (selected.isEmpty) return;

    try {
      switch (format) {
        case 'pdf':
          await ExportService.exportBulkPdf(context, selected, l);
          break;
        case 'excel':
          await ExportService.exportBulkExcel(selected, l);
          break;
        case 'csv':
          await ExportService.exportBulkCsv(selected, l);
          break;
      }
    } catch (e, st) {
      AppLogger.error('bulkExport($format)', error: e, stackTrace: st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Rename
  // ---------------------------------------------------------------------------

  void _showRenameDialog(SavedResult result, AppLocalizations l,
      {VoidCallback? onRenamed}) {
    final controller = TextEditingController(text: result.patientName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.renameTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l.renameHint),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.historyCancel),
          ),
          FilledButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isEmpty || newName == result.patientName) {
                Navigator.pop(ctx);
                return;
              }
              final updated = result.copyWith(patientName: newName);
              ResultsStorage.update(updated);
              setState(() {
                final idx = _results.indexWhere((r) => r.id == result.id);
                if (idx != -1) _results[idx] = updated;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.renameSuccess)),
              );
              onRenamed?.call();
            },
            child: Text(l.renameSave),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Backup export / import
  // ---------------------------------------------------------------------------

  Future<void> _exportBackup(AppLocalizations l) async {
    if (_results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.backupNoResults)),
      );
      return;
    }

    final json = await ResultsStorage.exportAllJson();
    final bytes = Uint8List.fromList(json.codeUnits);
    final now = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());

    await Share.shareXFiles([
      XFile.fromData(
        bytes,
        name: 'OptoView_backup_$now.json',
        mimeType: 'application/json',
      ),
    ]);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.backupExportSuccess(_results.length))),
      );
    }
  }

  Future<void> _importBackup(AppLocalizations l) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    final jsonString = String.fromCharCodes(file.bytes!);
    final count = await ResultsStorage.importFromJson(jsonString);

    if (!mounted) return;

    if (count < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.backupImportError)),
      );
    } else if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.backupImportNone)),
      );
    } else {
      await _loadResults();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.backupImportSuccess(count))),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Patient summary export
  // ---------------------------------------------------------------------------

  void _showPatientSummaryExport(AppLocalizations l) {
    // Group results by patient name
    final patients = <String, List<SavedResult>>{};
    for (final r in _results) {
      final name = r.patientName.isNotEmpty ? r.patientName : '-';
      patients.putIfAbsent(name, () => []).add(r);
    }

    if (patients.length == 1) {
      // Only one patient (or no names) → show format picker directly
      _showFormatPicker(patients.keys.first, patients.values.first, l);
      return;
    }

    // Multiple patients → show patient selector
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l.exportSelectPatient,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          ...patients.entries.map(
            (e) => ListTile(
              leading: const Icon(Icons.person),
              title: Text(e.key),
              subtitle: Text('${e.value.length} resultados'),
              onTap: () {
                Navigator.pop(ctx);
                _showFormatPicker(e.key, e.value, l);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFormatPicker(
      String patientName, List<SavedResult> results, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.exportPatientReport(patientName),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      await ExportService.exportPatientSummaryPdf(
                          context, patientName, results, l);
                    } catch (e, st) {
                      AppLogger.error('exportPatientSummaryPdf', error: e, stackTrace: st);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error PDF: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(l.exportPdf),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      await ExportService.exportPatientSummaryExcel(
                          patientName, results, l);
                    } catch (e, st) {
                      AppLogger.error('exportPatientSummaryExcel', error: e, stackTrace: st);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error Excel: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.table_chart),
                  label: Text(l.exportExcel),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      await ExportService.exportPatientSummaryCsv(
                          patientName, results, l);
                    } catch (e, st) {
                      AppLogger.error('exportPatientSummaryCsv', error: e, stackTrace: st);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error CSV: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.description),
                  label: Text(l.exportCsv),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _testTypeLabel(String type, AppLocalizations l) => switch (type) {
        'peripheral' => l.historyTestPeripheral,
        'localization' => l.historyTestLocalization,
        'macdonald' => l.historyTestMacdonald,
        _ => type,
      };

  IconData _testTypeIcon(String type) => switch (type) {
        'peripheral' => Icons.blur_on,
        'localization' => Icons.touch_app,
        'macdonald' => Icons.grid_on,
        _ => Icons.science,
      };

  Color _testTypeColor(String type) => switch (type) {
        'peripheral' => OptoColors.peripheral,
        'localization' => OptoColors.localization,
        'macdonald' => OptoColors.macdonald,
        _ => OptoColors.primary,
      };

  String _keyMetric(SavedResult r) {
    if (r.accuracy != null) {
      return '${(r.accuracy! * 100).toStringAsFixed(0)}%';
    }
    if (r.stimuliPerMinute != null) {
      return '${r.stimuliPerMinute!.toStringAsFixed(0)}/min';
    }
    return '${r.durationActualSeconds}s';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    if (_isLoading) {
      return Scaffold(
        backgroundColor: OptoColors.backgroundDark,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: OptoColors.backgroundDark,
      body: Column(
        children: [
          _buildTopBar(l),
          _buildFilterBar(l),
          Expanded(
            child: _results.isEmpty
                ? _buildEmptyState(l)
                : Row(
                    children: [
                      // LEFT: list panel (380px)
                      SizedBox(
                        width: 380,
                        child: _buildListPanel(l, dateFmt),
                      ),
                      // Divider
                      const VerticalDivider(
                        width: 1,
                        color: OptoColors.surfaceVariantDark,
                      ),
                      // RIGHT: detail panel
                      Expanded(child: _buildDetailPanel(l, dateFmt)),
                    ],
                  ),
          ),
          // Bottom bar for selection mode
          if (_selectionMode && _selectedIds.isNotEmpty) _buildSelectionBar(l),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top bar
  // ---------------------------------------------------------------------------

  Widget _buildTopBar(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OptoSpacing.sm,
        vertical: OptoSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: OptoColors.surfaceDark,
        border: Border(
          bottom: BorderSide(color: OptoColors.surfaceVariantDark),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: _selectionMode
            ? Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: OptoColors.onSurfaceDark),
                    onPressed: _exitSelectionMode,
                  ),
                  const SizedBox(width: OptoSpacing.sm),
                  Expanded(
                    child: Text(
                      l.bulkSelectedCount(_selectedIds.length),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: OptoColors.onSurfaceDark,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.select_all,
                        color: OptoColors.onSurfaceDark),
                    tooltip: _selectedIds.length == _filteredResults.length
                        ? l.bulkDeselectAll
                        : l.bulkSelectAll,
                    onPressed: _selectedIds.length == _filteredResults.length
                        ? _deselectAll
                        : _selectAll,
                  ),
                ],
              )
            : Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: OptoColors.onSurfaceDark),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: OptoSpacing.sm),
                  Expanded(
                    child: Text(
                      l.historyTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: OptoColors.onSurfaceDark,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_download,
                        color: OptoColors.onSurfaceDark),
                    tooltip: l.backupImportTooltip,
                    onPressed: () => _importBackup(l),
                  ),
                  if (_results.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.file_upload,
                          color: OptoColors.onSurfaceDark),
                      tooltip: l.backupExportTooltip,
                      onPressed: () => _exportBackup(l),
                    ),
                  if (_results.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.summarize,
                          color: OptoColors.onSurfaceDark),
                      tooltip: l.exportPatientSummary,
                      onPressed: () => _showPatientSummaryExport(l),
                    ),
                  if (_results.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_sweep,
                          color: OptoColors.onSurfaceDark),
                      tooltip: l.historyClearAll,
                      onPressed: () => _confirmDeleteAll(l),
                    ),
                ],
              ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Filter bar
  // ---------------------------------------------------------------------------

  Widget _buildFilterBar(AppLocalizations l) {
    if (_results.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(
        OptoSpacing.md,
        OptoSpacing.sm,
        OptoSpacing.md,
        OptoSpacing.xs,
      ),
      color: OptoColors.backgroundDark,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: OptoColors.onSurfaceDark),
              decoration: InputDecoration(
                hintText: l.historySearchHint,
                hintStyle:
                    const TextStyle(color: OptoColors.onSurfaceVariantDark),
                prefixIcon: const Icon(Icons.search,
                    color: OptoColors.onSurfaceVariantDark),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: OptoColors.onSurfaceVariantDark),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: OptoColors.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
                  borderSide:
                      const BorderSide(color: OptoColors.surfaceVariantDark),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
                  borderSide:
                      const BorderSide(color: OptoColors.surfaceVariantDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
                  borderSide: const BorderSide(color: OptoColors.primary),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
            ),
          ),
          const SizedBox(width: 12),
          SegmentedButton<_HistoryViewMode>(
            segments: [
              ButtonSegment(
                value: _HistoryViewMode.byPatient,
                icon: const Icon(Icons.person, size: 18),
                label: Text(l.historyGroupByPatient),
              ),
              ButtonSegment(
                value: _HistoryViewMode.byDate,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(l.historyOrderByDate),
              ),
            ],
            selected: {_viewMode},
            onSelectionChanged: (v) => setState(() => _viewMode = v.first),
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // List panel (left)
  // ---------------------------------------------------------------------------

  Widget _buildListPanel(AppLocalizations l, DateFormat dateFmt) {
    final theme = Theme.of(context);
    final filtered = _filteredResults;

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          l.historyNoResults,
          style: const TextStyle(color: OptoColors.onSurfaceVariantDark),
        ),
      );
    }

    return Container(
      color: OptoColors.backgroundDark,
      child: _viewMode == _HistoryViewMode.byPatient
          ? _buildPatientGroupedView(filtered, l, dateFmt, theme)
          : _buildDateSortedView(filtered, l, dateFmt, theme),
    );
  }

  // ---------------------------------------------------------------------------
  // Detail panel (right)
  // ---------------------------------------------------------------------------

  Widget _buildDetailPanel(AppLocalizations l, DateFormat dateFmt) {
    final theme = Theme.of(context);

    if (_selectedResultId == null) {
      return Container(
        color: OptoColors.backgroundDark,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.article_outlined,
                  size: 48, color: OptoColors.subtleDark),
              const SizedBox(height: OptoSpacing.md),
              Text(
                'Selecciona un resultado',
                style: TextStyle(
                  fontSize: 14,
                  color: OptoColors.onSurfaceVariantDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final current = _results.firstWhere(
      (r) => r.id == _selectedResultId,
      orElse: () {
        // Result was deleted; clear selection.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedResultId = null);
        });
        return _results.isNotEmpty ? _results.first : _results.first;
      },
    );

    // If the result list is empty (shouldn't normally happen because we
    // check _results.isEmpty higher up), bail out.
    if (_results.isEmpty) {
      return const SizedBox.shrink();
    }

    final typeColor = _testTypeColor(current.testType);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(current.id),
        color: OptoColors.backgroundDark,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(OptoSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(OptoSpacing.sm),
                    decoration: BoxDecoration(
                      color: typeColor.withAlpha(30),
                      borderRadius:
                          BorderRadius.circular(OptoSpacing.radiusChip),
                    ),
                    child: Icon(
                      _testTypeIcon(current.testType),
                      color: typeColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: OptoSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _testTypeLabel(current.testType, l),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: OptoColors.onSurfaceDark,
                          ),
                        ),
                        if (current.patientName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  size: 14,
                                  color: OptoColors.onSurfaceVariantDark),
                              const SizedBox(width: 4),
                              Text(
                                current.patientName,
                                style: const TextStyle(
                                  color: OptoColors.onSurfaceVariantDark,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          dateFmt.format(current.startedAt),
                          style: const TextStyle(
                            color: OptoColors.subtleDark,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit,
                        size: 20, color: OptoColors.onSurfaceVariantDark),
                    tooltip: l.renameTitle,
                    onPressed: () {
                      _showRenameDialog(current, l);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: OptoColors.error),
                    tooltip: l.historyDelete,
                    onPressed: () => _confirmDelete(current, l),
                  ),
                ],
              ),

              const SizedBox(height: OptoSpacing.md),
              const Divider(color: OptoColors.surfaceVariantDark, height: 1),
              const SizedBox(height: OptoSpacing.md),

              // Metrics
              _DetailRow(
                label: l.statsActualDuration,
                value: '${current.durationActualSeconds}s',
              ),
              _DetailRow(
                label: l.statsStimuliShown,
                value: '${current.totalStimuliShown}',
              ),
              if (current.correctTouches != null)
                _DetailRow(
                  label: l.accuracyCorrect,
                  value: '${current.correctTouches}',
                ),
              if (current.incorrectTouches != null)
                _DetailRow(
                  label: l.accuracyErrors,
                  value: '${current.incorrectTouches}',
                ),
              if (current.missedStimuli != null)
                _DetailRow(
                  label: l.accuracyMissed,
                  value: '${current.missedStimuli}',
                ),
              if (current.accuracy != null)
                _DetailRow(
                  label: l.accuracyPercent,
                  value: '${(current.accuracy! * 100).toStringAsFixed(1)}%',
                ),
              if (current.avgReactionTimeMs != null)
                _DetailRow(
                  label: l.reactionAvg,
                  value:
                      '${current.avgReactionTimeMs!.toStringAsFixed(0)} ms',
                ),
              if (current.bestReactionTimeMs != null)
                _DetailRow(
                  label: l.reactionBest,
                  value:
                      '${current.bestReactionTimeMs!.toStringAsFixed(0)} ms',
                ),
              if (current.worstReactionTimeMs != null)
                _DetailRow(
                  label: l.reactionWorst,
                  value:
                      '${current.worstReactionTimeMs!.toStringAsFixed(0)} ms',
                ),
              if (current.stimuliPerMinute != null)
                _DetailRow(
                  label: l.statsStimuliPerMinute,
                  value: current.stimuliPerMinute!.toStringAsFixed(1),
                ),
              if (current.anillosCompletados != null)
                _DetailRow(
                  label: l.macStatsRingsCompleted,
                  value: '${current.anillosCompletados}',
                ),
              if (current.tiempoPorAnillo != null) ...[
                const SizedBox(height: 8),
                ...current.tiempoPorAnillo!.asMap().entries.map(
                      (e) => _DetailRow(
                        label: l.macRingLabel(e.key + 1),
                        value: '${(e.value / 1000).toStringAsFixed(1)}s',
                      ),
                    ),
              ],

              // Hit/miss maps (MacDonald)
              if (current.letterEvents != null &&
                  current.letterEvents!.isNotEmpty) ...[
                const SizedBox(height: OptoSpacing.md),
                const Divider(
                    color: OptoColors.surfaceVariantDark, height: 1),
                const SizedBox(height: OptoSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(l.macHitMapTitle,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: OptoColors.onSurfaceDark,
                              )),
                          const SizedBox(height: 8),
                          AspectRatio(
                            aspectRatio: 1,
                            child: CustomPaint(
                              painter: _HitMapPainter(
                                events: current.letterEvents!
                                    .where((e) => e.isHit)
                                    .toList(),
                                dotColor: Colors.greenAccent,
                                numRings: current.anillosCompletados ?? 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        children: [
                          Text(l.macMissMapTitle,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: OptoColors.onSurfaceDark,
                              )),
                          const SizedBox(height: 8),
                          AspectRatio(
                            aspectRatio: 1,
                            child: CustomPaint(
                              painter: _HitMapPainter(
                                events: current.letterEvents!
                                    .where((e) => !e.isHit)
                                    .toList(),
                                dotColor: Colors.redAccent,
                                numRings: current.anillosCompletados ?? 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              // Config summary
              if (current.configSummary.isNotEmpty) ...[
                const SizedBox(height: OptoSpacing.md),
                const Divider(
                    color: OptoColors.surfaceVariantDark, height: 1),
                const SizedBox(height: OptoSpacing.md),
                Text(
                  l.configUsedTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: OptoColors.onSurfaceDark,
                  ),
                ),
                const SizedBox(height: 8),
                ...current.configSummary.entries.map(
                  (e) => _DetailRow(label: e.key, value: e.value),
                ),
              ],

              // Export buttons
              const SizedBox(height: OptoSpacing.md),
              const Divider(color: OptoColors.surfaceVariantDark, height: 1),
              const SizedBox(height: OptoSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await ExportService.exportResultPdf(
                            context, current, l);
                      } catch (e, st) {
                        AppLogger.error('exportResultPdf',
                            error: e, stackTrace: st);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error PDF: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: Text(l.exportPdf),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await ExportService.exportResultExcel(current, l);
                      } catch (e, st) {
                        AppLogger.error('exportResultExcel',
                            error: e, stackTrace: st);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error Excel: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.table_chart, size: 18),
                    label: Text(l.exportExcel),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await ExportService.exportResultCsv(current, l);
                      } catch (e, st) {
                        AppLogger.error('exportResultCsv',
                            error: e, stackTrace: st);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error CSV: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.description, size: 18),
                    label: Text(l.exportCsv),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Selection bar (bottom)
  // ---------------------------------------------------------------------------

  Widget _buildSelectionBar(AppLocalizations l) {
    final theme = Theme.of(context);

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: OptoSpacing.md, vertical: OptoSpacing.sm),
      decoration: const BoxDecoration(
        color: OptoColors.surfaceDark,
        border: Border(
          top: BorderSide(color: OptoColors.surfaceVariantDark),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Text(
              l.bulkExportTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: OptoColors.onSurfaceDark,
              ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => _bulkExport('pdf', l),
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: Text(l.exportPdf),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _bulkExport('excel', l),
              icon: const Icon(Icons.table_chart, size: 18),
              label: Text(l.exportExcel),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _bulkExport('csv', l),
              icon: const Icon(Icons.description, size: 18),
              label: Text(l.exportCsv),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 64, color: OptoColors.subtleDark),
          const SizedBox(height: 16),
          Text(
            l.historyEmpty,
            style: const TextStyle(
              fontSize: 14,
              color: OptoColors.onSurfaceVariantDark,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _importBackup(l),
            icon: const Icon(Icons.file_download),
            label: Text(l.backupImport),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Result tile
  // ---------------------------------------------------------------------------

  Widget _buildResultTile(
      SavedResult r, AppLocalizations l, DateFormat dateFmt, ThemeData theme,
      {bool showPatientName = false}) {
    final isSelected = _selectedIds.contains(r.id);
    final isDetailSelected = r.id == _selectedResultId;
    final typeColor = _testTypeColor(r.testType);

    final tile = Container(
      decoration: BoxDecoration(
        color: isDetailSelected
            ? OptoColors.surfaceVariantDark
            : Colors.transparent,
        border: isDetailSelected
            ? const Border(
                left: BorderSide(color: OptoColors.primary, width: 3),
              )
            : null,
      ),
      child: ListTile(
        leading: _selectionMode
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleSelection(r),
              )
            : CircleAvatar(
                radius: 18,
                backgroundColor: typeColor.withAlpha(30),
                child: Icon(_testTypeIcon(r.testType),
                    size: 18, color: typeColor),
              ),
        title: Text(
          _testTypeLabel(r.testType, l),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: OptoColors.onSurfaceDark,
            fontWeight: isDetailSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        subtitle: Text(
          showPatientName && r.patientName.isNotEmpty
              ? '${r.patientName} · ${dateFmt.format(r.startedAt)}'
              : dateFmt.format(r.startedAt),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: OptoColors.onSurfaceVariantDark, fontSize: 12),
        ),
        trailing: Text(
          _keyMetric(r),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDetailSelected ? OptoColors.primary : OptoColors.onSurfaceDark,
          ),
        ),
        selected: isSelected,
        onTap: _selectionMode
            ? () => _toggleSelection(r)
            : () => setState(() => _selectedResultId = r.id),
        onLongPress: _selectionMode ? null : () => _enterSelectionMode(r),
      ),
    );

    if (_selectionMode) return tile;

    return Dismissible(
      key: ValueKey(r.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        _confirmDelete(r, l);
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: OptoColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: tile,
    );
  }

  Widget _buildPatientGroupedView(List<SavedResult> filtered,
      AppLocalizations l, DateFormat dateFmt, ThemeData theme) {
    final groups = _groupByPatient(filtered);

    // Ordenar grupos: con nombre alfabéticamente, sin nombre al final.
    final sortedKeys = groups.keys.toList()
      ..sort((a, b) {
        if (a.isEmpty && b.isEmpty) return 0;
        if (a.isEmpty) return 1;
        if (b.isEmpty) return -1;
        return a.toLowerCase().compareTo(b.toLowerCase());
      });

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, groupIndex) {
        final patientName = sortedKeys[groupIndex];
        final items = groups[patientName]!;
        final displayName =
            patientName.isNotEmpty ? patientName : l.historyUnnamedPatient;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera del grupo
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  const Icon(Icons.person,
                      size: 18, color: OptoColors.onSurfaceVariantDark),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      displayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: OptoColors.onSurfaceDark,
                      ),
                    ),
                  ),
                  Text(
                    l.historyResultCount(items.length),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: OptoColors.onSurfaceVariantDark,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: OptoColors.surfaceVariantDark),
            // Resultados del grupo
            ...items.map(
                (r) => _buildResultTile(r, l, dateFmt, theme)),
          ],
        );
      },
    );
  }

  Widget _buildDateSortedView(List<SavedResult> filtered, AppLocalizations l,
      DateFormat dateFmt, ThemeData theme) {
    final sorted = List<SavedResult>.from(filtered)
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: sorted.length,
      itemBuilder: (context, index) =>
          _buildResultTile(sorted[index], l, dateFmt, theme, showPatientName: true),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label,
                style: const TextStyle(
                    color: OptoColors.onSurfaceVariantDark, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: OptoColors.onSurfaceDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HitMapPainter extends CustomPainter {
  final List<LetterEvent> events;
  final Color dotColor;
  final int numRings;

  _HitMapPainter({
    required this.events,
    required this.dotColor,
    required this.numRings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 4;

    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= numRings; i++) {
      final r = radius * i / numRings;
      canvas.drawCircle(center, r, ringPaint);
    }

    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      axisPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      axisPaint,
    );

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (final e in events) {
      final x = center.dx + e.dx * radius;
      final y = center.dy + e.dy * radius;
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HitMapPainter oldDelegate) =>
      oldDelegate.events != events ||
      oldDelegate.dotColor != dotColor ||
      oldDelegate.numRings != numRings;
}
