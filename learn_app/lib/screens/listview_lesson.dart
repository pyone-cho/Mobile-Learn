import 'package:flutter/material.dart';

class ListviewLesson extends StatelessWidget {
  const ListviewLesson({super.key});

  // Mock data for our list examples
  static const _items = [
    _ListItem('Milk', '\$3.49', Icons.local_grocery_store, Colors.blue),
    _ListItem('Bread', '\$2.99', Icons.bakery_dining, Colors.orange),
    _ListItem('Eggs', '\$5.99', Icons.egg, Colors.brown),
    _ListItem('Apples', '\$4.49', Icons.apple, Colors.red),
    _ListItem('Cheese', '\$6.99', Icons.diamond, Colors.amber),
    _ListItem('Chicken', '\$9.99', Icons.restaurant, Colors.pink),
    _ListItem('Rice', '\$3.99', Icons.grass, Colors.green),
    _ListItem('Pasta', '\$1.99', Icons.spa, Colors.yellow),
    _ListItem('Tomato', '\$2.49', Icons.circle, Colors.redAccent),
    _ListItem('Coffee', '\$8.99', Icons.coffee, Colors.brown),
  ];

  // Movie data for grid
  static const _movies = [
    'The Matrix', 'Inception', 'Interstellar', 'Dune',
    'Blade Runner', 'Arrival', 'Tenet', 'Oppenheimer',
    'The Batman', 'Dune II', 'Godzilla', 'Wonka',
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lists & Scrolling'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'ListView'),
              Tab(text: 'GridView'),
              Tab(text: 'Custom'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildListView(),
            _buildGridView(),
            _buildCustomList(),
          ],
        ),
      ),
    );
  }

  // --- Tab 1: Simple ListView ---
  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _items[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: item.color.withValues(alpha: 0.2),
            child: Icon(item.icon, color: item.color),
          ),
          title: Text(item.name),
          trailing: Text(item.price,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item.name}: ${item.price}')),
            );
          },
        );
      },
    );
  }

  // --- Tab 2: GridView ---
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.teal.withValues(alpha: 0.1),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                _movies[index],
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Tab 3: Custom list items ---
  Widget _buildCustomList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Leading icon with badge
                Stack(
                  children: [
                    Icon(item.icon, size: 40, color: item.color),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text('${index + 1}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Title and price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: (index + 1) / _items.length,
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(item.price,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: item.color)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ListItem {
  final String name;
  final String price;
  final IconData icon;
  final Color color;

  const _ListItem(this.name, this.price, this.icon, this.color);
}
