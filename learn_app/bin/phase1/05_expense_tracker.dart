/// Phase 1 Milestone: CLI Expense Tracker
///
/// Run: dart run bin/phase1/05_expense_tracker.dart
///
/// Ties together: nullable types, async/await, streams, collections, classes, enums.

import 'dart:async';
import 'dart:io';

void main() async {
  print('══════════════════════════════════════════');
  print('  💰 CLI EXPENSE TRACKER');
  print('══════════════════════════════════════════');
  print('  Commands: add, list, total, budget, summary, exit\n');

  final tracker = ExpenseTracker();
  await tracker.run();
}

// --- Enums ---
enum Category {
  food('🍔 Food'),
  transport('🚗 Transport'),
  housing('🏠 Housing'),
  entertainment('🎬 Entertainment'),
  utilities('💡 Utilities'),
  other('📦 Other');

  final String label;
  const Category(this.label);
}

// --- Models ---
class Expense {
  final String id;
  final String description;
  final double amount;
  final Category category;
  final DateTime date;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  @override
  String toString() =>
      '${date.toString().split(' ')[0]} | \$${amount.toStringAsFixed(2)} | ${category.label.padRight(16)} | $description';
}

// --- The Tracker ---
class ExpenseTracker {
  final List<Expense> _expenses = [];
  double _monthlyBudget = 1000.0;

  Future<void> run() async {
    // Interactive loop
    while (true) {
      stdout.write('\n> ');
      final input = (stdin.readLineSync() ?? '').trim().toLowerCase();

      if (input == 'exit') {
        print('👋 Goodbye!');
        break;
      }

      await _handleCommand(input);
    }
  }

  Future<void> _handleCommand(String input) async {
    final parts = input.split(' ');
    final command = parts[0];

    switch (command) {
      case 'add':
        await _addExpense();
      case 'list':
        _listExpenses();
      case 'total':
        _showTotal();
      case 'budget':
        _setBudget(parts);
      case 'summary':
        _showSummary();
      case '':
        break; // empty input
      default:
        print('❌ Unknown command. Try: add, list, total, budget, summary, exit');
    }
  }

  Future<void> _addExpense() async {
    try {
      // Description
      stdout.write('  Description: ');
      final description = (stdin.readLineSync() ?? '').trim();
      if (description.isEmpty) {
        print('❌ Description required');
        return;
      }

      // Amount
      stdout.write('  Amount: \$');
      final amountInput = stdin.readLineSync() ?? '';
      final amount = double.tryParse(amountInput);
      if (amount == null || amount <= 0) {
        print('❌ Invalid amount');
        return;
      }

      // Category
      print('  Categories:');
      for (var cat in Category.values) {
        print('    ${cat.index + 1}. ${cat.label}');
      }
      stdout.write('  Pick category (1-${Category.values.length}): ');
      final catInput = stdin.readLineSync() ?? '';
      final catIndex = int.tryParse(catInput);
      if (catIndex == null || catIndex < 1 || catIndex > Category.values.length) {
        print('❌ Invalid category');
        return;
      }
      final category = Category.values[catIndex - 1];

      // Create expense
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: description,
        amount: amount,
        category: category,
      );

      _expenses.add(expense);
      print('✅ Added: \$${amount.toStringAsFixed(2)} for $description');

      // Budget check
      if (_monthlyTotal() > _monthlyBudget) {
        print('⚠️  You\'ve exceeded your monthly budget of \$${_monthlyBudget.toStringAsFixed(2)}!');
      } else if (_monthlyTotal() > _monthlyBudget * 0.8) {
        print('⚠️  You\'ve used ${(_monthlyTotal() / _monthlyBudget * 100).toStringAsFixed(0)}% of your budget');
      }
    } catch (e) {
      print('❌ Error adding expense: $e');
    }
  }

  void _listExpenses() {
    if (_expenses.isEmpty) {
      print('📭 No expenses yet');
      return;
    }

    print('\n  ── All Expenses ──');
    // Sort by date descending (newest first)
    final sorted = [..._expenses]
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final e in sorted) {
      print('  ${e.toString()}');
    }
    print('  ──────────────────');
    print('  Total: \$${_allTotal().toStringAsFixed(2)}');
  }

  void _showTotal() {
    final total = _allTotal();
    final monthly = _monthlyTotal();
    print('  📊 All time: \$${total.toStringAsFixed(2)}');
    print('  📊 This month: \$${monthly.toStringAsFixed(2)}');
    print('  📊 Budget: \$${_monthlyBudget.toStringAsFixed(2)}');
    print('  📊 Remaining: \$${(_monthlyBudget - monthly).toStringAsFixed(2)}');
  }

  void _setBudget(List<String> parts) {
    if (parts.length < 2) {
      print('  Current budget: \$${_monthlyBudget.toStringAsFixed(2)}');
      print('  Usage: budget <amount>');
      return;
    }
    final amount = double.tryParse(parts[1]);
    if (amount == null || amount <= 0) {
      print('❌ Invalid budget amount');
      return;
    }
    _monthlyBudget = amount;
    print('✅ Budget set to \$${amount.toStringAsFixed(2)}/month');
  }

  void _showSummary() {
    if (_expenses.isEmpty) {
      print('📭 No expenses to summarize');
      return;
    }

    // Group by category
    final byCategory = <Category, List<Expense>>{};
    for (final e in _expenses) {
      byCategory.putIfAbsent(e.category, () => []);
      byCategory[e.category]!.add(e);
    }

    // Sort by total descending
    final sorted = byCategory.entries.toList()
      ..sort((a, b) {
        final sumA = a.value.fold(0.0, (s, e) => s + e.amount);
        final sumB = b.value.fold(0.0, (s, e) => s + e.amount);
        return sumB.compareTo(sumA);
      });

    print('\n  ── Spending by Category ──');
    for (final entry in sorted) {
      final total = entry.value.fold(0.0, (s, e) => s + e.amount);
      final count = entry.value.length;
      final pct = (_allTotal() > 0)
          ? (total / _allTotal() * 100).toStringAsFixed(1)
          : '0.0';
      print('  ${entry.key.label.padRight(18)} \$${total.toStringAsFixed(5).padLeft(8)}  ${pct}%  ($count entries)');
    }
    print('  ─────────────────────────');
  }

  double _allTotal() =>
      _expenses.fold(0.0, (sum, e) => sum + e.amount);

  double _monthlyTotal() {
    final now = DateTime.now();
    return _expenses
        .where((e) =>
            e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }
}
