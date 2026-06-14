/// Phase 4: Error Handling — timeouts, retries, connectivity, offline state
///
/// Real APIs fail. This lesson shows how to handle every failure mode
/// gracefully.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ErrorHandlingLesson extends StatelessWidget {
  const ErrorHandlingLesson({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Error Handling'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Timeout'),
              Tab(text: 'Retry'),
              Tab(text: 'No Internet'),
              Tab(text: 'All States'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TimeoutExample(),
            _RetryExample(),
            _NoInternetExample(),
            _AllStatesExample(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TAB 1: Timeout handling
// ============================================================

class _TimeoutExample extends StatefulWidget {
  const _TimeoutExample();

  @override
  State<_TimeoutExample> createState() => _TimeoutExampleState();
}

class _TimeoutExampleState extends State<_TimeoutExample> {
  String _status = 'Tap the button to test';
  bool _loading = false;

  Future<void> _fetchWithTimeout() async {
    setState(() {
      _loading = true;
      _status = 'Connecting...';
    });

    try {
      // Using a slow endpoint that will timeout
      final response = await http
          .get(
            Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _status = '✅ Success: ${data['title']}');
      } else {
        setState(() => _status = '❌ HTTP ${response.statusCode}');
      }
    } on TimeoutException {
      setState(() => _status =
          '⏱️ Timeout! The server took too long (3s limit).\n\nIn real apps, show a friendly message instead of crashing.');
    } on SocketException {
      setState(() => _status = '🔌 No connection (SocketException)');
    } catch (e) {
      setState(() => _status = '❌ Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Timeout with .timeout()',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text(
            'http.get() + .timeout(3s) catches slow servers.\n'
            'Without this, your app would hang forever.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loading ? null : _fetchWithTimeout,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.timer),
            label: Text(_loading ? 'Waiting...' : 'Test Timeout (3s)'),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_status),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TAB 2: Retry pattern
// ============================================================

class _RetryExample extends StatefulWidget {
  const _RetryExample();

  @override
  State<_RetryExample> createState() => _RetryExampleState();
}

class _RetryExampleState extends State<_RetryExample> {
  String _status = 'Ready';
  bool _loading = false;
  int _attempts = 0;

  Future<void> _fetchWithRetry() async {
    setState(() {
      _loading = true;
      _attempts = 0;
      _status = '';
    });

    const maxRetries = 3;

    for (int i = 0; i < maxRetries; i++) {
      _attempts++;
      setState(() => _status = 'Attempt $_attempts of $maxRetries...');

      try {
        final response = await http
            .get(
              Uri.parse(
                  'https://jsonplaceholder.typicode.com/posts/1'),
            )
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() =>
              _status = '✅ Success on attempt $_attempts!\n\n${data['title']}');
          return;
        }
      } on TimeoutException {
        setState(() =>
            _status = '⏱️ Timeout (attempt $_attempts)\n${i < maxRetries - 1 ? "Retrying..." : "Giving up"}');
      } on SocketException {
        setState(() =>
            _status = '🔌 No connection (attempt $_attempts)\n${i < maxRetries - 1 ? "Retrying..." : "Giving up"}');
      } catch (e) {
        setState(() => _status = '❌ $e');
        return;
      }

      // Wait before retry (exponential backoff)
      if (i < maxRetries - 1) {
        await Future.delayed(Duration(seconds: (i + 1)));
      }
    }

    setState(() => _status = '❌ Failed after $_attempts attempts.\nTry again later.');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Retry with Exponential Backoff',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text(
            '3 retries with 1s → 2s delays between attempts.\n'
            'In production, use a retry package or write a helper.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          const Text('Pattern:',
              style: TextStyle(fontWeight: FontWeight.w600)),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const SelectableText(
              'for (int i = 0; i < maxRetries; i++) {\n'
              '  try { return await fetch(); }\n'
              '  catch (e) { await Future.delayed(backoff); }\n'
              '}\n'
              'throw Exception("Failed after N retries");',
              style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loading ? null : _fetchWithRetry,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.replay),
            label: Text(_loading ? 'Retrying...' : 'Test Retry Logic'),
          ),
          if (_status.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(_status),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// TAB 3: No Internet detection
// ============================================================

class _NoInternetExample extends StatelessWidget {
  const _NoInternetExample();

  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Connectivity Check',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text(
            'Check internet before making API calls.\n'
            'Show a friendly offline screen instead of a cryptic error.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // Offline UI example
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: const Column(
              children: [
                Icon(Icons.wifi_off, size: 48, color: Colors.orange),
                SizedBox(height: 12),
                Text('No Internet Connection',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  'Please check your connection and try again.\n'
                  'Your data is safely stored locally.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 12),
                // Real retry button would call _checkConnectivity
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text('Pattern:',
              style: TextStyle(fontWeight: FontWeight.w600)),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const SelectableText(
              'try {\n'
              '  await InternetAddress.lookup("google.com");\n'
              '  // Connected — make API call\n'
              '} on SocketException {\n'
              '  // Not connected — show offline UI\n'
              '}',
              style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),

          const SizedBox(height: 16),

          FilledButton.icon(
            onPressed: () async {
              final connected = await _checkConnectivity();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(connected ? '✅ Connected!' : '❌ No connection'),
                  backgroundColor: connected ? Colors.green : Colors.red,
                ),
              );
            },
            icon: const Icon(Icons.wifi_find),
            label: const Text('Check My Connection'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TAB 4: All states demo
// ============================================================

enum _ApiState { idle, loading, success, error, empty }

class _AllStatesExample extends StatefulWidget {
  const _AllStatesExample();

  @override
  State<_AllStatesExample> createState() => _AllStatesExampleState();
}

class _AllStatesExampleState extends State<_AllStatesExample> {
  _ApiState _state = _ApiState.idle;
  String _message = '';

  Future<void> _simulateState(_ApiState target) async {
    setState(() {
      _state = _ApiState.loading;
      _message = 'Loading...';
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _state = target;
      _message = switch (target) {
        _ApiState.success => '✅ Data loaded successfully!\nHTTP 200 — ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        _ApiState.error => '❌ Something went wrong.\nHTTP 500 — Internal Server Error\n\nCheck your connection and retry.',
        _ApiState.empty => '📭 No data found.\nThe server responded but returned 0 results.',
        _ApiState.idle => '',
        _ApiState.loading => '',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Simulate Different States',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Tap a button to see how each state looks and feels.',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),

          // State buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StateButton('✅ Success', _ApiState.success, Colors.green, () => _simulateState(_ApiState.success)),
              _StateButton('❌ Error', _ApiState.error, Colors.red, () => _simulateState(_ApiState.error)),
              _StateButton('📭 Empty', _ApiState.empty, Colors.grey, () => _simulateState(_ApiState.empty)),
            ],
          ),

          const SizedBox(height: 16),

          // State display
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildStateWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildStateWidget() {
    switch (_state) {
      case _ApiState.idle:
        return Container(
          key: const ValueKey('idle'),
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          child: const Column(
            children: [
              Icon(Icons.touch_app, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Tap a button above', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      case _ApiState.loading:
        return Container(
          key: const ValueKey('loading'),
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          child: const Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        );
      case _ApiState.success:
        return Container(
          key: const ValueKey('success'),
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 32),
              const SizedBox(width: 16),
              Expanded(child: Text(_message)),
            ],
          ),
        );
      case _ApiState.empty:
        return Container(
          key: const ValueKey('empty'),
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.inbox, color: Colors.grey, size: 32),
              SizedBox(width: 16),
              Expanded(child: Text('📭 No data found.\nThe server responded but returned 0 results.')),
            ],
          ),
        );
      case _ApiState.error:
        return Container(
          key: const ValueKey('error'),
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 32),
              SizedBox(width: 16),
              Expanded(child: Text('❌ Something went wrong.\nHTTP 500 — Internal Server Error')),
            ],
          ),
        );
    }
  }
}

Widget _StateButton(String label, _ApiState state, Color color, VoidCallback onTap) {
  return ElevatedButton.icon(
    onPressed: onTap,
    icon: Icon(
      switch (state) {
        _ApiState.success => Icons.check,
        _ApiState.error => Icons.error,
        _ApiState.empty => Icons.inbox,
        _ => Icons.help,
      },
      size: 18,
    ),
    label: Text(label),
    style: ElevatedButton.styleFrom(backgroundColor: color.withValues(alpha: 0.2)),
  );
}
