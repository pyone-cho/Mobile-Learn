/// Phase 3 Milestone: Todo List App
///
/// Combines: setState, Provider, MVVM, FutureBuilder, and all Phase 2 UI skills.
///
/// Features:
/// - Add/delete/edit tasks with categories
/// - Filter by All/Pending/Done
/// - Search tasks
/// - Stats dashboard
/// - Pull-to-refresh (simulated)
/// - Empty states

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ============================================================
// MODEL
// ============================================================

enum TaskCategory {
  personal('Personal', Icons.person, Colors.blue),
  work('Work', Icons.work, Colors.purple),
  shopping('Shopping', Icons.shopping_cart, Colors.teal),
  health('Health', Icons.favorite, Colors.red),
  other('Other', Icons.more_horiz, Colors.grey);

  final String label;
  final IconData icon;
  final Color color;
  const TaskCategory(this.label, this.icon, this.color);
}

class TodoTask {
  final String id;
  String title;
  String? note;
  TaskCategory category;
  bool isDone;
  final DateTime createdAt;

  TodoTask({
    required this.id,
    required this.title,
    this.note,
    this.category = TaskCategory.other,
    this.isDone = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

// ============================================================
// VIEW MODEL
// ============================================================

enum _Filter { all, pending, done }

class TodoViewModel extends ChangeNotifier {
  final List<TodoTask> _tasks = [];

  // Seed data
  TodoViewModel() {
    _tasks.addAll([
      TodoTask(
        id: '1',
        title: 'Learn Flutter layouts',
        note: 'Row, Column, Stack',
        category: TaskCategory.personal,
      ),
      TodoTask(
        id: '2',
        title: 'Review PR',
        note: 'Check the auth module',
        category: TaskCategory.work,
        isDone: true,
      ),
      TodoTask(
        id: '3',
        title: 'Buy groceries',
        note: 'Milk, eggs, bread',
        category: TaskCategory.shopping,
      ),
      TodoTask(
        id: '4',
        title: 'Morning run',
        category: TaskCategory.health,
        isDone: true,
      ),
      TodoTask(
        id: '5',
        title: 'Write docs',
        note: 'API reference for v2',
        category: TaskCategory.work,
      ),
    ]);
  }

  _Filter _currentFilter = _Filter.all;
  String _searchQuery = '';

  // --- Computed properties ---
  List<TodoTask> get filteredTasks {
    var tasks = _tasks.where((t) {
      // Filter by status
      if (_currentFilter == _Filter.pending && t.isDone) return false;
      if (_currentFilter == _Filter.done && !t.isDone) return false;
      // Filter by search
      if (_searchQuery.isNotEmpty &&
          !t.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
    // Sort: pending first, then by date
    tasks.sort((a, b) {
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return tasks;
  }

  int get totalCount => _tasks.length;
  int get pendingCount => _tasks.where((t) => !t.isDone).length;
  int get doneCount => _tasks.where((t) => t.isDone).length;
  double get completionPct =>
      totalCount > 0 ? doneCount / totalCount : 0.0;

  // --- Actions ---
  void setFilter(_Filter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addTask(String title, {String? note, TaskCategory? category}) {
    _tasks.add(TodoTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      note: note,
      category: category ?? TaskCategory.other,
    ));
    notifyListeners();
  }

  void toggleTask(String id) {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.isDone = !task.isDone;
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void editTask(String id, String title, String? note, TaskCategory category) {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.title = title;
    task.note = note?.isEmpty == true ? null : note;
    task.category = category;
    notifyListeners();
  }
}

// ============================================================
// VIEW — Todo Screen
// ============================================================

class TodoMilestone extends StatelessWidget {
  const TodoMilestone({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoViewModel(),
      child: const _TodoApp(),
    );
  }
}

class _TodoApp extends StatelessWidget {
  const _TodoApp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⭐ Todo App'),
        centerTitle: true,
      ),
      body: const Column(
        children: [
          _StatsHeader(),
          _FilterBar(),
          _SearchBar(),
          Expanded(child: _TaskList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  static void _showAddDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final noteCtrl = TextEditingController();
    var category = TaskCategory.personal;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Task title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskCategory>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: TaskCategory.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Row(
                            children: [
                              Icon(c.icon, size: 18, color: c.color),
                              SizedBox(width: 8),
                              Text(c.label),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setDialogState(() => category = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (ctrl.text.trim().isEmpty) return;
                context.read<TodoViewModel>().addTask(
                      ctrl.text.trim(),
                      note: noteCtrl.text.trim(),
                      category: category,
                    );
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// STATS HEADER
// ============================================================

class _StatsHeader extends StatelessWidget {
  const _StatsHeader();

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoViewModel>(
      builder: (context, vm, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        child: Row(
          children: [
            _StatBox('Total', '${vm.totalCount}', Colors.teal),
            _StatBox('Pending', '${vm.pendingCount}', Colors.orange),
            _StatBox('Done', '${vm.doneCount}', Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(vm.completionPct * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: vm.completionPct,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
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

class _StatBox extends StatelessWidget {
  final String label;
  final String count;
  final Color color;
  const _StatBox(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Text(count,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

// ============================================================
// FILTER BAR
// ============================================================

class _FilterBar extends StatelessWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoViewModel>(
      builder: (context, vm, _) {
        final filters = _Filter.values;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: filters
                .map((f) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: FilterChip(
                          label: Center(
                              child: Text(f.name.toUpperCase(),
                                  style: const TextStyle(fontSize: 12))),
                          selected: vm._currentFilter == f,
                          onSelected: (_) => vm.setFilter(f),
                        ),
                      ),
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}

// ============================================================
// SEARCH BAR
// ============================================================

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 8),
          isDense: true,
        ),
        onChanged: (q) => context.read<TodoViewModel>().setSearch(q),
      ),
    );
  }
}

// ============================================================
// TASK LIST
// ============================================================

class _TaskList extends StatelessWidget {
  const _TaskList();

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoViewModel>(
      builder: (context, vm, _) {
        final tasks = vm.filteredTasks;

        if (tasks.isEmpty && vm.totalCount == 0) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.task_alt, size: 56, color: Colors.grey),
                SizedBox(height: 12),
                Text('No tasks yet!',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Tap + to add one',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        if (tasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('No matching tasks',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => Future.delayed(const Duration(milliseconds: 500)),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                child: Dismissible(
                  key: ValueKey(task.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => vm.deleteTask(task.id),
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (_) => vm.toggleTask(task.id),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isDone ? Colors.grey : null,
                        fontWeight:
                            task.isDone ? FontWeight.normal : FontWeight.w500,
                      ),
                    ),
                    subtitle: task.note != null
                        ? Text(task.note!,
                            maxLines: 1, overflow: TextOverflow.ellipsis)
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(task.category.icon,
                            size: 18, color: task.category.color),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'edit') {
                              _showEditDialog(context, task);
                            } else if (action == 'delete') {
                              vm.deleteTask(task.id);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                                value: 'edit',
                                child: Row(children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit')
                                ])),
                            const PopupMenuItem(
                                value: 'delete',
                                child: Row(children: [
                                  Icon(Icons.delete, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete')
                                ])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  static void _showEditDialog(BuildContext context, TodoTask task) {
    final ctrl = TextEditingController(text: task.title);
    final noteCtrl = TextEditingController(text: task.note ?? '');
    var category = task.category;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskCategory>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: TaskCategory.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Row(children: [
                            Icon(c.icon, size: 18, color: c.color),
                            SizedBox(width: 8),
                            Text(c.label),
                          ]),
                        ))
                    .toList(),
                onChanged: (v) => setDialogState(() => category = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (ctrl.text.trim().isEmpty) return;
                context
                    .read<TodoViewModel>()
                    .editTask(task.id, ctrl.text.trim(),
                        noteCtrl.text.trim(), category);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
