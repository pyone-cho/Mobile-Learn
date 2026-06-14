import 'package:flutter/material.dart';

class NavigationLesson extends StatelessWidget {
  const NavigationLesson({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Navigator.push / pop',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),

          // Push to a new screen
          _NavButton(
            icon: Icons.arrow_forward,
            label: 'Push — Simple screen',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const _DetailScreen(
                    title: 'Pushed Screen',
                    body: 'This screen was pushed onto the navigation stack. '
                        'Press back to return.',
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Push with data
          _NavButton(
            icon: Icons.send,
            label: 'Push — with data',
            onTap: () async {
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (_) => const _DataScreen(),
                ),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result ?? 'No data returned'),
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 24),
          const Text('Named Routes (via MaterialApp)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text(
            'For larger apps, define routes in MaterialApp.routes. '
            'Push with Navigator.pushNamed(context, "/profile").',
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 24),
          const Text('Common Navigation Patterns',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),

          // Replace current screen
          _NavButton(
            icon: Icons.swap_horiz,
            label: 'PushReplacement (no back)',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const _DetailScreen(
                    title: 'Replacement',
                    body: 'This replaced the previous screen. '
                        'Pressing back exits the lesson.',
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Pop until specific route
          _NavButton(
            icon: Icons.clear_all,
            label: 'popUntil (go back to root)',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('Nested Screen')),
                    body: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('You are 2 levels deep'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () =>
                                Navigator.popUntil(context, (r) => r.isFirst),
                            icon: const Icon(Icons.home),
                            label: const Text('popUntil — back to home'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '💡 Navigator.push = stack of screens. Push adds, '
                    'pop removes. Use pushReplacement to remove the current '
                    'screen (e.g. login -> home).',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple detail screen
class _DetailScreen extends StatelessWidget {
  final String title;
  final String body;

  const _DetailScreen({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(body, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}

// Screen that sends data back
class _DataScreen extends StatelessWidget {
  const _DataScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick a fruit')),
      body: ListView(
        children: ['Apple', 'Banana', 'Cherry', 'Date']
            .map((fruit) => ListTile(
                  title: Text(fruit),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(context, fruit),
                ))
            .toList(),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
