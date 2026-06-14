/// Phase 5 Capstone: Marketplace App
///
/// Full-featured marketplace combining everything from Phases 1-5:
///   - Models & enums (Phase 1)
///   - Complex layouts with GridView, cards, tabs (Phase 2)
///   - Provider + ChangeNotifier state management (Phase 3)
///   - SharedPreferences persistence (Phase 4)
///   - Native haptics, error handling (Phase 5)
///
/// Features: feed grid, search, categories, favorites, create listing, profile

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ======================================================================
// MODELS
// ======================================================================

enum ListingCategory {
  electronics('Electronics', Icons.laptop, Colors.blue),
  fashion('Fashion', Icons.checkroom, Colors.purple),
  home('Home & Garden', Icons.home, Colors.teal),
  vehicles('Vehicles', Icons.directions_car, Colors.orange),
  sports('Sports', Icons.sports_soccer, Colors.green),
  books('Books', Icons.menu_book, Colors.brown),
  music('Music', Icons.music_note, Colors.pink),
  other('Other', Icons.more_horiz, Colors.grey);

  final String label;
  final IconData icon;
  final Color color;
  const ListingCategory(this.label, this.icon, this.color);

  static ListingCategory fromString(String s) {
    return ListingCategory.values.firstWhere(
      (c) => c.name == s,
      orElse: () => ListingCategory.other,
    );
  }
}

class Listing {
  final String id;
  String title;
  String description;
  double price;
  String imageUrl;
  ListingCategory category;
  final String seller;
  final DateTime createdAt;
  int viewCount;

  Listing({
    required this.id,
    required this.title,
    this.description = '',
    required this.price,
    this.imageUrl = '',
    required this.category,
    required this.seller,
    DateTime? createdAt,
    this.viewCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'category': category.name,
        'seller': seller,
        'createdAt': createdAt.toIso8601String(),
        'viewCount': viewCount,
      };

  factory Listing.fromJson(Map<String, dynamic> j) => Listing(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        price: (j['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: j['imageUrl'] as String? ?? '',
        category: ListingCategory.fromString(j['category'] as String? ?? 'other'),
        seller: j['seller'] as String? ?? '',
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? ''),
        viewCount: (j['viewCount'] as num?)?.toInt() ?? 0,
      );
}

// ======================================================================
// PROVIDERS
// ======================================================================

class MarketplaceProvider extends ChangeNotifier {
  List<Listing> _listings = [];
  bool _loading = true;
  String _searchQuery = '';
  ListingCategory? _categoryFilter;
  List<Listing> get listings {
    var results = List<Listing>.from(_listings);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      results = results.where((l) =>
          l.title.toLowerCase().contains(q) ||
          l.description.toLowerCase().contains(q)).toList();
    }

    if (_categoryFilter != null) {
      results = results.where((l) => l.category == _categoryFilter).toList();
    }

    // Sort by newest first
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  List<Listing> get allListings => List.unmodifiable(_listings);
  bool get loading => _loading;
  String get searchQuery => _searchQuery;
  ListingCategory? get categoryFilter => _categoryFilter;
  int get listingCount => _listings.length;

  int get totalViews =>
      _listings.fold(0, (sum, l) => sum + l.viewCount);

  double get totalValue =>
      _listings.fold(0.0, (sum, l) => sum + l.price);

  // Available categories (ones that have listings)
  Set<ListingCategory> get activeCategories =>
      _listings.map((l) => l.category).toSet();

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(ListingCategory? category) {
    _categoryFilter = _categoryFilter == category ? null : category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _categoryFilter = null;
    notifyListeners();
  }

  Future<void> loadListings() async {
    _loading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('marketplace_listings');

      if (json != null) {
        final List<dynamic> data = jsonDecode(json);
        _listings = data
            .map((j) => Listing.fromJson(j as Map<String, dynamic>))
            .toList();
      } else {
        _listings = _seedData();
      }
    } catch (_) {
      _listings = _seedData();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_listings.map((l) => l.toJson()).toList());
    await prefs.setString('marketplace_listings', json);
  }

  Future<void> addListing({
    required String title,
    required String description,
    required double price,
    required ListingCategory category,
  }) async {
    final listing = Listing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      price: price,
      imageUrl: 'placeholder_${category.name}.jpg',
      category: category,
      seller: 'You',
    );

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    _listings.insert(0, listing);
    notifyListeners();
    await _persist();
  }

