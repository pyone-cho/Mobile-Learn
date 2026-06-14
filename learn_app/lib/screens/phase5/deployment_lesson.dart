/// Phase 5: App Store Deployment
///
/// Interactive lesson covering:
///   - Build Types: debug vs profile vs release
///   - Signing & Keys: Android keystore, iOS certificates
///   - Store Prep: listing, screenshots, app icons
///   - CI/CD: GitHub Actions, Codemagic, Play Console
///   - Versioning: semantic version, build numbers, changelogs

import 'package:flutter/material.dart';

class DeploymentLesson extends StatelessWidget {
  const DeploymentLesson({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('App Store Deployment'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Build Types'),
              Tab(text: 'Signing'),
              Tab(text: 'Store Prep'),
              Tab(text: 'CI/CD'),
              Tab(text: 'Versioning'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _BuildTypesTab(),
            _SigningTab(),
            _StorePrepTab(),
            _CicdTab(),
            _VersioningTab(),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// SHARED
// ======================================================================

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String message;

  const _InfoBanner({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message,
                style: TextStyle(fontSize: 12, color: Colors.blue.shade900)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  final String code;
  const _CodeBlock({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        code,
        style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
      ),
    );
  }
}

// ======================================================================
// TAB 1: Build Types
// ======================================================================

class _BuildTypesTab extends StatelessWidget {
  const _BuildTypesTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoBanner(
          icon: Icons.build_circle,
          message:
              'Flutter has three build modes. Debug is for development, '
              'profile is for performance testing, and release is for the stores.',
        ),
        const SizedBox(height: 20),

        // Debug
        _BuildModeCard(
          title: 'Debug Mode',
          icon: Icons.bug_report,
          color: Colors.orange,
          command: 'flutter run',
          apkCommand: 'flutter build apk --debug',
          description:
              'Hot reload enabled, assertions on, no optimizations. '
              'Best for development iteration.',
          pros: ['Hot reload / hot restart', 'Full stack traces', 'Debugger support'],
          cons: ['Slowest performance', 'Larger binary size', 'Not for testing'],
        ),

        // Profile
        _BuildModeCard(
          title: 'Profile Mode',
          icon: Icons.speed,
          color: Colors.indigo,
          command: 'flutter run --profile',
          apkCommand: 'flutter build apk --profile',
          description:
              'Optimized performance but with profiling tools. '
              'Use this to test real-world frame rates.',
          pros: ['Realistic performance metrics', 'DevTools profiling active', 'Good for UI tests'],
          cons: ['No hot reload', 'Still includes debug service', 'Not store-ready'],
        ),

        // Release
        _BuildModeCard(
          title: 'Release Mode',
          icon: Icons.rocket_launch,
          color: Colors.green,
          command: 'flutter run --release',
          apkCommand: 'flutter build apk --release',
          description:
              'Fully optimized, no debug tools, minified. '
              'This is what gets published to app stores.',
          pros: ['Smallest binary', 'Fastest performance', 'Obfuscated Dart code'],
          cons: ['No debugging', 'Test thoroughly before building', 'Must sign with release key'],
        ),

        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),

        const _SectionHeader(title: 'Build Commands by Platform'),
        _BuildCommandRow(
          platform: 'Android',
          commands: const [
            'flutter build apk --release         # APK',
            'flutter build appbundle --release    # AAB (Play Store)',
          ],
        ),
        _BuildCommandRow(
          platform: 'iOS',
          commands: const [
            'flutter build ios --release               # .xcarchive',
            'flutter build ipa --release                # .ipa (App Store)',
          ],
        ),
        _BuildCommandRow(
          platform: 'Web',
          commands: const [
            'flutter build web --release          # Deploy to any static host',
          ],
        ),

        const SizedBox(height: 16),
        const Text(
          'Pro tip: Test --profile builds before release. '
          'Profile mode catches jank that debug mode hides.',
          style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

class _BuildModeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String command;
  final String apkCommand;
  final String description;
  final List<String> pros;
  final List<String> cons;

  const _BuildModeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.command,
    required this.apkCommand,
    required this.description,
    required this.pros,
    required this.cons,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header stripe
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12)),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 10),
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description,
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 10),

                // Command
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(apkCommand,
                      style: const TextStyle(
                          fontSize: 11, fontFamily: 'monospace')),
                ),

                const SizedBox(height: 10),

