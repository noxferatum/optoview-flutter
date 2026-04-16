import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../l10n/app_localizations.dart';
import '../theme/opto_colors.dart';
import '../theme/opto_spacing.dart';

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: Row(
        children: [
          Expanded(flex: 5, child: _buildBrandingPanel(l)),
          Expanded(flex: 6, child: _buildInfoPanel(l)),
        ],
      ),
    );
  }

  Widget _buildBrandingPanel(AppLocalizations l) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            Color.alphaBlend(
                OptoColors.primary.withAlpha(20), colorScheme.surface),
            OptoColors.primary.withAlpha(40),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo with subtle glow
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(OptoSpacing.radiusLogo),
                boxShadow: [
                  BoxShadow(
                    color: OptoColors.primary.withAlpha(40),
                    blurRadius: 32,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(OptoSpacing.radiusLogo),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 150,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // App name
            Text(
              'OPTOVIEW',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            // Description
            SizedBox(
              width: 280,
              child: Text(
                l.creditsDescription,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            // Version badge
            if (_version.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(OptoSpacing.radiusPill),
                ),
                child: Text(
                  '$_version (build $_buildNumber)',
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel(AppLocalizations l) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(OptoSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Team card
          _buildCard(
            header: 'EQUIPO',
            child: Column(
              children: const [
                _TeamMember(
                  icon: Icons.remove_red_eye,
                  iconColor: OptoColors.peripheral,
                  name: 'Estefania Rodriguez-Bobada Lillo',
                  role: 'Optometrista',
                ),
                SizedBox(height: OptoSpacing.md),
                _TeamMember(
                  icon: Icons.code,
                  iconColor: OptoColors.primary,
                  name: 'Rodrigo Melon Gutte',
                  role: 'Desarrollo',
                ),
              ],
            ),
          ),
          const SizedBox(height: OptoSpacing.md),

          // Technology card
          _buildCard(
            header: 'TECNOLOGIA',
            child: Wrap(
              spacing: OptoSpacing.sm,
              runSpacing: OptoSpacing.sm,
              children: const [
                _TechTag(label: 'Flutter 3.8'),
                _TechTag(label: 'Dart'),
                _TechTag(label: 'Material 3'),
                _TechTag(label: 'Android'),
              ],
            ),
          ),
          const SizedBox(height: OptoSpacing.md),

          // Legal card
          _buildCard(
            header: 'LEGAL',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u00a9 ${DateTime.now().year} Optoview',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: OptoSpacing.sm),
                Text(
                  l.creditsDescription,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: OptoSpacing.lg),

          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: OptoSpacing.md,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back,
                    size: 18,
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(width: OptoSpacing.sm),
                  Text(
                    l.creditsBack,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String header, required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(OptoSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _TeamMember extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String name;
  final String role;

  const _TeamMember({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                role,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TechTag extends StatelessWidget {
  final String label;

  const _TechTag({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
