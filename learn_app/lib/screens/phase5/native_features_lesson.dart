/// Phase 5: Native Device Features
///
/// Interactive lesson covering:
///   - GPS & Location: geolocator package, permissions, real-time tracking
///   - Camera & Photos: image_picker, selecting from gallery
///   - Biometrics: local_auth, fingerprint/face unlock
///   - Haptics: HapticFeedback for tactile responses
///   - Platform Channels: communication between Dart and native code

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class NativeFeaturesLesson extends StatelessWidget {
  const NativeFeaturesLesson({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Native Device Features'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'GPS'),
              Tab(text: 'Camera'),
              Tab(text: 'Biometrics'),
              Tab(text: 'Haptics'),
              Tab(text: 'Platform'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _GpsTab(),
            _CameraTab(),
            _BiometricsTab(),
            _HapticsTab(),
            _PlatformTab(),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// HELPERS
// ======================================================================

/// Detects if running on web (no dart:io Platform available).
bool get _isWeb => identical(0, 0.0); // canonical web detection

/// Returns the platform name for display purposes.
String get _platformName {
  if (_isWeb) return 'Web';
  if (Platform.isAndroid) return 'Android';
  if (Platform.isIOS) return 'iOS';
  if (Platform.isMacOS) return 'macOS';
  if (Platform.isWindows) return 'Windows';
  if (Platform.isLinux) return 'Linux';
  return 'Unknown';
}

Widget _infoChip(IconData icon, String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.grey.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    ),
  );
}

// ======================================================================
// TAB 1: GPS / Location
// ======================================================================

class _GpsTab extends StatefulWidget {
  const _GpsTab();

  @override
  State<_GpsTab> createState() => _GpsTabState();
}

class _GpsTabState extends State<_GpsTab> {
  Position? _position;
  String? _error;
  bool _loading = false;
  bool _serviceEnabled = true;

  Future<void> _getLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isWeb) {
        // Simulate on web
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _position = Position(
            latitude: 51.5074 + (math.Random().nextDouble() - 0.5) * 0.01,
            longitude: -0.1278 + (math.Random().nextDouble() - 0.5) * 0.01,
            timestamp: DateTime.now(),
            altitude: 35.0,
            accuracy: 10.0,
            altitudeAccuracy: 10.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            headingAccuracy: 10.0,
          );
          _loading = false;
        });
        return;
      }

      // Real device flow
      _serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_serviceEnabled) {
        setState(() {
          _error = 'Location services are disabled. Enable them in settings.';
          _loading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Location permission denied.';
            _loading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permission permanently denied. '
              'Enable it in system settings.';
          _loading = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );

      setState(() {
        _position = pos;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoBanner(
          icon: Icons.location_on,
          message:
              'Use the geolocator package to access GPS coordinates. '
              'Always check permissions first — users can deny at any level.',
        ),
        const SizedBox(height: 16),

        // Controls
        Center(
          child: FilledButton.icon(
            onPressed: _loading ? null : _getLocation,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location),
            label: Text(_loading ? 'Getting location...' : 'Get My Location'),
          ),
        ),

        const SizedBox(height: 16),

        // Result card
        if (_position != null)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.location_on, size: 48, color: Colors.teal),
                  const SizedBox(height: 12),
                  Text(
                    '${_position!.latitude.toStringAsFixed(4)}, '
                    '${_position!.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _infoChip(Icons.height,
                          'Alt: ${_position!.altitude.toStringAsFixed(0)}m'),
                      _infoChip(Icons.gps_fixed,
                          'Acc: ±${_position!.accuracy.toStringAsFixed(0)}m'),
                      _infoChip(Icons.speed,
                          'Speed: ${_position!.speed.toStringAsFixed(1)} m/s'),
                    ],
                  ),
                ],
              ),
            ),
          ),

        if (_error != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13)),
                ),
              ],
            ),
          ),

        if (_position == null && _error == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Tap the button to get your current location',
                  style: TextStyle(color: Colors.grey)),
            ),
          ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),

        // Code snippet
        const Text('Required permissions:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Android (AndroidManifest.xml):\n'
            '  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />\n\n'
            'iOS (Info.plist):\n'
            '  <key>NSLocationWhenInUseUsageDescription</key>\n'
            '  <string>We need your location to show nearby features</string>',
            style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// TAB 2: Camera / Gallery
// ======================================================================

class _CameraTab extends StatefulWidget {
  const _CameraTab();

  @override
  State<_CameraTab> createState() => _CameraTabState();
}

class _CameraTabState extends State<_CameraTab> {
  final _picker = ImagePicker();
  XFile? _image;
  String? _error;
  bool _loading = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isWeb) {
        // Simulate on web
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _image = XFile('simulated_${source.name}.jpg');
          _loading = false;
        });
        return;
      }

      final image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        setState(() {
          _error = 'No image selected.';
          _loading = false;
        });
        return;
      }

      setState(() {
        _image = image;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoBanner(
          icon: Icons.camera_alt,
          message:
              'image_picker lets you grab photos from the camera or gallery. '
              'Always set maxWidth/maxHeight to avoid OOM on large images.',
        ),
        const SizedBox(height: 16),

        // Buttons
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _loading ? null : () => _pickImage(ImageSource.camera),
                icon: _loading && _image?.path.contains('camera') == true
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.camera_alt, size: 20),
                label: const Text('Camera'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _loading ? null : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library, size: 20),
                label: const Text('Gallery'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Result
        if (_image != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isWeb || _image!.path.startsWith('simulated')
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.image, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                const Text('Image selected',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_image!.path),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image, size: 48),
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _image!.name,
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ),

        if (_error != null)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(_error!,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),

        if (_image == null && _error == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Tap Camera or Gallery to select a photo',
                  style: TextStyle(color: Colors.grey)),
            ),
          ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),

        // Permissions note
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber, size: 18, color: Colors.amber),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Camera requires real device permissions.\n\n'
                  'Android: Add <uses-permission android:name="android.permission.CAMERA" />\n\n'
                  'iOS: Add NSCameraUsageDescription & NSPhotoLibraryUsageDescription to Info.plist',
                  style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
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
// TAB 3: Biometrics
// ======================================================================

