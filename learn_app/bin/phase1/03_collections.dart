/// Phase 1: Dart Fundamentals — Collections (Lists, Sets, Maps)
///
/// Run: dart run bin/phase1/03_collections.dart

void main() {
  print('══════════════════════════════════════');
  print('  COLLECTIONS');
  print('══════════════════════════════════════\n');

  // --- 1. LIST — ordered, indexed ---
  print('1. Lists:');
  List<String> fruits = ['apple', 'banana', 'cherry'];

  // Spread operator (...) — merge lists
  List<String> moreFruits = [...fruits, 'date', 'elderberry'];
  print('   spread: $moreFruits');

  // Collection-if — conditional inclusion
  bool includeCitrus = true;
  List<String> withConditional = [
    'apple',
    'banana',
    if (includeCitrus) 'orange',
  ];
  print('   collection-if: $withConditional');

  // Collection-for — transform inline
  List<String> uppercased = [
    for (final f in fruits) f.toUpperCase(),
  ];
  print('   collection-for: $uppercased\n');

  // --- 2. SET — unique, unordered ---
  print('2. Sets:');
  Set<int> numbers1 = {1, 2, 3, 4, 5};
  Set<int> numbers2 = {3, 4, 5, 6, 7};

  // Set operations
  print('   union:        ${numbers1.union(numbers2)}');
  print('   intersection: ${numbers1.intersection(numbers2)}');
  print('   difference:   ${numbers1.difference(numbers2)}');

  // Deduplication — super common real-world use
  List<String> withDupes = ['a', 'b', 'a', 'c', 'b', 'a'];
  List<String> unique = [...{...withDupes}]; // List → Set → List
  print('   deduped: $unique\n');

  // --- 3. MAP — key-value pairs ---
  print('3. Maps:');
  Map<String, dynamic> product = {
    'id': 101,
    'name': 'Widget',
    'price': 19.99,
    'inStock': true,
  };

  // Access with ?? fallback
  String name = product['name'] as String? ?? 'Unknown';
  double price = (product['price'] as num?)?.toDouble() ?? 0.0;
  print('   $name — \$${price.toStringAsFixed(2)}');

  // Looping over maps
  product.forEach((key, value) {
    print('   $key: $value (${value.runtimeType})');
  });

  // Filtering
  var stringsOnly = product.entries
      .where((e) => e.value is String)
      .map((e) => e.key)
      .toList();
  print('   string keys only: $stringsOnly\n');

  // --- 4. Practical: Grouping & counting ---
  print('4. Word frequency counter:');
  String text = 'the quick brown fox jumps over the lazy dog the fox';
  Map<String, int> freq = {};
  for (final word in text.split(' ')) {
    freq[word] = (freq[word] ?? 0) + 1;
  }
  freq.forEach((word, count) {
    print('   "$word" × $count');
  });

  // Top 3 most frequent
  var top3 = freq.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  print('   Top 3: ${top3.take(3).map((e) => "${e.key} (${e.value})").join(", ")}\n');

  // --- 5. Immutable collections ---
  print('5. Immutable (unmodifiable):');
  List<String> locked = List.unmodifiable(['read', 'only']);
  // locked.add('crash');  // ❌ runtime error — unmodifiable
  print('   unmodifiable: $locked\n');

  // --- 6. Exercise ---
  // Build a map of {name: score} from these lists
  List<String> studentNames = ['Alice', 'Bob', 'Charlie'];
  List<int> studentScores = [88, 72, 95];

  Map<String, int> scoreMap = {
    for (int i = 0; i < studentNames.length; i++)
      studentNames[i]: studentScores[i],
  };
  print('6. Exercise — score map: $scoreMap');

  // Find the top scorer
  var topStudent = scoreMap.entries.reduce(
    (a, b) => a.value > b.value ? a : b,
  );
  print('   Top scorer: ${topStudent.key} (${topStudent.value})\n');

  print('══════════════════════════════════════');
  print('  ✅ Collections done!');
  print('══════════════════════════════════════');
}
