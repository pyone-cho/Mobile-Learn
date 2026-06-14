import 'package:flutter/material.dart';

/// Phase 3: State Management — setState
///
/// setState is Flutter's simplest state mechanism. When you call setState(),
/// Flutter rebuilds the widget. This is great for local state that only
/// affects one screen.

class SetstateLesson extends StatefulWidget {
  const SetstateLesson({super.key});

  @override
  State<SetstateLesson> createState() => _SetstateLessonState();
}

class _SetstateLessonState extends State<SetstateLesson> {
  // --- Local state variables ---
  int _counter = 0;
  bool _isDark = false;
  double _scale = 1.0;

  // setState tells Flutter "rebuild me!"
  void _increment() {
    setState(() {
      _counter++;
    });
  }

  void _reset() {
    setState(() {
      _counter = 0;
      _scale = 1.0;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('🔄 Rebuild: counter=$_counter, isDark=$_isDark');

    return Scaffold(
      backgroundColor: _isDark ? Colors.grey[900] : null,
      appBar: AppBar(
        title: const Text('setState Basics'),
        backgroundColor: _isDark ? Colors.grey[850] : null,
        actions: [
          IconButton(
            icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated scale on counter
            AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 200),
              child: Column(
                children: [
                  Text(
                    '$_counter',
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: _isDark ? Colors.white : Colors.teal,
                    ),
                  ),
                  const Text('taps'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'add',
                  onPressed: _increment,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'reset',
                  onPressed: _reset,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // What's happening explanation
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (_isDark ? Colors.grey[800] : Colors.teal)
                    ?.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.code, size: 20),
                      SizedBox(width: 8),
                      Text('How it works',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'setState() marks the widget as dirty and schedules a rebuild. '
                    'Every time _counter changes, the build() method runs again '
                    'with the new value. This is perfect for local state that '
                    'only this screen cares about.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
