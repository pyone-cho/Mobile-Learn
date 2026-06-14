import 'package:flutter/material.dart';

class TabsLesson extends StatefulWidget {
  const TabsLesson({super.key});

  @override
  State<TabsLesson> createState() => _TabsLessonState();
}

class _TabsLessonState extends State<TabsLesson> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tabs & Bottom Nav'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.search), text: 'Search'),
              Tab(icon: Icon(Icons.settings), text: 'Settings'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Top TabBar content
            const Expanded(
              child: TabBarView(
                children: [
                  _TabContent(label: 'Home Tab', icon: Icons.home, color: Colors.teal),
                  _TabContent(label: 'Search Tab', icon: Icons.search, color: Colors.indigo),
                  _TabContent(label: 'Settings Tab', icon: Icons.settings, color: Colors.purple),
                ],
              ),
            ),

            // Divider
            const Divider(height: 1),

            // Bottom Navigation Bar (above system nav)
            const _BottomNavTip(),

            // Bottom Navigation Bar
            BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
              selectedItemColor: Colors.teal,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: 'Search'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _TabContent({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: color.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(label, style: TextStyle(fontSize: 20, color: color)),
        ],
      ),
    );
  }
}

class _BottomNavTip extends StatelessWidget {
  const _BottomNavTip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.amber.withValues(alpha: 0.1),
      child: const Row(
        children: [
          Icon(Icons.lightbulb, color: Colors.amber, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '💡 Top tabs: TabBar + TabBarView. '
              'Bottom nav: BottomNavigationBar + IndexedStack. '
              'Try switching both!',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