  void incrementViews(Listing listing) {
    listing.viewCount++;
    notifyListeners();
    // Don't await — fire and forget
    _persist();
  }

  static List<Listing> _seedData() {
    final now = DateTime.now();
    final categories = ListingCategory.values;
    final rng = math.Random(42);

    final items = <String>[
      'Vintage Leather Jacket', 'MacBook Pro 2021', 'Mountain Bike',
      'Handmade Ceramic Vase', 'Guitar Fender Stratocaster', 'Harry Potter Box Set',
      'Running Shoes - Size 10', 'Antique Desk Lamp', 'Samsung 4K Monitor',
      'Acoustic Guitar Bundle', 'Winter Jacket - North Face', 'Mechanical Keyboard',
      'Plant Collection (5 pots)', 'Camera Lens 50mm', 'Board Game Collection',
      'Electric Scooter', 'Yoga Mat Premium', 'Programming Books Bundle',
      'Wireless Headphones', 'Coffee Maker Deluxe',
    ];

    return List.generate(items.length, (i) {
      final cat = categories[rng.nextInt(categories.length)];
      return Listing(
        id: 'seed_$i',
        title: items[i % items.length],
        description: 'Excellent condition. Barely used. '
            'Original packaging included. '
            'Price is negotiable for quick sale.',
        price: 5.0 + rng.nextDouble() * 495,
        category: cat,
        seller: ['Alice', 'Bob', 'Charlie', 'Diana', 'Eve'][rng.nextInt(5)],
        createdAt: now.subtract(Duration(hours: rng.nextInt(168))),
        viewCount: rng.nextInt(200),
      );
    });
  }
}

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favoritedIds = {};

  Set<String> get favoritedIds => Set.unmodifiable(_favoritedIds);
  int get count => _favoritedIds.length;

  bool isFavorited(String id) => _favoritedIds.contains(id);

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorited_ids');
    if (ids != null) {
      _favoritedIds.addAll(ids);
      notifyListeners();
    }
  }

  Future<void> toggle(String id) async {
    if (_favoritedIds.contains(id)) {
      _favoritedIds.remove(id);
    } else {
      HapticFeedback.mediumImpact();
      _favoritedIds.add(id);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorited_ids', _favoritedIds.toList());
  }
}

// ======================================================================
// APP ENTRY
// ======================================================================

class CapstoneMarketplace extends StatelessWidget {
  const CapstoneMarketplace({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const _MarketplaceShell(),
    );
  }
}

class _MarketplaceShell extends StatefulWidget {
  const _MarketplaceShell();

  @override
  State<_MarketplaceShell> createState() => _MarketplaceShellState();
}

class _MarketplaceShellState extends State<_MarketplaceShell> {
  int _tabIndex = 0;

