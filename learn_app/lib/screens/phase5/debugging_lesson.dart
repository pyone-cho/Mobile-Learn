/// Phase 5: Debugging & Profiling
///
/// Interactive lesson covering:
///   - Logging: debugPrint, structured logs, log levels
///   - Rebuilds: const constructors, RepaintBoundary, tracking rebuilds
///   - Performance: efficient lists, keys, const vs rebuild
///   - Error Handling: FlutterError.onError, ErrorWidget, graceful degradation
///   - DevTools: profiling, memory, timeline, inspector

import 'dart:math' as math;
import 'package:flutter/material.dart';

class DebuggingLesson extends StatelessWidget {
  const DebuggingLesson({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Debugging & Profiling'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Logging'),
              Tab(text: 'Rebuilds'),
              Tab(text: 'Performance'),
              Tab(text: 'Errors'),
              Tab(text: 'DevTools'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LoggingTab(),
            _RebuildsTab(),
            _PerformanceTab(),
            _ErrorsTab(),
            _DevToolsTab(),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// TAB 1: Logging
// ======================================================================

class _LoggingTab extends StatefulWidget {
  const _LoggingTab();

  @override
  State<_LoggingTab> createState() => _LoggingTabState();
}

class _LoggingTabState extends State<_LoggingTab> {
  final _logs = <_LogEntry>[];
  int _counter = 0;

  void _log(int level, String message) {
    // In a real app these would be debugPrint(...) calls.
    // Here we collect them for the in-app display.
    final entry = _LogEntry(
      level: level,
      message: message,
      time: DateTime.now(),
    );
    setState(() => _logs.insert(0, entry));

    // This is what you'd write in production:
    debugPrint('[${_levelLabel(level)}] $message');
  }

  String _levelLabel(int level) {
    switch (level) {
      case 0:
        return 'VERBOSE';
      case 1:
        return 'INFO';
      case 2:
        return 'WARNING';
      case 3:
        return 'ERROR';
      default:
        return 'LOG';
    }
  }

  Color _levelColor(int level) {
    switch (level) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Controls
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () {
                  _counter++;
                  _log(1, 'Button tapped (#$_counter)');
                },
                icon: const Icon(Icons.touch_app, size: 18),
                label: Text('Tap ($_counter)'),
              ),
              OutlinedButton.icon(
                onPressed: () => _log(
                  2,
                  'Warning: network timeout simulated',
                ),
                icon: const Icon(Icons.warning_amber, size: 18),
                label: const Text('Warn'),
              ),
              OutlinedButton.icon(
                onPressed: () => _log(
                  3,
                  'Error: failed to load user profile',
                ),
                icon: const Icon(Icons.error_outline, size: 18),
                label: const Text('Error'),
              ),
              TextButton(
                onPressed: () => setState(() => _logs.clear()),
                child: const Text('Clear'),
              ),
            ],
          ),
        ),

        // Explanation
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Use debugPrint() instead of print() in Flutter — it throttles '
            'output so the console doesn\'t flood on rapid calls. '
            'In production, route logs through a proper logging framework.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),

        const SizedBox(height: 8),

