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
      backgroundColor: OptoColors.backgroundDark,
      body: Row(
        children: [
          Expanded(flex: 5, child: _buildBrandingPanel(l)),
          Expanded(flex: 6, child: _buildInfoPanel(l)),
        ],
      ),
    );
  }

  Widget _buildBrandingPanel(AppLocalizations l) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            OptoColors.backgroundDark,
            Color(0xFF1A2332),
            Color(0x280A3F6FB2), // OptoColors.primary with alpha ~40
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
            const Text(
              'OPTOVIEW',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: OptoColors.onSurfaceDark,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            // Description
            SizedBox(
              width: 280,
              child: Text(
                l.creditsDescription,
                style: const TextStyle(
                  fontSize: 13,
                  color: OptoColors.onSurfaceVariantDark,
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
                  color: OptoColors.surfaceVariantDark,
                  borderRadius: BorderRadius.circular(OptoSpacing.radiusPill),
                ),
                child: Text(
                  '$_version (build $_buildNumber)',
                  style: const TextStyle(
                    fontSize: 10,
                    color: OptoColors.onSurfaceVariantDark,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel(AppLocalizations l) {
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
                  style: const TextStyle(
                    fontSize: 13,
                    color: OptoColors.onSurfaceDark,
                  ),
                ),
                const SizedBox(height: OptoSpacing.sm),
                Text(
                  l.creditsDescription,
                  style: const TextStyle(
                    fontSize: 12,
                    color: OptoColors.onSurfaceVariantDark,
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
                color: OptoColors.surfaceVariantDark,
                borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_back,
                    size: 18,
                    color: OptoColors.onSurfaceDark,
                  ),
                  const SizedBox(width: OptoSpacing.sm),
                  Text(
                    l.creditsBack,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: OptoColors.onSurfaceDark,
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
    return Container(
      padding: const EdgeInsets.all(OptoSpacing.md),
      decoration: BoxDecoration(
        color: OptoColors.surfaceDark,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: OptoColors.onSurfaceVariantDark,
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: OptoColors.onSurfaceDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                role,
                style: const TextStyle(
                  fontSize: 12,
                  color: OptoColors.onSurfaceVariantDark,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: OptoColors.surfaceVariantDark,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: OptoColors.onSurfaceVariantDark,
        ),
      ),
    );
  }
}
