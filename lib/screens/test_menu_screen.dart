import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'config_screen.dart';
import 'localization_config_screen.dart';

class TestMenuScreen extends StatelessWidget {
  const TestMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final tests = [
      _TestInfo(
        title: l.testPeripheralTitle,
        subtitle: l.testPeripheralSubtitle,
        gradient: const [Color(0xFF5B72F2), Color(0xFF62C4FF)],
        icon: Icons.blur_circular,
        imageAsset: 'assets/images/test_peripheral.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ConfigScreen()),
          );
        },
      ),
      _TestInfo(
        title: l.testLocalizationTitle,
        subtitle: l.testLocalizationSubtitle,
        gradient: const [Color(0xFF7B5BFF), Color(0xFFD16EF5)],
        icon: Icons.my_location,
        imageAsset: 'assets/images/location_peripheal.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const LocalizationConfigScreen()),
          );
        },
      ),
      _TestInfo(
        title: l.testComingSoonTitle,
        subtitle: l.testComingSoonSubtitle,
        gradient: const [Color(0xFF333A73), Color(0xFF5B6BC3)],
        icon: Icons.upcoming,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.testComingSoonSnackbar),
            ),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.testMenuTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.builder(
                itemCount: tests.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final info = tests[index];
                  return _TestCard(info: info);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TestInfo {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;
  final String? imageAsset;
  final VoidCallback onTap;

  _TestInfo({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    this.imageAsset,
    required this.onTap,
  });
}

class _TestCard extends StatelessWidget {
  final _TestInfo info;

  const _TestCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${info.title}: ${info.subtitle}',
      child: Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: info.onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: info.imageAsset != null
                      ? Image.asset(
                          info.imageAsset!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: info.gradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              info.icon,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                info.title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                info.subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
