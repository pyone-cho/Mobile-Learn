/// Phase 4: JSON Serialization — fromJson / toJson patterns
///
/// Three approaches: manual, helper mixin, and codegen-ready pattern.

import 'dart:convert';
import 'package:flutter/material.dart';

class JsonLesson extends StatelessWidget {
  const JsonLesson({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JSON Serialization')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ApproachCard(
              title: 'Approach 1: Manual fromJson',
              code: '''
class User {
  final int id;
  final String name;
  final String? email;

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j['id'] as int? ?? 0,
    name: j['name'] as String? ?? '',
    email: j['email'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email,
  };
}''',
              note: 'Simple, no deps. Write once per model.',
            ),

            SizedBox(height: 16),

            _ApproachCard(
              title: 'Approach 2: Nested objects',
              code: '''
class Company {
  final String name;
  final Address address;

  factory Company.fromJson(Map<String, dynamic> j) => Company(
    name: j['name'] ?? '',
    address: Address.fromJson(j['address']),
  );
}

class Address {
  final String street;
  final String city;

  factory Address.fromJson(Map<String, dynamic> j) => Address(
    street: j['street'] ?? '',
    city: j['city'] ?? '',
  );
}''',
              note: 'Nested JSON → nested models. Common in real APIs.',
            ),

            SizedBox(height: 16),

            _ApproachCard(
              title: 'Approach 3: JSON string directly',
              code: '''
// Parse JSON string → model
final jsonStr = '{"id":1,"name":"Alice"}';
final user = User.fromJson(jsonDecode(jsonStr));

// Model → JSON string
final back = jsonEncode(user.toJson());''',
              note: 'Use dart:convert for raw JSON strings.',
            ),

            SizedBox(height: 16),

            _LiveExample(),
          ],
        ),
      ),
    );
  }
}

class _ApproachCard extends StatelessWidget {
  final String title;
  final String code;
  final String note;

  const _ApproachCard({
    required this.title,
    required this.code,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                code.trim(),
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(note, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Live example — parse real JSON and display
// ============================================================

class _LiveExample extends StatefulWidget {
  const _LiveExample();

  @override
  State<_LiveExample> createState() => _LiveExampleState();
}

class _LiveExampleState extends State<_LiveExample> {
  final _ctrl = TextEditingController();
  String _result = '';

  // Sample JSONs to try
  static const _samples = [
    '{"userId": 1, "id": 1, "title": "Sample post", "body": "Post body text here"}',
    '{"name": "Alice", "age": 30, "isActive": true, "skills": ["Flutter", "Dart", "Firebase"]}',
    '{"error": "not_found", "message": "Resource does not exist"}',
  ];

  int _sampleIndex = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _parse() {
    final input = _ctrl.text.trim();
    if (input.isEmpty) {
      setState(() => _result = 'Enter JSON to parse');
      return;
    }

    try {
      final parsed = jsonDecode(input);
      setState(() {
        _result = '✅ Valid JSON\n\n'
            'Type: ${parsed.runtimeType}\n'
            'Keys: ${parsed is Map ? parsed.keys.join(", ") : "N/A (not a Map)"}\n\n'
            'Formatted:\n${const JsonEncoder.withIndent("  ").convert(parsed)}';
      });
    } catch (e) {
      setState(() => _result = '❌ Invalid JSON\n$e');
    }
  }

  void _loadSample() {
    _ctrl.text = _samples[_sampleIndex % _samples.length];
    _sampleIndex++;
    _parse();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🧪 Live JSON Parser',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Paste JSON here...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _parse,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Parse'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _loadSample,
                  icon: const Icon(Icons.science, size: 18),
                  label: const Text('Load Sample'),
                ),
              ],
            ),
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _result,
                  style: const TextStyle(
                      fontSize: 12, fontFamily: 'monospace', height: 1.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
