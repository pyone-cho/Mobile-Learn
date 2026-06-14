import 'package:flutter/material.dart';

class LayoutLesson extends StatelessWidget {
  const LayoutLesson({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Layout Basics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ROW ---
            const Text('Row (horizontal layout)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey.withValues(alpha: 0.1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BlueBox(label: '1'),
                  BlueBox(label: '2'),
                  BlueBox(label: '3'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- COLUMN ---
            const Text('Column (vertical layout)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey.withValues(alpha: 0.1),
              child: const Column(
                children: [
                  OrangeBox(label: 'Top'),
                  OrangeBox(label: 'Middle'),
                  OrangeBox(label: 'Bottom'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- STACK ---
            const Text('Stack (overlapping layers)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: Stack(
                children: [
                  Container(
                    width: 200,
                    height: 100,
                    color: Colors.blue.withValues(alpha: 0.3),
                  ),
                  Positioned(
                    left: 20,
                    top: 20,
                    child: Container(
                      width: 100,
                      height: 60,
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  const Positioned(
                    right: 10,
                    bottom: 10,
                    child: Text('Overlay!',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- CONTAINER with decoration ---
            const Text('Container (styled box)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal, width: 2),
              ),
              child: const Text('I am a Container!',
                  style: TextStyle(fontSize: 16, color: Colors.teal)),
            ),

            const SizedBox(height: 24),

            // --- Expanded & Flex ---
            const Text('Expanded (flex sizing)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              height: 60,
              color: Colors.grey.withValues(alpha: 0.1),
              child: const Row(
                children: [
                  Expanded(flex: 2, child: BlueBox(label: '2x')),
                  Expanded(flex: 1, child: OrangeBox(label: '1x')),
                  Expanded(flex: 1, child: OrangeBox(label: '1x')),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- WRAP ---
            const Text('Wrap (auto-wrapping)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: List.generate(
                12,
                (i) => Chip(
                  label: Text('Tag $i'),
                  backgroundColor: Colors.teal.withValues(alpha: 0.2),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // --- TIP ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '💡 In Flutter, EVERYTHING is a Widget. '
                      'Row, Column, Stack, Container — these layout widgets '
                      'are the building blocks of every screen.',
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

class BlueBox extends StatelessWidget {
  final String label;
  const BlueBox({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.blue,
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}

class OrangeBox extends StatelessWidget {
  final String label;
  const OrangeBox({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.deepOrange,
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
