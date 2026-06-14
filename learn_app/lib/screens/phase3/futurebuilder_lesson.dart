/// Phase 3: State Management — FutureBuilder & Loading States
///
/// FutureBuilder lets you show different UI for loading, success, error,
/// and empty states — without managing state variables yourself.

import 'package:flutter/material.dart';

class FuturebuilderLesson extends StatelessWidget {
  const FuturebuilderLesson({super.key});

  // Simulate data sources
  static Future<List<_User>> _fetchUsers({bool fail = false}) async {
    await Future.delayed(const Duration(seconds: 2));
    if (fail) throw Exception('Network error: could not reach server');
    return [
      _User('Alice', 'alice@example.com', Icons.person),
      _User('Bob', 'bob@example.com', Icons.face),
      _User('Charlie', 'charlie@example.com', Icons.smoke_free),
    ];
  }

  static Future<List<_Post>> _fetchPosts({bool empty = false}) async {
    await Future.delayed(const Duration(seconds: 1));
    if (empty) return [];
    return [
      _Post('First post!', 'Just setting up my profile...'),
      _Post('Flutter is amazing', 'Hot reload is a game changer.'),
      _Post('Learning Dart', 'Null safety makes so much sense!'),
      _Post('Hello World', 'Building my first app.'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FutureBuilder & Loading States'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Loading'),
              Tab(text: 'Error'),
              Tab(text: 'Empty'),
              Tab(text: 'Refreshing'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Normal loading → success
            _StateExample(
              future: _fetchUsers(),
              title: 'Normal Flow',
              builder: (users) => ListView.builder(
                itemCount: users.length,
                itemBuilder: (_, i) => ListTile(
                  leading: CircleAvatar(child: Icon(users[i].icon)),
                  title: Text(users[i].name),
                  subtitle: Text(users[i].email),
                ),
              ),
            ),

            // Tab 2: Error state
            _StateExample(
              future: _fetchUsers(fail: true),
              title: 'Error Flow',
              builder: (users) => ListView.builder(
                itemCount: users.length,
                itemBuilder: (_, i) => ListTile(
                  leading: CircleAvatar(child: Icon(users[i].icon)),
                  title: Text(users[i].name),
                  subtitle: Text(users[i].email),
                ),
              ),
            ),

            // Tab 3: Empty state
            _StateExample(
              future: _fetchPosts(empty: true),
              title: 'Empty Flow',
              builder: (posts) => ListView.builder(
                itemCount: posts.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(posts[i].title),
                  subtitle: Text(posts[i].body),
                ),
              ),
            ),

            // Tab 4: Pull-to-refresh
            const _RefreshExample(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Generic state handler — works with any data type
// ============================================================

class _StateExample<T> extends StatelessWidget {
  final Future<List<T>> future;
  final String title;
  final Widget Function(List<T> data) builder;

  const _StateExample({
    required this.future,
    required this.title,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: FutureBuilder<List<T>>(
            future: future,
            builder: (context, snapshot) {
              // 1. LOADING state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading data...',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              // 2. ERROR state
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 12),
                      // Note: In a real app you'd retry the actual future
                      // by rebuilding with a new Future. Here we just show
                      // the button as a pattern demonstration.
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // 3. EMPTY state
              final data = snapshot.data ?? [];
              if (data.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Nothing here yet',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              // 4. SUCCESS state — render the data
              return builder(data);
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Pull-to-refresh example
// ============================================================

class _RefreshExample extends StatefulWidget {
  const _RefreshExample();

  @override
  State<_RefreshExample> createState() => _RefreshExampleState();
}

class _RefreshExampleState extends State<_RefreshExample> {
  late Future<List<_Post>> _postsFuture;
  int _refreshCount = 0;

  @override
  void initState() {
    super.initState();
    _postsFuture = _loadPosts();
  }

  Future<List<_Post>> _loadPosts() async {
    await Future.delayed(const Duration(seconds: 1));
    _refreshCount++;
    return [
      _Post('Update #$_refreshCount', 'Refreshed at ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}'),
      _Post('Post 2', 'Second item after refresh'),
      _Post('Post 3', 'Third item after refresh'),
    ];
  }

  Future<void> _onRefresh() async {
    setState(() {
      _postsFuture = _loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text('Pull down to refresh',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: FutureBuilder<List<_Post>>(
            future: _postsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final posts = snapshot.data ?? [];
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (_, i) => ListTile(
                    leading: const Icon(Icons.article),
                    title: Text(posts[i].title),
                    subtitle: Text(posts[i].body),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Data models
// ============================================================

class _User {
  final String name;
  final String email;
  final IconData icon;
  const _User(this.name, this.email, this.icon);
}

class _Post {
  final String title;
  final String body;
  const _Post(this.title, this.body);
}
