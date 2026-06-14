/// Phase 4: Offline Caching — shared_preferences & local storage
///
/// Cache API responses locally so your app works offline.
/// The cached data is shown immediately; fresh data replaces it when online.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CacheLesson extends StatefulWidget {
  const CacheLesson({super.key});

  @override
  State<CacheLesson> createState() => _CacheLessonState();
}

class _CacheLessonState extends State<CacheLesson> {
  List<_CachedPost>? _posts;
  String? _error;
  bool _loading = false;
  bool _isFromCache = false;

  @override
  void initState() {
    super.initState();
    _loadFromCache(); // Show cached immediately
    _fetchPosts();    // Then fetch fresh
  }

  // --- Load from local cache ---
  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_posts');
    if (cached != null) {
      final List<dynamic> data = jsonDecode(cached);
      setState(() {
        _posts = data.map((j) => _CachedPost.fromJson(j)).toList();
        _isFromCache = true;
      });
    }
  }

  // --- Fetch from network + cache ---
  Future<void> _fetchPosts() async {
    setState(() {
      _loading = _posts == null; // Only show loading if no cached data
      _error = null;
    });

    try {
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=8'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final List<dynamic> data = jsonDecode(response.body);
      final posts = data.map((j) => _CachedPost.fromJson(j)).toList();

      // Cache to disk
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_posts', response.body);
      await prefs.setString('last_fetch', DateTime.now().toIso8601String());

      setState(() {
        _posts = posts;
        _isFromCache = false;
        _loading = false;
      });
    } catch (e) {
      if (_posts == null) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      } else {
        // Already showing cached data — silently fail
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Showing cached data (offline)')),
          );
        }
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_posts');
    await prefs.remove('last_fetch');
    setState(() {
      _posts = null;
      _isFromCache = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Caching'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearCache,
            tooltip: 'Clear cache',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPosts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Cache status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: _isFromCache
                ? Colors.orange.withValues(alpha: 0.15)
                : Colors.green.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(
                  _isFromCache ? Icons.storage : Icons.cloud_done,
                  size: 18,
                  color: _isFromCache ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  _isFromCache ? '📦 Showing Cached Data' : '☁️ Live Data',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _isFromCache ? Colors.orange.shade800 : Colors.green.shade800,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                if (_posts != null)
                  Text(
                    '${_posts!.length} posts',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text('Error: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _fetchPosts,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_posts == null || _posts!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('No data. Pull to refresh.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchPosts,
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: _posts!.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final post = _posts![index];
          return ListTile(
            leading: CircleAvatar(
              child: Text('${post.id}'),
            ),
            title: Text(post.title,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(post.body,
                maxLines: 2, overflow: TextOverflow.ellipsis),
          );
        },
      ),
    );
  }
}

class _CachedPost {
  final int id;
  final String title;
  final String body;

  _CachedPost({required this.id, required this.title, required this.body});

  factory _CachedPost.fromJson(Map<String, dynamic> j) {
    return _CachedPost(
      id: j['id'] as int? ?? 0,
      title: j['title'] as String? ?? '',
      body: j['body'] as String? ?? '',
    );
  }
}