                // Pros & Cons
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pros',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.green.shade700)),
                          const SizedBox(height: 4),
                          ...pros.map((p) => Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('  •  ',
                                      style: TextStyle(fontSize: 11)),
                                  Expanded(
                                      child: Text(p,
                                          style:
                                              const TextStyle(fontSize: 11))),
                                ],
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cons',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.red.shade700)),
                          const SizedBox(height: 4),
                          ...cons.map((c) => Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('  •  ',
                                      style: TextStyle(fontSize: 11)),
                                  Expanded(
                                      child: Text(c,
                                          style:
                                              const TextStyle(fontSize: 11))),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildCommandRow extends StatelessWidget {
  final String platform;
  final List<String> commands;

  const _BuildCommandRow({
    required this.platform,
    required this.commands,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(platform,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: commands
                  .map((c) => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(c,
                            style: const TextStyle(
                                fontSize: 11, fontFamily: 'monospace')),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// TAB 2: Signing & Keys
// ======================================================================

class _SigningTab extends StatelessWidget {
  const _SigningTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoBanner(
          icon: Icons.vpn_key,
          message:
              'Apps must be cryptographically signed before submission. '
              'Android uses a keystore, iOS uses certificates & provisioning profiles.',
        ),
        const SizedBox(height: 20),

        // Android section
        const _SectionHeader(title: 'Android — Keystore'),
        const Text(
          'A keystore is a binary file containing your private signing key. '
          'Keep it safe — if you lose it, you cannot update your app.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 12),

        const Text('1. Generate a keystore:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const _CodeBlock(
          code: 'keytool -genkey -v -keystore release.keystore \\\n'
              '  -alias my-key -keyalg RSA -keysize 2048 \\\n'
              '  -validity 10000',
        ),

        const Text('2. Create key.properties (android/):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const _CodeBlock(
          code: 'storeFile=../release.keystore\n'
              'storePassword=your-store-password\n'
              'keyAlias=my-key\n'
              'keyPassword=your-key-password',
        ),

        const Text('3. Configure build.gradle.kts:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const _CodeBlock(
          code: 'android {\n'
              '  signingConfigs {\n'
              '    release {\n'
              '      val props = Properties().apply {\n'
              '        load(file("key.properties").inputStream())\n'
              '      }\n'
              '      storeFile = file(props["storeFile"]!!)\n'
              '      storePassword = props["storePassword"]!!\n'
              '      keyAlias = props["keyAlias"]!!\n'
              '      keyPassword = props["keyPassword"]!!\n'
              '    }\n'
              '  }\n'
              '  buildTypes {\n'
              '    release {\n'
              '      signingConfig = signingConfigs.release\n'
              '    }\n'
              '  }\n'
              '}',
        ),

        const SizedBox(height: 16),
        const Divider(),

        // iOS section
        const _SectionHeader(title: 'iOS — Certificates & Profiles'),
        const Text(
          'iOS signing requires an Apple Developer account (\$99/yr). '
          'Xcode handles most of this automatically with "Automatically manage signing".',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 12),

        _ChecklistCard(
          label: 'Assets',
          items: const [
            'Apple Developer Program membership (\$99/year)',
            'Distribution certificate (in Apple Developer portal)',
            'App ID matching your bundle identifier',
            'App Store provisioning profile',
            'Push notification certificate (if using push)',
          ],
          checked: false,
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber, size: 18, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Never commit your keystore or signing passwords to git. '
                  'Use environment variables or a secrets manager in CI/CD.',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// TAB 3: Store Prep
// ======================================================================

class _StorePrepTab extends StatelessWidget {
  const _StorePrepTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoBanner(
          icon: Icons.store,
          message:
              'A great store listing is half the battle. You need '
              'screenshots, a description, app icons, and proper categorization.',
        ),
        const SizedBox(height: 20),

        // App Icon section
        const _SectionHeader(title: '1. App Icon'),
        const Text(
          'Generate all required sizes from a single 1024×1024 source. '
          'Use flutter_launcher_icons package for automation.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        const _CodeBlock(
          code: '// pubspec.yaml\ndev_dependencies:\n'
              '  flutter_launcher_icons: ^0.14.0\n\n'
              'flutter_launcher_icons:\n'
              '  android: true\n'
              '  ios: true\n'
              '  image_path: "assets/icon/app_icon.png"\n\n'
              '// Terminal:\n'
              '> flutter pub get\n'
              '> dart run flutter_launcher_icons',
        ),

        const SizedBox(height: 16),
        const Divider(),

        // Screenshots
        const _SectionHeader(title: '2. Screenshots'),
        const Text(
          'Each store has specific screenshot requirements. '
          'Use a tool like Store Screenshots or manual device frames.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 8),

        _ChecklistCard(
          label: 'Play Store (Android)',
          items: const [
            '2–8 screenshots',
            'JPEG or 24-bit PNG (no alpha)',
            'Min 320px, max 3840px (16:9 or 9:16)',
            'Feature graphic: 1024×500 (optional but recommended)',
            'TV: 1280×720 (if targeting Android TV)',
          ],
          checked: false,
        ),

        const SizedBox(height: 8),

        _ChecklistCard(
          label: 'App Store (iOS)',
          items: const [
            'Up to 10 screenshots per device size',
            '6.7" (iPhone): 1290×2796',
            '6.5" (iPhone): 1242×2688',
            '5.5" (iPhone): 1242×2208',
            'iPad Pro: 2048×2732 (if targeting iPad)',
          ],
          checked: false,
        ),

        const SizedBox(height: 16),
        const Divider(),

        // Listing
        const _SectionHeader(title: '3. Store Listing'),
        const Text(
          'Your store listing text is marketing — invest time here.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 8),

        _ListingField(
          label: 'App Name',
          value: '30 characters max. Should be memorable and searchable.',
          icon: Icons.title,
        ),
        _ListingField(
          label: 'Short Description (Play Store)',
          value: '80 characters. One-line pitch.',
          icon: Icons.short_text,
        ),
        _ListingField(
          label: 'Full Description',
          value: '4000 characters. Cover features, benefits, what makes it unique.',
          icon: Icons.article,
        ),
        _ListingField(
          label: 'Keywords (App Store)',
          value: '100 characters. Comma-separated search terms.',
          icon: Icons.search,
        ),
        _ListingField(
          label: 'Category',
          value: 'Pick the most accurate — Education, Health, Productivity, etc.',
          icon: Icons.category,
        ),

        const SizedBox(height: 16),

        // Tip
        const Text(
          'Tip: A/B test your screenshots. The first 1–3 screenshots are '
          'the most important — they appear in search results without scrolling.',
          style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  final String label;
  final List<String> items;
  final bool checked;

  const _ChecklistCard({
    required this.label,
    required this.items,
    required this.checked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      checked
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(item,
                          style: const TextStyle(fontSize: 12)),
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
}

class _ListingField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ListingField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.teal),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(value,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// TAB 4: CI/CD
// ======================================================================

class _CicdTab extends StatelessWidget {
  const _CicdTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoBanner(
          icon: Icons.sync_alt,
          message:
              'CI/CD automates building, testing, and deploying your app. '
              'Push to GitHub → automatic build → deploy to stores.',
        ),
        const SizedBox(height: 20),

        // GitHub Actions
        const Text('GitHub Actions (Free for public repos)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        const Text(
          'Create .github/workflows/flutter.yml in your repo root.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        const _CodeBlock(
          code: 'name: Flutter CI\n\n'
              'on:\n'
              '  push:\n'
              '    branches: [main]\n'
              '  pull_request:\n'
              '    branches: [main]\n\n'
              'jobs:\n'
              '  build:\n'
              '    runs-on: ubuntu-latest\n'
              '    steps:\n'
              '      - uses: actions/checkout@v4\n'
              '      - uses: subosito/flutter-action@v2\n'
              '        with:\n'
              '          flutter-version: "3.x"\n'
              '      - run: flutter pub get\n'
              '      - run: flutter analyze\n'
              '      - run: flutter test\n'
              '      - run: flutter build apk --release',
        ),

        const SizedBox(height: 16),
        const Divider(),

        // Codemagic
        const Text('Codemagic (CI/CD for Flutter)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        const Text(
          'Codemagic is purpose-built for Flutter. It can auto-publish '
          'to Google Play and App Store Connect.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        const _CodeBlock(
          code: '# codemagic.yaml (in repo root)\n'
              'workflows:\n'
              '  release:\n'
              '    name: Release Build\n'
              '    environment:\n'
              '      flutter: stable\n'
              '    scripts:\n'
              '      - flutter pub get\n'
              '      - flutter test\n'
              '      - flutter build appbundle --release\n'
              '    artifacts:\n'
              '      - build/**/outputs/**/*.aab\n'
              '    publishing:\n'
              '      google_play:\n'
              '        credentials: Encrypted(...)\n'
              '        track: internal',
        ),

        const SizedBox(height: 16),
        const Divider(),

        // Comparison
        const Text('CI/CD Service Comparison',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),

        _CicdComparison(
          service: 'GitHub Actions',
          freeTier: '2000 min/month',
          storeDeploy: 'Manual or 3rd party',
          bestFor: 'Open-source projects, simple builds',
        ),
        _CicdComparison(
          service: 'Codemagic',
          freeTier: '500 min/month (open source)',
          storeDeploy: 'One-click to Play & App Store',
          bestFor: 'Flutter-only projects',
        ),
        _CicdComparison(
          service: 'Bitrise',
          freeTier: '200 min/month',
          storeDeploy: 'Workflow-based deploy',
          bestFor: 'Cross-platform teams',
        ),
      ],
    );
  }
}

class _CicdComparison extends StatelessWidget {
  final String service;
  final String freeTier;
  final String storeDeploy;
  final String bestFor;

  const _CicdComparison({
    required this.service,
    required this.freeTier,
    required this.storeDeploy,
    required this.bestFor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text('Free tier: $freeTier',
                style: const TextStyle(fontSize: 12)),
            Text('Store deploy: $storeDeploy',
                style: const TextStyle(fontSize: 12)),
            Text('Best for: $bestFor',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// TAB 5: Versioning
// ======================================================================

class _VersioningTab extends StatefulWidget {
  const _VersioningTab();

  @override
  State<_VersioningTab> createState() => _VersioningTabState();
}

class _VersioningTabState extends State<_VersioningTab> {
  int _major = 1;
  int _minor = 0;
  int _patch = 0;
  int _build = 1;

  void _bump(String level) {
    setState(() {
      switch (level) {
        case 'major':
          _major++;
          _minor = 0;
          _patch = 0;
          break;
        case 'minor':
          _minor++;
          _patch = 0;
          break;
        case 'patch':
          _patch++;
          break;
        case 'build':
          _build++;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoBanner(
          icon: Icons.tag,
          message:
              'Every release needs a version name (shown to users) and a '
              'version code (integer, used internally). Follow semantic versioning.',
        ),
        const SizedBox(height: 20),

        // Interactive version display
        Card(
          elevation: 2,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.teal.shade600, Colors.teal.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Text('Current Version',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Text(
                  'v$_major.$_minor.$_patch',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Build $_build',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 4),
                Text(
                  'pubspec.yaml: $_major.$_minor.$_patch+$_build',
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Colors.white.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Version bump buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _BumpButton(
              label: 'Major',
              subtitle: 'Breaking changes',
              color: Colors.red,
              onTap: () => _bump('major'),
            ),
            _BumpButton(
              label: 'Minor',
              subtitle: 'New features',
              color: Colors.orange,
              onTap: () => _bump('minor'),
            ),
            _BumpButton(
              label: 'Patch',
              subtitle: 'Bug fixes',
              color: Colors.green,
              onTap: () => _bump('patch'),
            ),
            _BumpButton(
              label: 'Build',
              subtitle: 'Internal revision',
              color: Colors.blue,
              onTap: () => _bump('build'),
            ),
          ],
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),

        // pubspec.yaml example
        const _SectionHeader(title: 'In pubspec.yaml'),
        const Text(
          'Flutter uses the format version_name+version_code:',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        const _CodeBlock(
          code: 'version: 1.0.0+1  # format: <name>+<code>\n'
              '              ^ ^\n'
              '              | build number (integer, must increase)\n'
              '              version name (shown to users)',
        ),

        const SizedBox(height: 12),

        // Changelog
        const _SectionHeader(title: 'Changelog Best Practices'),
        const Text(
          'Keep a CHANGELOG.md in your repo root. It helps users and '
          'testers understand what changed.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        const _CodeBlock(
          code: '# Changelog\n\n'
              '## [1.1.0] - 2025-03-15\n'
              '### Added\n'
              '- Dark mode support\n'
              '- Push notifications\n\n'
              '### Fixed\n'
              '- Crash on login with empty email\n\n'
              '## [1.0.0] - 2025-02-01\n'
              '- Initial release',
        ),

        const SizedBox(height: 16),

        // Rules card
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Version code (build number) must ALWAYS increase. '
                    'Once uploaded to stores, you cannot decrease it. '
                    'Start at 1 and increment for every upload.',
                    style:
                        TextStyle(fontSize: 12, color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BumpButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _BumpButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('+$label',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
          Text(subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