  final _screens = const [
    _FeedScreen(),
    _FavoritesScreen(),
    _CreateScreen(),
    _ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceProvider>().loadListings();
      context.read<FavoritesProvider>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MarketplaceProvider>().loadListings(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Sell'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ======================================================================
// TAB 1: FEED
// ======================================================================

class _FeedScreen extends StatefulWidget {
  const _FeedScreen();

  @override
  State<_FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<_FeedScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Loading listings...'),
              ],
            ),
          );
        }

        final listings = provider.listings;

        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search listings...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  suffixIcon: provider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            provider.setSearch('');
                          },
                        )
                      : null,
                ),
                onChanged: provider.setSearch,
              ),
            ),

            // Category chips
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                children: [
                  _CategoryChip(
                    label: 'All',
                    icon: Icons.grid_view,
                    selected: provider.categoryFilter == null,
                    onTap: () => provider.setCategoryFilter(null),
                  ),
                  ...ListingCategory.values.map((c) => _CategoryChip(
                        label: c.label,
                        icon: c.icon,
                        selected: provider.categoryFilter == c,
                        color: c.color,
                        onTap: () => provider.setCategoryFilter(c),
                      )),
                ],
              ),
            ),

            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              child: Row(
                children: [
                  Text(
                    '${listings.length} ${listings.length == 1 ? 'listing' : 'listings'}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (provider.categoryFilter != null ||
                      provider.searchQuery.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        _searchCtrl.clear();
                        provider.clearFilters();
                      },
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Clear filters',
                          style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ),

            // Grid
            Expanded(
              child: listings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text('No listings found',
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          const Text('Try a different search or category',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: provider.loadListings,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: listings.length,
                        itemBuilder: (context, index) =>
                            _ListingCard(listing: listings[index]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Colors.grey;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        avatar: Icon(icon, size: 16, color: selected ? Colors.white : chipColor),
        selected: selected,
        selectedColor: chipColor,
        checkmarkColor: Colors.white,
        onSelected: (_) => onTap(),
        labelStyle: TextStyle(
          fontSize: 11,
          color: selected ? Colors.white : null,
        ),
      ),
    );
  }
}

// ======================================================================
// LISTING CARD
// ======================================================================

class _ListingCard extends StatelessWidget {
  final Listing listing;

  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isFav = favorites.isFavorited(listing.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.read<MarketplaceProvider>().incrementViews(listing);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _DetailScreen(listing: listing),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: listing.category.color.withValues(alpha: 0.12),
                  gradient: LinearGradient(
                    colors: [
                      listing.category.color.withValues(alpha: 0.08),
                      listing.category.color.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        listing.category.icon,
                        size: 40,
                        color: listing.category.color.withValues(alpha: 0.4),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isFav ? Colors.red : Colors.grey,
                          ),
                          onPressed: () => favorites.toggle(listing.id),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.visibility,
                                size: 10, color: Colors.white70),
                            const SizedBox(width: 2),
                            Text('${listing.viewCount}',
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 11, color: Colors.grey.shade500),
                      const SizedBox(width: 3),
                      Text(listing.seller,
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade500)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${listing.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: listing.category.color,
                    ),
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

// ======================================================================
// DETAIL SCREEN
// ======================================================================

class _DetailScreen extends StatelessWidget {
  final Listing listing;

  const _DetailScreen({required this.listing});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isFav = favorites.isFavorited(listing.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Details'),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : null,
            ),
            onPressed: () => favorites.toggle(listing.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero image area
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: listing.category.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                listing.category.icon,
                size: 80,
                color: listing.category.color.withValues(alpha: 0.3),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Price & title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(listing.title,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              Text(
                '\$${listing.price.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: listing.category.color),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Seller & meta
          Row(
            children: [
              const CircleAvatar(
                radius: 14,
                child: Icon(Icons.person, size: 18),
              ),
              const SizedBox(width: 8),
              Text(listing.seller,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              const Spacer(),
              Icon(Icons.visibility, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text('${listing.viewCount} views',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 6),

          // Category tag
          Chip(
            avatar: Icon(listing.category.icon,
                size: 16, color: listing.category.color),
            label: Text(listing.category.label,
                style: TextStyle(color: listing.category.color)),
            side: BorderSide(color: listing.category.color.withValues(alpha: 0.3)),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Description
          const Text('Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            listing.description,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),

          const SizedBox(height: 8),
          Text(
            'Listed ${_timeAgo(listing.createdAt)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const SizedBox(height: 24),

          // Contact button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Contacted ${listing.seller} about "${listing.title}"'),
                  ),
                );
              },
              icon: const Icon(Icons.message),
              label: const Text('Contact Seller'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: listing.category.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}

// ======================================================================
// TAB 2: FAVORITES
// ======================================================================

class _FavoritesScreen extends StatelessWidget {
  const _FavoritesScreen();

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final marketplace = context.watch<MarketplaceProvider>();

    final favListings = marketplace.allListings
        .where((l) => favorites.favoritedIds.contains(l.id))
        .toList();

    if (favorites.count == 0) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('No favorites yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Tap the heart icon on listings\nyou want to save',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text('${favListings.length} favorites',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: favListings.length,
            itemBuilder: (context, index) =>
                _ListingCard(listing: favListings[index]),
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// TAB 3: CREATE LISTING
// ======================================================================

class _CreateScreen extends StatefulWidget {
  const _CreateScreen();

  @override
  State<_CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<_CreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  ListingCategory _category = ListingCategory.other;
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    HapticFeedback.mediumImpact();

    await context.read<MarketplaceProvider>().addListing(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          price: double.parse(_priceCtrl.text.trim()),
          category: _category,
        );

    if (!mounted) return;

    setState(() => _submitting = false);

    // Reset form
    _titleCtrl.clear();
    _descCtrl.clear();
    _priceCtrl.clear();
    setState(() => _category = ListingCategory.other);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Listing created!'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _InfoBanner(
              icon: Icons.add_circle_outline,
              message:
                  'Fill in the details below to list your item for sale. '
                  'All fields marked with * are required.',
            ),
            const SizedBox(height: 20),

            // Title
            const Text('Title *',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. Vintage Record Player',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
            ),
            const SizedBox(height: 16),

            // Category
            const Text('Category *',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            DropdownButtonFormField<ListingCategory>(
              value: _category,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: ListingCategory.values.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Row(
                    children: [
                      Icon(c.icon, size: 18, color: c.color),
                      const SizedBox(width: 8),
                      Text(c.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _category = v ?? ListingCategory.other),
            ),
            const SizedBox(height: 16),

            // Price
            const Text('Price *',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixText: '\$ ',
                hintText: '0.00',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter a price';
                final price = double.tryParse(v.trim());
                if (price == null || price <= 0) return 'Enter a valid price';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            const Text('Description',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe your item... condition, size, reason for selling',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Submit
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(_submitting ? 'Publishing...' : 'Publish Listing'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// TAB 4: PROFILE
// ======================================================================

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Consumer2<MarketplaceProvider, FavoritesProvider>(
      builder: (context, marketplace, favorites, _) {
        final myListings = marketplace.listings
            .where((l) => l.seller == 'You')
            .toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar & name
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 48),
            ),
            const SizedBox(height: 12),
            const Text('You',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Member since ${DateTime.now().year}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),

            const SizedBox(height: 24),

            // Stats grid
            Row(
              children: [
                Expanded(
                    child: _StatCard(
                        Icons.inventory_2,
                        '${marketplace.listingCount}',
                        'Listings',
                        Colors.teal)),
                Expanded(
                    child: _StatCard(Icons.favorite, '${favorites.count}',
                        'Favorites', Colors.red)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _StatCard(Icons.visibility, '${marketplace.totalViews}',
                        'Total Views', Colors.blue)),
                Expanded(
                    child: _StatCard(
                        Icons.attach_money,
                        '\$${marketplace.totalValue.toStringAsFixed(0)}',
                        'Listed Value',
                        Colors.green)),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),

            // My listings header
            Row(
              children: [
                const Text('My Listings',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Text('${myListings.length} items',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),

            if (myListings.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2,
                            size: 40, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        const Text('No listings yet',
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        const Text('Tap "Sell" to create your first listing',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...myListings.map(
                (l) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: l.category.color.withValues(alpha: 0.15),
                    child: Icon(l.category.icon,
                        size: 18, color: l.category.color),
                  ),
                  title: Text(l.title,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  subtitle: Text('\$${l.price.toStringAsFixed(2)}',
                      style:
                          const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                  trailing: Text('${l.viewCount} views',
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard(this.icon, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: color)),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
