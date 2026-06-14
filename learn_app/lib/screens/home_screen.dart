import 'package:flutter/material.dart';
import 'layout_lesson.dart';
import 'listview_lesson.dart';
import 'styling_lesson.dart';
import 'form_lesson.dart';
import 'navigation_lesson.dart';
import 'tabs_lesson.dart';
import 'milestone_clone.dart';
import 'phase3/setstate_lesson.dart';
import 'phase3/provider_lesson.dart';
import 'phase3/mvvm_lesson.dart';
import 'phase3/futurebuilder_lesson.dart';
import 'phase3/todo_milestone.dart';
import 'phase4/http_basics.dart';
import 'phase4/json_lesson.dart';
import 'phase4/error_handling.dart';
import 'phase4/cache_lesson.dart';
import 'phase4/weather_milestone.dart';
import 'phase5/debugging_lesson.dart';
import 'phase5/native_features_lesson.dart';
import 'phase5/deployment_lesson.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Phase 5 cards
  static const _phase5Lessons = [
    _LessonCard(
      icon: Icons.bug_report,
      title: 'Debugging & Profiling',
      subtitle: 'Logging, rebuilds, perf, errors, DevTools',
      color: Colors.teal,
      route: 'debugging',
    ),
    _LessonCard(
      icon: Icons.phone_android,
      title: 'Native Features',
      subtitle: 'GPS, camera, biometrics, haptics, platform channels',
      color: Colors.indigo,
      route: 'native',
    ),
    _LessonCard(
      icon: Icons.store,
      title: 'App Store Deployment',
      subtitle: 'Build types, signing, store prep, CI/CD, versioning',
      color: Colors.deepOrange,
      route: 'deploy',
    ),
  ];

  // Phase 2 cards
  static const _phase2Lessons = [
    _LessonCard(
      icon: Icons.view_quilt,
      title: 'Layout Basics',
      subtitle: 'Row, Column, Stack, Container',
      color: Colors.teal,
      route: 'layout',
    ),
    _LessonCard(
      icon: Icons.list,
      title: 'Lists & Scrolling',
      subtitle: 'ListView, GridView, scrolling',
      color: Colors.indigo,
      route: 'listview',
    ),
    _LessonCard(
      icon: Icons.palette,
      title: 'Styling & Themes',
      subtitle: 'Text, Image, Icon, colors',
      color: Colors.deepOrange,
      route: 'styling',
    ),
    _LessonCard(
      icon: Icons.input,
      title: 'Forms & Input',
      subtitle: 'TextField, Form, validation',
      color: Colors.purple,
      route: 'form',
    ),
    _LessonCard(
      icon: Icons.navigation,
      title: 'Navigation',
      subtitle: 'push/pop, named routes, data passing',
      color: Colors.blue,
      route: 'navigation',
    ),
    _LessonCard(
      icon: Icons.tab,
      title: 'Tabs & Bottom Nav',
      subtitle: 'TabBar, BottomNavigationBar',
      color: Colors.pink,
      route: 'tabs',
    ),
    _LessonCard(
      icon: Icons.emoji_events,
      title: '⭐ UI Clone Milestone',
      subtitle: 'Pixel-perfect profile screen',
      color: Colors.amber,
      route: 'milestone',
    ),
  ];

  // Phase 4 cards
  static const _phase4Lessons = [
    _LessonCard(
      icon: Icons.cloud,
      title: 'HTTP Basics',
      subtitle: 'GET, POST, JSONPlaceholder, Random User',
      color: Colors.teal,
      route: 'http',
    ),
    _LessonCard(
      icon: Icons.data_object,
      title: 'JSON Serialization',
      subtitle: 'fromJson, toJson, manual & codegen patterns',
      color: Colors.indigo,
      route: 'json',
    ),
    _LessonCard(
      icon: Icons.error_outline,
      title: 'Error Handling',
      subtitle: 'Timeouts, retries, connectivity, offline',
      color: Colors.deepOrange,
      route: 'errors',
    ),
    _LessonCard(
      icon: Icons.cached,
      title: 'Offline Caching',
      subtitle: 'shared_preferences, cache-then-network',
      color: Colors.purple,
      route: 'cache',
    ),
    _LessonCard(
      icon: Icons.emoji_events,
      title: '⭐ Weather Milestone',
      subtitle: 'Live weather, search, 7-day forecast, offline',
      color: Colors.amber,
      route: 'weather',
    ),
  ];

  // Phase 3 cards
  static const _phase3Lessons = [
    _LessonCard(
      icon: Icons.toggle_on,
      title: 'setState Basics',
      subtitle: 'Local state, rebuilds, theme toggle',
      color: Colors.teal,
      route: 'setstate',
    ),
    _LessonCard(
      icon: Icons.share,
      title: 'Provider Pattern',
      subtitle: 'Shared cart, ChangeNotifier, Consumer',
      color: Colors.indigo,
      route: 'provider',
    ),
    _LessonCard(
      icon: Icons.account_tree,
      title: 'MVVM Architecture',
      subtitle: 'Model-View-ViewModel separation',
      color: Colors.purple,
      route: 'mvvm',
    ),
    _LessonCard(
      icon: Icons.hourglass_bottom,
      title: 'Loading States',
      subtitle: 'FutureBuilder, errors, empty, refresh',
      color: Colors.deepOrange,
      route: 'futurebuilder',
    ),
    _LessonCard(
      icon: Icons.emoji_events,
      title: '⭐ Todo App Milestone',
      subtitle: 'Full CRUD, categories, search, filters',
      color: Colors.amber,
      route: 'todo',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter UI Lab'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Phase 2 header
          _PhaseHeader(
            title: 'Phase 2: Building Interfaces',
            subtitle: 'Layouts, navigation, forms, styling',
            icon: Icons.palette_outlined,
          ),
          ..._phase2Lessons.map((lesson) => _buildCard(context, lesson, false)),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Phase 3 header
          _PhaseHeader(
            title: 'Phase 3: State Management',
            subtitle: 'setState, Provider, MVVM, async states',
            icon: Icons.memory,
          ),
          ..._phase3Lessons.map((lesson) => _buildCard(context, lesson, true)),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Phase 4 header
          _PhaseHeader(
            title: 'Phase 4: Networking & APIs',
            subtitle: 'HTTP, JSON, error handling, caching, weather app',
            icon: Icons.cloud_outlined,
          ),
          ..._phase4Lessons.map((lesson) => _buildCard(context, lesson, true)),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Phase 5 header
          _PhaseHeader(
            title: 'Phase 5: Polish & Ship',
            subtitle: 'Debugging, profiling, native features, deployment',
            icon: Icons.rocket_outlined,
          ),
          ..._phase5Lessons.map((lesson) => _buildCard(context, lesson, true)),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, _LessonCard lesson, bool highlightMilestones) {
    final isMilestone = lesson.title.contains('Milestone');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isMilestone ? 3 : 1,
      color: isMilestone
          ? Theme.of(context).colorScheme.tertiaryContainer
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: lesson.color.withValues(alpha: 0.2),
          child: Icon(lesson.icon, color: lesson.color),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(lesson.subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _navigateTo(context, lesson.route),
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    final routes = <String, Widget>{
      'layout': const LayoutLesson(),
      'listview': const ListviewLesson(),
      'styling': const StylingLesson(),
      'form': const FormLesson(),
      'navigation': const NavigationLesson(),
      'tabs': const TabsLesson(),
      'milestone': const MilestoneClone(),
      'setstate': const SetstateLesson(),
      'provider': const ProviderLesson(),
      'mvvm': const MvvmLesson(),
      'futurebuilder': const FuturebuilderLesson(),
      'todo': const TodoMilestone(),
      'http': const HttpBasicsLesson(),
      'json': const JsonLesson(),
      'errors': const ErrorHandlingLesson(),
      'cache': const CacheLesson(),
      'weather': const WeatherMilestone(),
      'debugging': const DebuggingLesson(),
      'native': const NativeFeaturesLesson(),
      'deploy': const DeploymentLesson(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => routes[route]!),
    );
  }
}

class _PhaseHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _PhaseHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;

  const _LessonCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
  });
}
