import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../main.dart' show themeNotifier, saveThemePreference;
import '../models/saved_result.dart';
import '../services/results_storage.dart';
import '../theme/opto_colors.dart';
import '../theme/opto_spacing.dart';
import '../utils/page_transitions.dart';
import '../widgets/design_system/opto_card.dart';
import 'config_screen.dart';
import 'credits_screen.dart';
import 'history_screen.dart';
import 'localization_config_screen.dart';
import 'macdonald_config_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  List<SavedResult> _results = [];
  bool _isLoading = true;

  late final AnimationController _animController;

  // Staggered animations (7 items max: 3 test cards + repeat + 3 stats + activity)
  static const int _totalAnimItems = 8;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<double>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnims = List.generate(_totalAnimItems, (i) {
      final start = (i * 50) / ((_totalAnimItems - 1) * 50 + 200);
      final end = (i * 50 + 200) / ((_totalAnimItems - 1) * 50 + 200);
      return CurvedAnimation(
        parent: _animController,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
            curve: Curves.easeOut),
      );
    });
    _slideAnims = _fadeAnims; // same intervals for slide
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await ResultsStorage.loadAll();
    if (!mounted) return;
    setState(() {
      _results = results;
      _isLoading = false;
    });
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // -- Computed stats --

  int get _testsToday {
    final now = DateTime.now();
    return _results
        .where((r) =>
            r.startedAt.year == now.year &&
            r.startedAt.month == now.month &&
            r.startedAt.day == now.day)
        .length;
  }

  int get _uniquePatients =>
      _results.map((r) => r.patientName).where((n) => n.isNotEmpty).toSet().length;

  SavedResult? get _lastResult => _results.isNotEmpty ? _results.first : null;

  List<SavedResult> get _recentResults =>
      _results.length > 4 ? _results.sublist(0, 4) : _results;

  // -- Helpers --

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return 'hace ${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return 'hace ${diff.inHours}h';
    } else if (diff.inHours < 48) {
      return 'ayer';
    } else {
      return 'hace ${diff.inDays}d';
    }
  }

  String _testTypeLabel(String testType) {
    switch (testType) {
      case 'peripheral':
        return 'Periférico';
      case 'localization':
        return 'Localización';
      case 'macdonald':
        return 'MacDonald';
      default:
        return testType;
    }
  }

  Color _testTypeColor(String testType) {
    switch (testType) {
      case 'peripheral':
        return OptoColors.peripheral;
      case 'localization':
        return OptoColors.localization;
      case 'macdonald':
        return OptoColors.macdonald;
      default:
        return OptoColors.primary;
    }
  }

  void _navigateToConfig(String testType) {
    Widget screen;
    switch (testType) {
      case 'peripheral':
        screen = const ConfigScreen();
        break;
      case 'localization':
        screen = const LocalizationConfigScreen();
        break;
      case 'macdonald':
        screen = const MacDonaldConfigScreen();
        break;
      default:
        return;
    }
    Navigator.push(context, OptoPageRoute(builder: (_) => screen)).then((_) {
      // Reload results when returning from a test flow.
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final results = await ResultsStorage.loadAll();
    if (!mounted) return;
    setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildHeader(l, theme, isDark, colorScheme),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        OptoSpacing.md,
                        OptoSpacing.sm,
                        OptoSpacing.md,
                        OptoSpacing.md,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 12,
                            child: _buildLeftColumn(l, theme, colorScheme),
                          ),
                          const SizedBox(width: OptoSpacing.md),
                          Expanded(
                            flex: 10,
                            child: _buildRightColumn(l, theme, colorScheme),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // -- Header --

  Widget _buildHeader(
    AppLocalizations l,
    ThemeData theme,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: OptoSpacing.md,
        vertical: OptoSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: OptoColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: OptoSpacing.sm),
          Text(
            'OptoView',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? l.themeLight : l.themeDark,
            onPressed: () {
              final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
              themeNotifier.value = newMode;
              saveThemePreference(newMode);
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: l.menuCredits,
            onPressed: () {
              Navigator.push(
                context,
                OptoPageRoute(builder: (_) => const CreditsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // -- Left column --

  Widget _buildLeftColumn(
    AppLocalizations l,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('TESTS DISPONIBLES', colorScheme),
          const SizedBox(height: OptoSpacing.sm),
          _animatedItem(
            0,
            _buildTestCard(
              icon: Icons.blur_circular,
              color: OptoColors.peripheral,
              name: l.testPeripheralTitle,
              description: l.testPeripheralSubtitle,
              onTap: () => _navigateToConfig('peripheral'),
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(height: OptoSpacing.sm),
          _animatedItem(
            1,
            _buildTestCard(
              icon: Icons.my_location,
              color: OptoColors.localization,
              name: l.testLocalizationTitle,
              description: l.testLocalizationSubtitle,
              onTap: () => _navigateToConfig('localization'),
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(height: OptoSpacing.sm),
          _animatedItem(
            2,
            _buildTestCard(
              icon: Icons.grid_view_rounded,
              color: OptoColors.macdonald,
              name: l.testMacdonaldTitle,
              description: l.testMacdonaldSubtitle,
              onTap: () => _navigateToConfig('macdonald'),
              colorScheme: colorScheme,
            ),
          ),
          if (_lastResult != null) ...[
            const SizedBox(height: OptoSpacing.md),
            _animatedItem(3, _buildRepeatCard(colorScheme, theme)),
          ],
        ],
      ),
    );
  }

  Widget _buildTestCard({
    required IconData icon,
    required Color color,
    required String name,
    required String description,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return OptoCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(OptoSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withAlpha(38), // ~15%
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: OptoSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: OptoColors.onSurfaceVariantDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatCard(ColorScheme colorScheme, ThemeData theme) {
    final last = _lastResult!;
    final subtitle = '${_testTypeLabel(last.testType)}'
        '${last.patientName.isNotEmpty ? ' · ${last.patientName}' : ''}'
        ' · ${_relativeTime(last.startedAt)}';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
        border: Border.all(
          color: OptoColors.primary.withAlpha(31), // ~12%
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            OptoColors.primary.withAlpha(31), // ~12%
            OptoColors.primary.withAlpha(13), // ~5%
          ],
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToConfig(last.testType),
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(OptoSpacing.md),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: OptoColors.primary.withAlpha(51), // ~20%
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.replay,
                  color: OptoColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: OptoSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Repetir último test',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: OptoColors.onSurfaceVariantDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -- Right column --

  Widget _buildRightColumn(
    AppLocalizations l,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (_results.isEmpty) {
      return _buildEmptyState(colorScheme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _animatedItem(4, _buildStatsRow(colorScheme)),
        const SizedBox(height: OptoSpacing.md),
        Expanded(
          child: _animatedItem(
            5,
            _buildActivityCard(l, theme, colorScheme),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.visibility_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant.withAlpha(128),
          ),
          const SizedBox(height: OptoSpacing.md),
          Text(
            'Bienvenido a OptoView',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: OptoSpacing.sm),
          Text(
            'Selecciona un test para comenzar',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            '$_testsToday',
            'TESTS HOY',
            colorScheme,
          ),
        ),
        const SizedBox(width: OptoSpacing.sm),
        Expanded(
          child: _buildStatBox(
            '$_uniquePatients',
            'PACIENTES',
            colorScheme,
          ),
        ),
        const SizedBox(width: OptoSpacing.sm),
        Expanded(
          child: _buildStatBox(
            '${_results.length}',
            'TOTAL TESTS',
            colorScheme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String value, String label, ColorScheme colorScheme) {
    return OptoCard(
      padding: const EdgeInsets.symmetric(
        vertical: OptoSpacing.md,
        horizontal: OptoSpacing.sm,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: OptoSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: OptoColors.onSurfaceVariantDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    AppLocalizations l,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return OptoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionLabel('ACTIVIDAD RECIENTE', colorScheme),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    OptoPageRoute(builder: (_) => const HistoryScreen()),
                  ).then((_) => _refreshData());
                },
                child: Text(
                  'Ver historial >',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: OptoSpacing.md),
          Expanded(
            child: ListView.separated(
              itemCount: _recentResults.length,
              separatorBuilder: (_, __) => const SizedBox(height: OptoSpacing.sm),
              itemBuilder: (_, i) {
                final r = _recentResults[i];
                return _buildActivityRow(r, colorScheme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(SavedResult r, ColorScheme colorScheme) {
    final color = _testTypeColor(r.testType);
    final statusLabel = r.completedNaturally ? 'Completo' : 'Detenido';
    final statusColor =
        r.completedNaturally ? OptoColors.success : OptoColors.warning;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: OptoSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.patientName.isNotEmpty ? r.patientName : _testTypeLabel(r.testType),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${_testTypeLabel(r.testType)} · ${_relativeTime(r.startedAt)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: OptoColors.onSurfaceVariantDark,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: OptoSpacing.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(31),
            borderRadius: BorderRadius.circular(OptoSpacing.radiusChip),
          ),
          child: Text(
            statusLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }

  // -- Shared helpers --

  Widget _sectionLabel(String text, ColorScheme colorScheme) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: OptoColors.onSurfaceVariantDark,
      ),
    );
  }

  Widget _animatedItem(int index, Widget child) {
    if (index >= _totalAnimItems) return child;
    return AnimatedBuilder(
      animation: _fadeAnims[index],
      builder: (context, _) => Opacity(
        opacity: _fadeAnims[index].value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - _slideAnims[index].value)),
          child: child,
        ),
      ),
    );
  }
}