        // Log display
        Expanded(
          child: _logs.isEmpty
              ? const Center(
                  child: Text('Tap a button to generate a log entry',
                      style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final entry = _logs[index];
                    return ListTile(
                      dense: true,
                      leading: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _levelColor(entry.level),
                        ),
                      ),
                      title: Text(
                        '[${_levelLabel(entry.level)}] ${entry.message}',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: _levelColor(entry.level),
                        ),
                      ),
                      trailing: Text(
                        '${entry.time.hour}:${entry.time.minute.toString().padLeft(2, '0')}:${entry.time.second.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _LogEntry {
  final int level;
  final String message;
  final DateTime time;
  _LogEntry({
    required this.level,
    required this.message,
    required this.time,
  });
}

// ======================================================================
// TAB 2: Rebuilds
// ======================================================================

class _RebuildsTab extends StatefulWidget {
  const _RebuildsTab();

  @override
  State<_RebuildsTab> createState() => _RebuildsTabState();
}

class _RebuildsTabState extends State<_RebuildsTab> {
  int _counter = 0;

  void _increment() => setState(() => _counter++);

  @override
  Widget build(BuildContext context) {
    debugPrint('[_RebuildsTab] build() called — counter=$_counter');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoBanner(
          icon: Icons.info_outline,
          message:
              'Every time setState() is called, the entire build() method '
              're-runs. Notice which widgets below log "rebuilt" vs "SKIPPED".',
        ),
        const SizedBox(height: 16),

        // Counter controls
        Center(
          child: Column(
            children: [
              Text('Counter: $_counter',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _increment,
                icon: const Icon(Icons.add),
                label: const Text('Increment (rebuilds parent)'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
        const Text('Widgets below:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),

        const SizedBox(height: 8),

        // Non-const widget — rebuilds every time
        const _RebuildTracker(label: 'Non-const child — REBUILDS'),

        // Const widget — stays the same, Flutter skips it
        const _RebuildTracker(label: 'Const child — SKIPPED by Flutter'),

        const SizedBox(height: 8),

        // Explanation card
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Text('Pro Tip',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Making constructors const lets Flutter short-circuit rebuilds. '
                  'Wrap expensive subtrees in RepaintBoundary or use const '
                  'constructors where possible.',
                  style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A widget that logs every time it builds.
/// When instantiated with `const`, Flutter can skip rebuilding it entirely.
class _RebuildTracker extends StatelessWidget {
  final String label;
  const _RebuildTracker({required this.label});

  @override
  Widget build(BuildContext context) {
    debugPrint('  ▸ _RebuildTracker("$label") built');
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: const Icon(Icons.construction, size: 20),
        title: Text(label, style: const TextStyle(fontSize: 13)),
        subtitle: Text(
          'Built at ${DateTime.now().second}s ${DateTime.now().millisecond}ms',
          style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
        ),
      ),
    );
  }
}

// ======================================================================
// TAB 3: Performance
// ======================================================================

class _PerformanceTab extends StatefulWidget {
  const _PerformanceTab();

  @override
  State<_PerformanceTab> createState() => _PerformanceTabState();
}

class _PerformanceTabState extends State<_PerformanceTab> {
  bool _useBuilder = true;
  final _items = List.generate(100, (i) => 'Item #$i');

  // This simulates an expensive build method
  Widget _buildItem(String item, int index) {
    // Simulate work — DON'T do this in production!
    final hash = math.Random(index).nextDouble();
    final color = Color.fromARGB(
      255,
      (hash * 100).toInt() + 50,
      (hash * 150).toInt() + 50,
      (hash * 200).toInt() + 50,
    );

    return Container(
      key: ValueKey(item),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.3),
          child: Text('$index', style: TextStyle(color: color)),
        ),
        title: Text(item),
        subtitle: Text('Hash: ${hash.toStringAsFixed(4)}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = List.generate(
      _items.length,
      (i) => _buildItem(_items[i], i),
    );

    return Column(
      children: [
        // Controls
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Text('ListView.builder: '),
              Switch(
                value: _useBuilder,
                onChanged: (v) => setState(() => _useBuilder = v),
              ),
              Text(_useBuilder ? 'ON' : 'OFF'),
            ],
          ),
        ),

        // Explanation
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ListView.builder only builds visible items. Turning it off '
            'builds all 100 items upfront — try scrolling both modes.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),

        // Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _StatChip(
                Icon(Icons.view_column, size: 14),
                'Items: ${_items.length}',
              ),
              const SizedBox(width: 8),
              _StatChip(
                Icon(Icons.bolt, size: 14, color: _useBuilder ? Colors.green : Colors.red),
                _useBuilder ? 'Lazy (fast)' : 'Eager (slow)',
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // List
        Expanded(
          child: _useBuilder
              ? ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (_, i) => _buildItem(_items[i], i),
                )
              : ListView(children: list),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final Widget icon;
  final String label;
  const _StatChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

// ======================================================================
// TAB 4: Error Handling
// ======================================================================

class _ErrorsTab extends StatefulWidget {
  const _ErrorsTab();

  @override
  State<_ErrorsTab> createState() => _ErrorsTabState();
}

class _ErrorsTabState extends State<_ErrorsTab> {
  final _errors = <String>[];

  @override
  void initState() {
    super.initState();

    // Override Flutter's error handler for this lesson
    final originalHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      _recordError(details.exceptionAsString());
      // Call original to preserve normal behaviour
      originalHandler?.call(details);
    };
  }

  void _recordError(String message) {
    if (!mounted) return;
    setState(() => _errors.insert(0, '${DateTime.now().second}s: $message'));
  }

  void _triggerNetworkError() {
    try {
      throw const FormatException('Invalid JSON response (simulated)');
    } catch (e) {
      _recordError('Caught: $e');
    }
  }

  void _triggerAssertion() {
    try {
      // ignore: only_throw_errors
      throw 'Simulated network timeout after 10s';
    } catch (e) {
      _recordError('Recovered: $e');
    }
  }

  @override
  void dispose() {
    // Restore default — in a real app you'd save and restore properly
    FlutterError.onError = (details) {
      debugPrint('${details.exception}');
    };
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoBanner(
          icon: Icons.shield_outlined,
          message:
              'Always catch and handle errors gracefully. Use try-catch for '
              'network calls, FlutterError.onError for framework errors, and '
              'ErrorWidget.builder for a custom crash UI.',
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _triggerNetworkError,
                icon: const Icon(Icons.wifi_off, size: 18),
                label: const Text('Network Error'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _triggerAssertion,
                icon: const Icon(Icons.error, size: 18),
                label: const Text('Throw String'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton.icon(
                onPressed: () => setState(() => _errors.clear()),
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Clear'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Safe area demo
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Safe Widget Pattern',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _SafeWidget(
                  future: _fetchThatMightFail(),
                  loadingMessage: 'Fetching simulated data...',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        if (_errors.isNotEmpty) ...[
          const Text('Error Log:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          ..._errors.map(
            (e) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Text(
                e,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],

        if (_errors.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text('No errors yet — tap a button to simulate one',
                  style: TextStyle(color: Colors.grey)),
            ),
          ),
      ],
    );
  }

  Future<String> _fetchThatMightFail() async {
    await Future.delayed(const Duration(seconds: 1));
    // Randomly succeed or fail
    if (math.Random().nextBool()) {
      return '✅ Data loaded successfully!';
    } else {
      throw Exception('Simulated fetch failure');
    }
  }
}

class _SafeWidget extends StatelessWidget {
  final Future<String> future;
  final String loadingMessage;

  const _SafeWidget({
    required this.future,
    required this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Loading...', style: TextStyle(fontSize: 13)),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        }
        return Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Text(snapshot.data ?? '', style: const TextStyle(fontSize: 13)),
          ],
        );
      },
    );
  }
}

// ======================================================================
// TAB 5: DevTools
// ======================================================================

class _DevToolsTab extends StatelessWidget {
  const _DevToolsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _InfoBanner(
          icon: Icons.developer_board,
          message:
              'Flutter DevTools is a suite of debugging and profiling tools '
              'built into Flutter. Access it via: flutter run → then press "d" '
              'for the inspector, "p" for performance overlay.',
        ),
        const SizedBox(height: 20),

        // Tool cards
        _ToolCard(
          icon: Icons.search,
          title: 'Widget Inspector',
          subtitle: 'Select any widget on screen to see its layout, padding, '
              'constraints, and properties in real-time.',
          color: Colors.teal,
          shortcut: 'd',
        ),
        _ToolCard(
          icon: Icons.speed,
          title: 'Performance Overlay',
          subtitle: 'Shows two raster graphs: UI thread and GPU thread. '
              'Green bars = smooth; red bars = jank.',
          color: Colors.indigo,
          shortcut: 'p',
        ),
        _ToolCard(
          icon: Icons.memory,
          title: 'Memory View',
          subtitle: 'Track Dart heap usage, detect memory leaks by watching '
              'allocation grow on repeated navigation.',
          color: Colors.deepOrange,
          shortcut: 'DevTools → Memory',
        ),
        _ToolCard(
          icon: Icons.show_chart,
          title: 'Timeline / CPU Profiler',
          subtitle: 'Records every frame, event, and widget build so you can '
              'pinpoint exactly what is causing frame drops.',
          color: Colors.purple,
          shortcut: 'DevTools → Timeline',
        ),
        _ToolCard(
          icon: Icons.cell_tower,
          title: 'Network View',
          subtitle: 'Inspects HTTP traffic — request/response headers, '
              'latency, and payload sizes. Requires Dart VM.',
          color: Colors.blue,
          shortcut: 'DevTools → Network',
        ),

        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),

        // Manual overlay toggle
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Try It: Performance Overlay',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Run your app with:\n\n'
                  '  flutter run --profile\n\n'
                  'Or toggle the overlay at runtime by pressing "p" in the '
                  'terminal. The two graphs show:\n\n'
                  '  • Top (UI): widget building & layout\n'
                  '  • Bottom (GPU): rasterization & compositing\n\n'
                  'A smooth 60 FPS app shows all green bars. '
                  'Red bars mean you\'re dropping frames.',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Colors.grey.shade700,
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

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String shortcut;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.shortcut,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(shortcut,
                            style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'monospace',
                                color: color)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
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
