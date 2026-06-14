/// Phase 3: State Management — Provider
///
/// Provider shares state across screens without passing it through every
/// constructor. Think of it like a dependency injector that Flutter widgets
/// can "reach into" to read or change shared data.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ============================================================
// 1. MODEL — plain Dart class with ChangeNotifier
// ============================================================
// ChangeNotifier is a simple class that provides notifyListeners().
// Call it whenever data changes so Provider can rebuild listeners.

class CartModel extends ChangeNotifier {
  final List<_CartItem> _items = [];

  List<_CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  double get total => _items.fold(0.0, (s, i) => s + i.price * i.quantity);

  void add(String name, double price) {
    // Check if item already exists — increment quantity
    final existing = _items.where((i) => i.name == name).firstOrNull;
    if (existing != null) {
      existing.quantity++;
    } else {
      _items.add(_CartItem(name: name, price: price));
    }
    notifyListeners(); // 🔔 Tell all listeners to rebuild
  }

  void remove(String name) {
    _items.removeWhere((i) => i.name == name);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

// ============================================================
// 2. UI — Screens that consume the provider
// ============================================================

class ProviderLesson extends StatelessWidget {
  const ProviderLesson({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide CartModel to this screen and all its children
    return ChangeNotifierProvider(
      create: (_) => CartModel(),
      child: const _ProviderShell(),
    );
  }
}

class _ProviderShell extends StatelessWidget {
  const _ProviderShell();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider — Shared Cart'),
        actions: [
          // Consumer rebuilds only when CartModel changes
          Consumer<CartModel>(
            builder: (context, cart, _) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_cart, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${cart.itemCount}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Product listing (50% height)
          const Expanded(
            child: _ProductSection(),
          ),
          const Divider(height: 1),
          // Cart section (50% height)
          const Expanded(
            child: _CartSection(),
          ),
        ],
      ),
    );
  }
}

class _ProductSection extends StatelessWidget {
  const _ProductSection();

  static const _products = [
    ('🍎 Apples', 1.49),
    ('🍞 Bread', 2.99),
    ('🥛 Milk', 3.49),
    ('🧀 Cheese', 5.99),
    ('☕ Coffee', 8.99),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'Products',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _products.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final (name, price) = _products[index];
              return ListTile(
                title: Text(name),
                trailing: Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                // Provider.of<CartModel>(context, listen: false)
                // gives us the model WITHOUT rebuilding this widget
                onTap: () {
                  context.read<CartModel>().add(name, price);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added $name'),
                      duration: const Duration(milliseconds: 600),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CartSection extends StatelessWidget {
  const _CartSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Cart',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              // Consumer rebuilds only when cart data changes
              Consumer<CartModel>(
                builder: (context, cart, _) => cart.itemCount > 0
                    ? TextButton.icon(
                        onPressed: cart.clear,
                        icon: const Icon(Icons.delete_sweep, size: 18),
                        label: const Text('Clear'),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
        Expanded(
          // Consumer wraps the widget that depends on cart data
          child: Consumer<CartModel>(
            builder: (context, cart, _) {
              if (cart.items.isEmpty) {
                return const Center(
                  child: Text('Tap products to add them to your cart',
                      style: TextStyle(color: Colors.grey)),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text('${item.quantity}x'),
                          ),
                          title: Text(item.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red, size: 20),
                                onPressed: () => cart.remove(item.name),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('\$${cart.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            )),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CartItem {
  final String name;
  final double price;
  int quantity;

  _CartItem({required this.name, required this.price, this.quantity = 1});
}
