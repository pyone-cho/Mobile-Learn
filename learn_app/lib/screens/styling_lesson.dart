import 'package:flutter/material.dart';

class StylingLesson extends StatelessWidget {
  const StylingLesson({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Styling & Themes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TEXT STYLING ---
            const Text('Text Styling',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Small body text', style: theme.textTheme.bodySmall),
            Text('Default body', style: theme.textTheme.bodyMedium),
            Text('Large body', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text('Title Small', style: theme.textTheme.titleSmall),
            Text('Title Medium', style: theme.textTheme.titleMedium),
            Text('Title Large', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Headline', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text('Custom: bold italic underline',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline,
                  color: Colors.teal,
                  fontSize: 16,
                )),

            const SizedBox(height: 24),

            // --- IMAGES ---
            const Text('Icons & Images',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Icon(Icons.favorite, color: Colors.red, size: 40),
                    Text('Favorite'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.thumb_up, color: Colors.blue, size: 40),
                    Text('Like'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 40),
                    Text('Star'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.share, color: Colors.green, size: 40),
                    Text('Share'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Color swatches
            const Text('Material Colors',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                _colorSwatch(Colors.red),
                _colorSwatch(Colors.pink),
                _colorSwatch(Colors.purple),
                _colorSwatch(Colors.deepPurple),
                _colorSwatch(Colors.indigo),
                _colorSwatch(Colors.blue),
                _colorSwatch(Colors.teal),
                _colorSwatch(Colors.green),
                _colorSwatch(Colors.yellow),
                _colorSwatch(Colors.orange),
                _colorSwatch(Colors.deepOrange),
                _colorSwatch(Colors.brown),
              ],
            ),

            const SizedBox(height: 24),

            // --- CARD STYLING ---
            const Text('Card Decorations',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.wb_sunny, color: Colors.orange.shade300),
                          const Text('Elevation 1'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.wb_sunny, color: Colors.orange.shade300),
                          const Text('Elevation 6'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    elevation: 12,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.wb_sunny, color: Colors.orange.shade300),
                          const Text('Elevation 12'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Gradient box
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade300, Colors.purple.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text('Gradient Container',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 24),

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
                      '💡 Use Theme.of(context) to access your app\'s colors '
                      'and text styles. Use Material icons with Icon(). '
                      'Gradients, shadows, and borders go in BoxDecoration.',
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

  Widget _colorSwatch(Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