class _BiometricsTab extends StatefulWidget {
  const _BiometricsTab();

  @override
  State<_BiometricsTab> createState() => _BiometricsTabState();
}

class _BiometricsTabState extends State<_BiometricsTab> {
  bool _authenticated = false;
  bool _loading = false;
  String? _error;

  Future<void> _authenticate() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // Simulate biometric check — real implementation uses local_auth:
    //
    //   final auth = LocalAuthentication();
    //   final didAuthenticate = await auth.authenticate(
    //     localizedReason: 'Please authenticate to unlock',
    //     options: const AuthenticationOptions(
    //       biometricOnly: true,
    //       stickyAuth: true,
    //     ),
    //   );

    await Future.delayed(const Duration(seconds: 2));

    // Random result for demo purposes
    final success = math.Random().nextBool();

    if (success) {
      setState(() {
        _authenticated = true;
        _loading = false;
      });
    } else {
      setState(() {
        _error = 'Authentication failed. Try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoBanner(
          icon: Icons.fingerprint,
          message:
              'Biometrics (Face ID / fingerprint) provide quick, secure '
              'authentication. The local_auth package wraps both platforms.',
        ),
        const SizedBox(height: 20),

        // Status icon
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _authenticated
                ? const Icon(Icons.check_circle,
                    size: 80, color: Colors.green, key: ValueKey('check'))
                : Icon(Icons.fingerprint,
                    size: 80,
                    color: _loading ? Colors.grey : Colors.teal,
                    key: const ValueKey('finger')),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          _authenticated ? 'Authenticated!' : 'Tap to authenticate',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _authenticated ? Colors.green : null,
          ),
        ),
        const SizedBox(height: 20),

