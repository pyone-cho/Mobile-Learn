/// Phase 4: Networking — HTTP Basics (GET, POST, async requests)
///
/// Uses free public APIs that require NO API keys.
/// APIs used: JSONPlaceholder, Random User, Dog API, Bored API.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HttpBasicsLesson extends StatelessWidget {
  const HttpBasicsLesson({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('HTTP Basics'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'GET'),
              Tab(text: 'POST'),
              Tab(text: 'Users'),
              Tab(text: 'Random'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _GetExample(),
            _PostExample(),
            _UsersExample(),
            _RandomExample(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TAB 1: Simple GET request
// ============================================================

class _GetExample extends StatefulWidget {
  const _GetExample();

  @override
  State<_GetExample> createState() => _GetExampleState();
}

class _GetExampleState extends State<_GetExample> {
  late Future<List<_Post>> _posts;
  final _client = http.Client();

  @override
  void initState() {
    super.initState();
    _posts = _fetchPosts();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<List<_Post>> _fetchPosts() async {
    // JSONPlaceholder — free fake API
    final response = await _client.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=10'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load posts (${response.statusCode})');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((j) => _Post.fromJson(j)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_Post>>(
      future: _posts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Fetching posts from jsonplaceholder...'),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Error: ${snapshot.error}',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => setState(() => _posts = _fetchPosts()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final posts = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async =>
              setState(() => _posts = _fetchPosts()),
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${post.id}')),
                title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
              );
            },
          ),
        );
      },
    );
  }
}

// ============================================================
// TAB 2: POST request
// ============================================================

class _PostExample extends StatefulWidget {
  const _PostExample();

  @override
  State<_PostExample> createState() => _PostExampleState();
}

class _PostExampleState extends State<_PostExample> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _client = http.Client();
  String _result = '';
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _client.close();
    super.dispose();
  }

  Future<void> _createPost() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _result = '';
    });

    try {
      final response = await _client.post(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': _titleCtrl.text,
          'body': _bodyCtrl.text,
          'userId': 1,
        }),
      );

      if (response.statusCode == 201) {
        setState(() => _result = '✅ Created! Response:\n${response.body}');
      } else {
        setState(
            () => _result = '❌ Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _result = '❌ Network error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('POST — Create a resource',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        const Text(
          'Sends data to the server. JSONPlaceholder echoes it back.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
              hintText: 'Enter post title'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bodyCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
              labelText: 'Body',
              border: OutlineInputBorder(),
              hintText: 'Enter post content'),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loading ? null : _createPost,
          icon: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.send),
          label: Text(_loading ? 'Sending...' : 'Send POST Request'),
        ),
        if (_result.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(_result,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
          ),
        ],
      ],
    );
  }
}

// ============================================================
// TAB 3: Random User API
// ============================================================

class _UsersExample extends StatefulWidget {
  const _UsersExample();

  @override
  State<_UsersExample> createState() => _UsersExampleState();
}

class _UsersExampleState extends State<_UsersExample> {
  late Future<List<_RandomUser>> _users;
  final _client = http.Client();

  @override
  void initState() {
    super.initState();
    _users = _fetchUsers();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<List<_RandomUser>> _fetchUsers() async {
    final response = await _client.get(
      Uri.parse('https://randomuser.me/api/?results=10&nat=us,gb,fr'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed (${response.statusCode})');
    }
    final data = jsonDecode(response.body);
    final List<dynamic> results = data['results'];
    return results.map((j) => _RandomUser.fromJson(j)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_RandomUser>>(
      future: _users,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Fetching random users...')
                  ]));
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                FilledButton.icon(
                  onPressed: () => setState(() => _users = _fetchUsers()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        final users = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async =>
              setState(() => _users = _fetchUsers()),
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final u = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(u.picture),
                ),
                title: Text('${u.first} ${u.last}'),
                subtitle: Text('${u.email} • ${u.country}'),
                trailing: Text(
                    '${u.age}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          ),
        );
      },
    );
  }
}

// ============================================================
// TAB 4: Random (Bored API) — get activity suggestions
// ============================================================

class _RandomExample extends StatefulWidget {
  const _RandomExample();

  @override
  State<_RandomExample> createState() => _RandomExampleState();
}

class _RandomExampleState extends State<_RandomExample> {
  final _client = http.Client();
  Map<String, dynamic>? _activity;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _fetchActivity() async {
    setState(() {
      _loading = true;
      _error = null;
      _activity = null;
    });

    try {
      final response = await _client.get(
        Uri.parse('https://bored-api.appbrewery.com/random'),
      );
      if (response.statusCode != 200) {
        throw Exception('Status: ${response.statusCode}');
      }
      setState(() => _activity = jsonDecode(response.body));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Bored API — random activity suggestion',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),

          FilledButton.icon(
            onPressed: _loading ? null : _fetchActivity,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.shuffle),
            label: Text(_loading ? 'Loading...' : 'Get Random Activity'),
          ),

          const SizedBox(height: 24),

          if (_activity != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.lightbulb, size: 48, color: Colors.amber.shade600),
                    const SizedBox(height: 12),
                    Text(
                      _activity!['activity'] ?? '',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _Tag(
                            Icons.category, '${_activity!['type']}'),
                        _Tag(Icons.people,
                            '${_activity!['participants']} participants'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _Tag(Icons.price_check,
                            '\$${_activity!['price']}'),
                        _Tag(Icons.accessibility,
                            'Difficulty: ${_activity!['accessibility']}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (_error != null)
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Tag(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ============================================================
// DATA MODELS
// ============================================================

class _Post {
  final int id;
  final String title;
  final String body;

  _Post({required this.id, required this.title, required this.body});

  factory _Post.fromJson(Map<String, dynamic> json) {
    return _Post(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }
}

class _RandomUser {
  final String first;
  final String last;
  final String email;
  final String country;
  final int age;
  final String picture;

  _RandomUser({
    required this.first,
    required this.last,
    required this.email,
    required this.country,
    required this.age,
    required this.picture,
  });

  factory _RandomUser.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final dob = json['dob'];
    final loc = json['location'];
    final pic = json['picture'];
    return _RandomUser(
      first: name?['first'] ?? '',
      last: name?['last'] ?? '',
      email: json['email'] ?? '',
      country: loc?['country'] ?? '',
      age: dob?['age'] ?? 0,
      picture: pic?['medium'] ?? '',
    );
  }
}
