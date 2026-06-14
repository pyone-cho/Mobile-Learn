/// Phase 3: State Management — MVVM Pattern
///
/// MVVM (Model-View-ViewModel) separates your app into 3 layers:
///
///   Model →  Data & business rules (what your app IS)
///   ViewModel →  State & logic (how your app BEHAVES)
///   View →  UI only, no logic (how your app LOOKS)
///
/// This keeps code testable and maintainable as your app grows.

import 'package:flutter/material.dart';

// ============================================================
// MODEL — Pure data, no Flutter imports needed
// ============================================================

class _Task {
  final String id;
  String title;
  bool isDone;
  _Task({required this.id, required this.title, required this.isDone});
}

// ============================================================
// VIEW MODEL — Holds state, exposes methods, extends ChangeNotifier
// ============================================================

class _TaskViewModel extends ChangeNotifier {
  final List<_Task> _tasks = [];

  // Read-only view of data
  List<_Task> get tasks => List.unmodifiable(_tasks);
  int get pendingCount => _tasks.where((t) => !t.isDone).length;
  int get doneCount => _tasks.where((t) => t.isDone).length;

  // --- Actions ---
  void addTask(String title) {
    _tasks.add(_Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      isDone: false,
    ));
    notifyListeners();
  }

  void toggleTask(String id) {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.isDone = !task.isDone;
    notifyListeners();
  }

  void removeTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void editTask(String id, String newTitle) {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.title = newTitle;
    notifyListeners();
  }
}

// ============================================================
// VIEW — Pure UI. No business logic, just `viewModel.method()` calls.
// ============================================================

class MvvmLesson extends StatefulWidget {
  const MvvmLesson({super.key});

  @override
  State<MvvmLesson> createState() => _MvvmLessonState();
}

class _MvvmLessonState extends State<MvvmLesson> {
  // The ViewModel lives as long as this screen
  final _viewModel = _TaskViewModel();
  final _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _addTask() {
    final title = _textCtrl.text.trim();
    if (title.isEmpty) return;
    _viewModel.addTask(title);
    _textCtrl.clear();
  }

  void _editTask(String id, String currentTitle) {
    final ctrl = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit task'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Task title',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              _viewModel.editTask(id, ctrl.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MVVM — Task Manager')),
      body: Column(
        children: [
          // Input area
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Add a task...',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _addTask, child: const Text('Add')),
              ],
            ),
          ),

          // Stats bar
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  _StatChip(
                    label: 'Pending',
                    count: _viewModel.pendingCount,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: 'Done',
                    count: _viewModel.doneCount,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: 'Total',
                    count: _viewModel.tasks.length,
                    color: Colors.teal,
                  ),
                ],
              ),
            ),
          ),

          // Task list
          Expanded(
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                if (_viewModel.tasks.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.task_alt, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No tasks yet. Add one above!',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: _viewModel.tasks.length,
                  itemBuilder: (context, index) {
                    final task = _viewModel.tasks[index];
                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isDone,
                          onChanged: (_) => _viewModel.toggleTask(task.id),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isDone ? Colors.grey : null,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () =>
                                  _editTask(task.id, task.title),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              color: Colors.red,
                              onPressed: () =>
                                  _viewModel.removeTask(task.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        radius: 10,
        child: Text('$count',
            style:
                const TextStyle(color: Colors.white, fontSize: 11)),
      ),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }
}
