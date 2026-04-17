import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import '../l10n/app_localizations.dart';
import '../models/macdonald_result.dart';
import '../models/questionnaire_result.dart';
import '../models/saved_result.dart';
import '../services/app_logger.dart';
import '../services/export_service.dart';
import '../services/questionnaire_storage.dart';
import '../services/results_storage.dart';
import '../theme/opto_colors.dart';
import '../theme/opto_spacing.dart';
import '../widgets/design_system/opto_action_button.dart';

enum _HistoryViewMode { byPatient, byDate }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Object> _items = []; // SavedResult OR QuestionnaireResult
  bool _isLoading = true;
  String _searchQuery = '';
  _HistoryViewMode _viewMode = _HistoryViewMode.byPatient;
  final _searchController = TextEditingController();
  String? _activeFilter; // Filter by test type: 'peripheral', 'localization', 'macdonald', 'questionnaire', null = all

  // Selection mode
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  // Master-detail
  String? _selectedResultId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final results = await ResultsStorage.loadAll();
    final questionnaires = await QuestionnaireStorage.loadAll();
    final combined = <Object>[...results, ...questionnaires];
    combined.sort((a, b) => _dateOf(b).compareTo(_dateOf(a)));
    if (!mounted) return;
    setState(() {
      _items = combined;
      _isLoading = false;
    });
  }

  // ---------------------------------------------------------------------------
  // Mixed-item helpers
  // ---------------------------------------------------------------------------

  DateTime _dateOf(Object item) {
    if (item is SavedResult) return item.startedAt;
    if (item is QuestionnaireResult) return item.completedAt;
    throw StateError('unknown item type $item');
  }

  String _idOf(Object item) {
    if (item is SavedResult) return item.id;
    if (item is QuestionnaireResult) return item.id;
    throw StateError('unknown item type $item');
  }

  String _patientOf(Object item) {
    if (item is SavedResult) return item.patientName;
    if (item is QuestionnaireResult) return item.patientName;
    throw StateError('unknown item type $item');
  }

  /// Filtra items por nombre de paciente, tipo de test y filtro activo.
  List<Object> get _filteredItems {
    var result = _items.where((item) {
      // Apply filter by test type / questionnaire
      if (_activeFilter != null) {
        if (_activeFilter == 'questionnaire') {
          if (item is! QuestionnaireResult) return false;
        } else {
          if (item is! SavedResult || item.testType != _activeFilter) return false;
        }
      }
      return true;
    }).toList();

    // Apply search filter
    if (_searchQuery.isEmpty) return result;
    final q = _searchQuery.toLowerCase();
    final l = AppLocalizations.of(context)!;
    return result.where((item) {
      final name = _patientOf(item).toLowerCase();
      if (name.contains(q)) return true;
      if (item is SavedResult) {
        final type = _testTypeLabel(item.testType, l).toLowerCase();
        if (type.contains(q)) return true;
      }
      return false;
    }).toList();
  }

  /// Agrupa items por paciente, ordenados: primero con nombre, luego sin nombre.
  Map<String, List<Object>> _groupByPatient(List<Object> items) {
    final groups = <String, List<Object>>{};
    for (final item in items) {
      final name = _patientOf(item);
      final key = name.isNotEmpty ? name : '';
      groups.putIfAbsent(key, () => []).add(item);
    }
    // Ordenar cada grupo por fecha descendente.
    for (final list in groups.values) {
      list.sort((a, b) => _dateOf(b).compareTo(_dateOf(a)));
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
                // Only test results are wiped here; questionnaires remain.
                _items.removeWhere((item) => item is SavedResult);
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
                _items.removeWhere(
                  (item) => item is SavedResult && item.id == result.id,
                );
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

  void _toggleSelectionById(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIds.addAll(_filteredItems.map(_idOf));
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedIds.clear();
      _selectionMode = false;
    });
  }

  List<Object> get _selectedItems =>
      _items.where((i) => _selectedIds.contains(_idOf(i))).toList()
        ..sort((a, b) => _dateOf(b).compareTo(_dateOf(a)));

  Future<void> _bulkExport(String format, AppLocalizations l) async {
    final selected = _selectedItems;
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
                final idx = _items.indexWhere(
                  (item) => item is SavedResult && item.id == result.id,
                );
                if (idx != -1) _items[idx] = updated;
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
    final savedResults = _items.whereType<SavedResult>().toList();
    if (savedResults.isEmpty) {
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
        SnackBar(content: Text(l.backupExportSuccess(savedResults.length))),
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
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.backupImportSuccess(count))),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Patient summary export
  // ---------------------------------------------------------------------------

  void _showPatientSummaryExport(AppLocalizations l) {
    // Group items (tests + questionnaires) by patient name.
    final patients = <String, List<Object>>{};
    for (final item in _items) {
      final rawName = _patientOf(item);
      final name = rawName.isNotEmpty ? rawName : '-';
      patients.putIfAbsent(name, () => []).add(item);
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
      String patientName, List<Object> results, AppLocalizations l) {
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
    final colorScheme = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          _buildTopBar(l),
          _buildFilterBar(l),
          Expanded(
            child: _items.isEmpty
                ? _buildEmptyState(l)
                : Row(
                    children: [
                      // LEFT: list panel (380px)
                      SizedBox(
                        width: 380,
                        child: _buildListPanel(l, dateFmt),
                      ),
                      // Divider
                      VerticalDivider(
                        width: 1,
                        color: colorScheme.outlineVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OptoSpacing.sm,
        vertical: OptoSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: _selectionMode
            ? Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close,
                        color: colorScheme.onSurface),
                    onPressed: _exitSelectionMode,
                  ),
                  const SizedBox(width: OptoSpacing.sm),
                  Expanded(
                    child: Text(
                      l.bulkSelectedCount(_selectedIds.length),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.select_all,
                        color: colorScheme.onSurface),
                    tooltip: _selectedIds.length == _filteredItems.length
                        ? l.bulkDeselectAll
                        : l.bulkSelectAll,
                    onPressed: _selectedIds.length == _filteredItems.length
                        ? _deselectAll
                        : _selectAll,
                  ),
                ],
              )
            : Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: colorScheme.onSurface),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: OptoSpacing.sm),
                  Expanded(
                    child: Text(
                      l.historyTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.file_download,
                        color: colorScheme.onSurface),
                    tooltip: l.backupImportTooltip,
                    onPressed: () => _importBackup(l),
                  ),
                  if (_items.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.file_upload,
                          color: colorScheme.onSurface),
                      tooltip: l.backupExportTooltip,
                      onPressed: () => _exportBackup(l),
                    ),
                  if (_items.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.summarize,
                          color: colorScheme.onSurface),
                      tooltip: l.exportPatientSummary,
                      onPressed: () => _showPatientSummaryExport(l),
                    ),
                  if (_items.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.delete_sweep,
                          color: colorScheme.onSurface),
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
    if (_items.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        OptoSpacing.md,
        OptoSpacing.sm,
        OptoSpacing.md,
        OptoSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: l.historySearchHint,
                    hintStyle:
                        TextStyle(color: colorScheme.onSurfaceVariant),
                    prefixIcon: Icon(Icons.search,
                        color: colorScheme.onSurfaceVariant),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: colorScheme.onSurfaceVariant),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
                      borderSide:
                          BorderSide(color: colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
                      borderSide:
                          BorderSide(color: colorScheme.outlineVariant),
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
          const SizedBox(height: OptoSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: Text(Localizations.localeOf(context).languageCode == 'es' ? 'Todos' : 'All'),
                  selected: _activeFilter == null,
                  onSelected: (_) => setState(() => _activeFilter = null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(l.historyTestPeripheral),
                  selected: _activeFilter == 'peripheral',
                  onSelected: (_) => setState(() => _activeFilter = 'peripheral'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(l.historyTestLocalization),
                  selected: _activeFilter == 'localization',
                  onSelected: (_) => setState(() => _activeFilter = 'localization'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(l.historyTestMacdonald),
                  selected: _activeFilter == 'macdonald',
                  onSelected: (_) => setState(() => _activeFilter = 'macdonald'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(l.historyTestQuestionnaire),
                  selected: _activeFilter == 'questionnaire',
                  onSelected: (_) => setState(() => _activeFilter = 'questionnaire'),
                ),
              ],
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
    final colorScheme = theme.colorScheme;
    final filtered = _filteredItems;

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          l.historyNoResults,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return _viewMode == _HistoryViewMode.byPatient
        ? _buildPatientGroupedView(filtered, l, dateFmt, theme)
        : _buildDateSortedView(filtered, l, dateFmt, theme);
  }

  // ---------------------------------------------------------------------------
  // Detail panel (right)
  // ---------------------------------------------------------------------------

  Widget _buildDetailPanel(AppLocalizations l, DateFormat dateFmt) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_selectedResultId == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.article_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant.withAlpha(128)),
            const SizedBox(height: OptoSpacing.md),
            Text(
              'Selecciona un resultado',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Find the selected item; may be a SavedResult or QuestionnaireResult.
    Object? selected;
    for (final item in _items) {
      if (_idOf(item) == _selectedResultId) {
        selected = item;
        break;
      }
    }

    if (selected == null) {
      // Item was deleted; clear selection.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedResultId = null);
      });
      return const SizedBox.shrink();
    }

    if (selected is QuestionnaireResult) {
      return _buildQuestionnaireDetailPanel(selected, colorScheme, l);
    }

    if (selected is! SavedResult) {
      return const SizedBox.shrink();
    }

    final current = selected;

    final typeColor = _testTypeColor(current.testType);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: SingleChildScrollView(
        key: ValueKey(current.id),
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
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (current.patientName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.person,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                current.patientName,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          dateFmt.format(current.startedAt),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant.withAlpha(128),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit,
                        size: 20, color: colorScheme.onSurfaceVariant),
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
              Divider(color: colorScheme.outlineVariant, height: 1),
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
                Divider(
                    color: colorScheme.outlineVariant, height: 1),
                const SizedBox(height: OptoSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(l.macHitMapTitle,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
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
                                color: colorScheme.onSurface,
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
                Divider(
                    color: colorScheme.outlineVariant, height: 1),
                const SizedBox(height: OptoSpacing.md),
                Text(
                  l.configUsedTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ...current.configSummary.entries.map(
                  (e) => _DetailRow(label: e.key, value: e.value),
                ),
              ],

              // Export buttons
              const SizedBox(height: OptoSpacing.md),
              Divider(color: colorScheme.outlineVariant, height: 1),
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
    );
  }

  // ---------------------------------------------------------------------------
  // Selection bar (bottom)
  // ---------------------------------------------------------------------------

  Widget _buildSelectionBar(AppLocalizations l) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: OptoSpacing.md, vertical: OptoSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
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
                color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history,
              size: 64,
              color: colorScheme.onSurfaceVariant.withAlpha(128)),
          const SizedBox(height: 16),
          Text(
            l.historyEmpty,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
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
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedIds.contains(r.id);
    final isDetailSelected = r.id == _selectedResultId;
    final typeColor = _testTypeColor(r.testType);

    final tile = Container(
      decoration: BoxDecoration(
        color: isDetailSelected
            ? colorScheme.surfaceContainerHighest
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
            color: colorScheme.onSurface,
            fontWeight: isDetailSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        subtitle: Text(
          showPatientName && r.patientName.isNotEmpty
              ? '${r.patientName} · ${dateFmt.format(r.startedAt)}'
              : dateFmt.format(r.startedAt),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
        ),
        trailing: Text(
          _keyMetric(r),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDetailSelected ? OptoColors.primary : colorScheme.onSurface,
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

  Widget _buildPatientGroupedView(List<Object> filtered,
      AppLocalizations l, DateFormat dateFmt, ThemeData theme) {
    final colorScheme = theme.colorScheme;
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
                  Icon(Icons.person,
                      size: 18, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      displayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    l.historyResultCount(items.length),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colorScheme.outlineVariant),
            // Resultados del grupo
            ...items.map((item) => _buildItemTile(item, l, dateFmt, theme)),
          ],
        );
      },
    );
  }

  Widget _buildDateSortedView(List<Object> filtered, AppLocalizations l,
      DateFormat dateFmt, ThemeData theme) {
    final sorted = List<Object>.from(filtered)
      ..sort((a, b) => _dateOf(b).compareTo(_dateOf(a)));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: sorted.length,
      itemBuilder: (context, index) => _buildItemTile(
        sorted[index], l, dateFmt, theme,
        showPatientName: true,
      ),
    );
  }

  /// Dispatches tile rendering by concrete item type.
  Widget _buildItemTile(
      Object item, AppLocalizations l, DateFormat dateFmt, ThemeData theme,
      {bool showPatientName = false}) {
    if (item is SavedResult) {
      return _buildResultTile(item, l, dateFmt, theme,
          showPatientName: showPatientName);
    }
    if (item is QuestionnaireResult) {
      return _buildQuestionnaireTile(item, theme.colorScheme, l);
    }
    return const SizedBox.shrink();
  }

  Widget _buildQuestionnaireTile(
    QuestionnaireResult q,
    ColorScheme cs,
    AppLocalizations l,
  ) {
    final isSelected = _selectedIds.contains(q.id);
    final isDetailSelected = q.id == _selectedResultId;
    return Container(
      decoration: BoxDecoration(
        color: isDetailSelected ? OptoColors.primary.withAlpha(26) : null,
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: InkWell(
        onTap: _selectionMode
            ? () => _toggleSelectionById(q.id)
            : () => setState(() => _selectedResultId = q.id),
        onLongPress: () {
          if (!_selectionMode) {
            setState(() {
              _selectionMode = true;
              _selectedIds.add(q.id);
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(OptoSpacing.md),
          child: Row(
            children: [
              if (_selectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: OptoSpacing.sm),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelectionById(q.id),
                  ),
                ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: OptoColors.primary.withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.assignment,
                    color: OptoColors.primary, size: 18),
              ),
              const SizedBox(width: OptoSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.patientName.isNotEmpty
                          ? q.patientName
                          : l.questionnaireFormTitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      l.questionnaireHistorySubtitle(q.cvsqTotalScore),
                      style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Questionnaire detail panel
  // ---------------------------------------------------------------------------

  Widget _buildQuestionnaireDetailPanel(
    QuestionnaireResult q,
    ColorScheme cs,
    AppLocalizations l,
  ) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(OptoSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: patient + date + score
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.patientName.isNotEmpty
                          ? q.patientName
                          : l.questionnaireFormTitle,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface),
                    ),
                    Text(
                      dateFmt.format(q.completedAt),
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l.questionnaireScoreLabel,
                      style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                  Text(
                    '${q.cvsqTotalScore}',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: OptoSpacing.md),

          // Export + delete buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OptoActionButton(
                label: 'PDF',
                icon: Icons.picture_as_pdf,
                onPressed: () =>
                    ExportService.exportQuestionnairePdf(context, q, l),
              ),
              OptoActionButton(
                label: 'Excel',
                icon: Icons.table_chart,
                onPressed: () => ExportService.exportQuestionnaireExcel(q, l),
              ),
              OptoActionButton(
                label: 'CSV',
                icon: Icons.description,
                onPressed: () => ExportService.exportQuestionnaireCsv(q, l),
              ),
              OptoActionButton(
                label: l.historyDelete,
                icon: Icons.delete,
                variant: OptoButtonVariant.danger,
                onPressed: () async {
                  await QuestionnaireStorage.delete(q.id);
                  if (!mounted) return;
                  setState(() => _selectedResultId = null);
                  await _loadData();
                },
              ),
            ],
          ),
          const SizedBox(height: OptoSpacing.lg),

          // CVS-Q section
          Text(l.questionnaireCvsqSection,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface)),
          const SizedBox(height: OptoSpacing.sm),
          ...List.generate(q.cvsqAnswers.length, (i) {
            final a = q.cvsqAnswers[i];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                      width: 24,
                      child: Text('${i + 1}.',
                          style: TextStyle(
                              fontSize: 12, color: cs.onSurfaceVariant))),
                  Expanded(
                      child: Text(_cvsqItemText(i, l),
                          style: TextStyle(fontSize: 12, color: cs.onSurface))),
                  Text(_freqLabel(a.frequency, l),
                      style: TextStyle(
                          fontSize: 11, color: cs.onSurfaceVariant)),
                  const SizedBox(width: 8),
                  Text(
                      a.intensity == null
                          ? '—'
                          : _intLabel(a.intensity!, l),
                      style: TextStyle(
                          fontSize: 11, color: cs.onSurfaceVariant)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${a.score}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: OptoSpacing.md),

          // FSS section
          Text(l.questionnaireFssSection,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface)),
          const SizedBox(height: OptoSpacing.sm),
          ...List.generate(q.fssAnswers.length, (i) {
            final v = q.fssAnswers[i];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                      child: Text(_fssItemText(i, l),
                          style: TextStyle(fontSize: 12, color: cs.onSurface))),
                  Text(
                    v == null ? '—' : '$v / 7',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _freqLabel(CvsqFrequency f, AppLocalizations l) => switch (f) {
        CvsqFrequency.never => l.cvsqFreqNever,
        CvsqFrequency.occasional => l.cvsqFreqOccasional,
        CvsqFrequency.habitual => l.cvsqFreqHabitual,
      };

  String _intLabel(CvsqIntensity i, AppLocalizations l) => switch (i) {
        CvsqIntensity.moderate => l.cvsqIntModerate,
        CvsqIntensity.intense => l.cvsqIntIntense,
      };

  String _cvsqItemText(int i, AppLocalizations l) {
    switch (i) {
      case 0:
        return l.cvsqItem1;
      case 1:
        return l.cvsqItem2;
      case 2:
        return l.cvsqItem3;
      case 3:
        return l.cvsqItem4;
      case 4:
        return l.cvsqItem5;
      case 5:
        return l.cvsqItem6;
      case 6:
        return l.cvsqItem7;
      case 7:
        return l.cvsqItem8;
      case 8:
        return l.cvsqItem9;
      case 9:
        return l.cvsqItem10;
      case 10:
        return l.cvsqItem11;
      case 11:
        return l.cvsqItem12;
      case 12:
        return l.cvsqItem13;
      case 13:
        return l.cvsqItem14;
      case 14:
        return l.cvsqItem15;
      case 15:
        return l.cvsqItem16;
      default:
        throw StateError('invalid CVS-Q index $i');
    }
  }

  String _fssItemText(int i, AppLocalizations l) {
    switch (i) {
      case 0:
        return l.fssItem1;
      case 1:
        return l.fssItem2;
      case 2:
        return l.fssItem3;
      case 3:
        return l.fssItem4;
      case 4:
        return l.fssItem5;
      default:
        throw StateError('invalid FSS index $i');
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label,
                style: TextStyle(
                    color: colorScheme.onSurfaceVariant, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
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
