/// Phase 1: Dart Fundamentals — Sound Null Safety
///
/// Run: dart run bin/phase1/01_null_safety.dart
///
/// Dart enforces null safety at compile time — a variable can't hold null
/// unless you explicitly allow it. This eliminates null pointer exceptions.

void main() {
  print("══════════════════════════════════════");
  print("  SOUND NULL SAFETY");
  print("══════════════════════════════════════\n");

  // --- 1. Non-nullable types (default) ---
  // These can NEVER be null. The compiler enforces it.
  String name = "Alice";
  int age = 30;
  // name = null;  // ❌ COMPILE ERROR — null can't be assigned to String

  print("1. Non-nullable (can't be null):");
  print("   name = $name, age = $age\n");

  // --- 2. Nullable types (? suffix) ---
  // Add `?` to allow null. Every use must be checked.
  String? nickname = null;   // ✅ allowed
  int? score;                // ✅ defaults to null

  nickname = "Al";           // ✅ can reassign a value

  print("2. Nullable (can be null):");
  print("   nickname = $nickname, score = $score\n");

  // --- 3. Working with nullables — the ?? operator ---
  // ?? means "use this if null"
  String displayName = nickname ?? "Guest";
  String fallback = score?.toString() ?? "no score";

  print("3. Null-coalescing (??):");
  print("   displayName = $displayName");
  print("   fallback    = $fallback\n");

  // --- 4. Null-aware access (?.) ---
  // If the left side is null, the expression short-circuits to null
  String? nullName = null;
  int? length = nullName?.length;  // null instead of crash
  int actualLength = nullName?.length ?? 0;

  print("4. Null-aware access (?.) + default:");
  print("   nullName?.length = $length");
  print("   with ?? 0        = $actualLength\n");

  // --- 5. The ! operator (use sparingly!) ---
  // You tell Dart "trust me, this isn't null". It'll crash if you're wrong.
  String definitelyNotNull = nickname!;  // you know it's "Al"
  print("5. Force unwrap (!):");
  print("   nickname! = $definitelyNotNull (risky if wrong!)\n");

  // --- 6. late variables ---
  // Promise Dart you'll set it before first read.
  // Useful for dependency injection or computed-once values.
  late String greeting;

  // If we read greeting here WITHOUT setting it first -> runtime crash
  greeting = _buildGreeting(name, nickname);
  print("6. Late variable:");
  print('   greeting = "$greeting"\n');

  // --- 7. Practical: safe JSON parsing ---
  // This is THE most common real-world use case
  Map<String, dynamic> json = {
    "id": 42,
    "email": "alice@example.com",
    // "name" is missing — simulating real API data
  };

  // Safe extraction with ?? fallback
  int userId = json["id"] as int;
  String userEmail = (json["email"] as String?) ?? "no-email";
  String userName = (json["name"] as String?) ?? "Anonymous";

  print("7. Safe JSON parsing:");
  print("   id    = $userId");
  print("   email = $userEmail");
  print("   name  = $userName (was null, fell back)\n");

  // --- 8. Exercise ---
  // Uncomment and fix:
  // String? maybeNumber = "42";
  // int parsed = int.parse(maybeNumber);  // ❌ maybeNumber is String?
  // print(parsed);

  // ✅ Fix by adding ?? or !:
  String? maybeNumber = "42";
  int parsed = int.parse(maybeNumber ?? "0");
  print("8. Exercise: parsed = $parsed (fixed with ??)\n");

  print("══════════════════════════════════════");
  print("  ✅ Null safety done!");
  print("══════════════════════════════════════");
}

String _buildGreeting(String name, String? nickname) {
  final nickPart = nickname != null ? ' aka "$nickname"' : "";
  return "Hello $name$nickPart!";
}