        Center(
          child: FilledButton.icon(
            onPressed: _loading ? null : _authenticate,
            icon: _loading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(_authenticated ? Icons.lock_open : Icons.lock),
            label: Text(_loading
                ? 'Authenticating...'
                : _authenticated
                    ? 'Authenticate Again'
                    : 'Start Authentication'),
          ),
        ),

        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
          ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),

        // Code snippet
        const Text('local_auth usage:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '// 1. Add to pubspec.yaml:\n'
            'dependencies:\n'
            '  local_auth: ^2.3.0\n\n'
            '// 2. In your Dart code:\n'
            "import 'package:local_auth/local_auth.dart';\n\n"
            'final auth = LocalAuthentication();\n'
            'final canCheck = await auth.canCheckBiometrics;\n\n'
            'final didAuth = await auth.authenticate(\n'
            "  localizedReason: 'Unlock to continue',\n"
            ');',
            style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// TAB 4: Haptics
// ======================================================================

class _HapticsTab extends StatelessWidget {
  const _HapticsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoBanner(
          icon: Icons.vibration,
          message:
              'HapticFeedback provides tactile responses built into Flutter — '
              'no extra packages needed. Use them sparingly for meaningful events.',
        ),
        const SizedBox(height: 20),

        // Light impact
        _HapticButton(
          icon: Icons.touch_app,
          title: 'Light Impact',
          subtitle: 'For subtle UI feedback (button taps, toggles)',
          onTap: () {
            HapticFeedback.lightImpact();
            _showSnack(context, 'lightImpact()');
          },
        ),

        // Medium impact
        _HapticButton(
          icon: Icons.touch_app,
          title: 'Medium Impact',
          subtitle: 'For confirmation events (item selected, action completed)',
          onTap: () {
            HapticFeedback.mediumImpact();
            _showSnack(context, 'mediumImpact()');
          },
        ),

        // Heavy impact
        _HapticButton(
          icon: Icons.touch_app,
          title: 'Heavy Impact',
          subtitle: 'For significant events (dangerous action, irreversible)',
          onTap: () {
            HapticFeedback.heavyImpact();
            _showSnack(context, 'heavyImpact()');
          },
        ),

        // Selection click
        _HapticButton(
          icon: Icons.mouse,
          title: 'Selection Click',
          subtitle: 'For scroll wheel / picker interactions',
          onTap: () {
            HapticFeedback.selectionClick();
            _showSnack(context, 'selectionClick()');
          },
        ),

        // Vibrate
        _HapticButton(
          icon: Icons.vibration,
          title: 'Vibrate',
          subtitle: 'System-level vibration (longer than impacts)',
          onTap: () {
            HapticFeedback.vibrate();
            _showSnack(context, 'vibrate()');
          },
        ),

        const SizedBox(height: 16),

        // Tip card
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
                    'Haptics may not work on all platforms (web, emulators). '
                    'Test on real devices. Never over-use — haptic fatigue is real.',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }
}

class _HapticButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HapticButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.withValues(alpha: 0.1),
          child: Icon(icon, color: Colors.indigo),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.play_arrow),
        onTap: onTap,
      ),
    );
  }
}

// ======================================================================
// TAB 5: Platform Channels
// ======================================================================

class _PlatformTab extends StatelessWidget {
  const _PlatformTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoBanner(
          icon: Icons.developer_mode,
          message:
              'Platform Channels let Dart send messages to native Kotlin/Swift '
              'code and receive responses. Used for features no plugin covers yet.',
        ),
        const SizedBox(height: 20),

        // Platform identity
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  _isWeb
                      ? Icons.web
                      : Platform.isAndroid
                          ? Icons.android
                          : Platform.isIOS
                              ? Icons.phone_iphone
                              : Icons.desktop_windows,
                  size: 56,
                  color: Colors.teal,
                ),
                const SizedBox(height: 12),
                Text(_platformName,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  _isWeb
                      ? 'Running in browser'
                      : 'Version: ${Platform.operatingSystemVersion}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Channel code example
        const Text('MethodChannel Example:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "// Dart side:\n"
            "static const platform = MethodChannel('com.example/app');\n\n"
            "Future<String> getBatteryLevel() async {\n"
            "  try {\n"
            "    final result = await platform.invokeMethod<int>('getBatteryLevel');\n"
            "    return 'Battery: \${result.toString()}%';\n"
            "  } on PlatformException catch (e) {\n"
            "    return 'Failed: \${e.message}';\n"
            "  }\n"
            "}\n\n"
            "// Android (Kotlin) side:\n"
            'val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example/app")\n'
            'channel.setMethodCallHandler { call, result ->\n'
            '  if (call.method == "getBatteryLevel") {\n'
            '    val battery = 85 // native Android API call\n'
            '    result.success(battery)\n'
            '  }\n'
            '}',
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
          ),
        ),

        const SizedBox(height: 16),

        // Channel type comparison
        const Text('Channel Types:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),

        _ChannelCard(
          name: 'MethodChannel',
          description:
              'Call a function on the native side and get a result back. '
              'Best for one-shot operations (get battery, check sensors).',
        ),
        _ChannelCard(
          name: 'EventChannel',
          description:
              'Stream continuous data from native to Dart. '
              'Best for sensor updates, GPS streams, battery status changes.',
        ),
        _ChannelCard(
          name: 'BasicMessageChannel',
          description:
              'Send and receive strings/semiserialized messages. '
              'Lower-level than MethodChannel, good for custom protocols.',
        ),

        const SizedBox(height: 12),
        const Text(
          'Tip: Always prefer a well-maintained plugin from pub.dev over '
          'writing your own platform channel. Only use channels when no '
          'plugin exists for your use case.',
          style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final String name;
  final String description;

  const _ChannelCard({required this.name, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(description,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
