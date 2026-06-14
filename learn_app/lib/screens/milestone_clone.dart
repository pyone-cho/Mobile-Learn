import 'package:flutter/material.dart';

/// Phase 2 Milestone: UI Clone
/// A pixel-perfect social media profile screen (Instagram-style).
///
/// Key concepts demonstrated:
/// - Stack for overlapping avatar + cover
/// - Row/Column layouts with spacing
/// - GridView for photo grid
/// - Custom app bar with actions
/// - Icons, Text styling, and theme colors

class MilestoneClone extends StatelessWidget {
  const MilestoneClone({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom gradient AppBar
      appBar: AppBar(
        title: const Row(
          children: [
            Text('alice_designs', style: TextStyle(fontWeight: FontWeight.bold)),
            Icon(Icons.arrow_drop_down),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add_box_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            _ProfileHeader(),
            _ProfileStats(),
            _BioSection(),
            _ActionButtons(),
            _StoryHighlights(),
            _PhotoGrid(),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar with ring
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.pink.shade300, width: 3),
            ),
            child: const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.teal,
              child: Text('A',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 24),
          // Name + handle
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alice Johnson',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 2),
              Text('@alice_designs',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.verified, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Text('UI/UX Designer',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(count: '142', label: 'Posts'),
          _StatItem(count: '8.5K', label: 'Followers'),
          _StatItem(count: '423', label: 'Following'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _BioSection extends StatelessWidget {
  const _BioSection();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🎨 Digital designer & illustrator',
              style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text(
            'Building beautiful things for the web and mobile. '
            'Flutter enthusiast. Coffee addict ☕',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 4),
          Text('🔗 alice.designs.io',
              style: TextStyle(
                  color: Colors.blue, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: () {},
              child: const Text('Follow'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('Message'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryHighlights extends StatelessWidget {
  const _StoryHighlights();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 6,
        itemBuilder: (context, index) {
          const highlights = ['Design', 'Travel', 'Food', 'Code', 'Art', 'Music'];
          const icons = [
            Icons.palette,
            Icons.flight,
            Icons.restaurant,
            Icons.code,
            Icons.brush,
            Icons.music_note,
          ];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400, width: 1.5),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.teal.withValues(alpha: 0.1),
                    child: Icon(icons[index], color: Colors.teal, size: 24),
                  ),
                ),
                const SizedBox(height: 4),
                Text(highlights[index],
                    style: const TextStyle(fontSize: 11)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid();

  // Simulated post data
  static const _posts = [
    _Post(Icons.landscape, Color(0xFF5C6BC0)),
    _Post(Icons.forest, Color(0xFF26A69A)),
    _Post(Icons.wb_sunny, Color(0xFFFFCA28)),
    _Post(Icons.terrain, Color(0xFF8D6E63)),
    _Post(Icons.water_drop, Color(0xFF42A5F5)),
    _Post(Icons.local_fire_department, Color(0xFFEF5350)),
    _Post(Icons.nightlight, Color(0xFF5C6BC0)),
    _Post(Icons.beach_access, Color(0xFFFFCC80)),
    _Post(Icons.photo_camera, Color(0xFF78909C)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return Container(
            color: post.color.withValues(alpha: 0.7),
            child: Center(
              child: Icon(post.icon, color: Colors.white, size: 36),
            ),
          );
        },
      ),
    );
  }
}

class _Post {
  final IconData icon;
  final Color color;
  const _Post(this.icon, this.color);
}
