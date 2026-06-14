/// Phase 1: Dart Fundamentals — Async/Await, Futures & Streams
///
/// Run: dart run bin/phase1/02_async.dart
///
/// Async code is how Dart handles waiting (network, files, timers)
/// without blocking the UI or freezing your app.

import 'dart:async';

void main() async {
  print('══════════════════════════════════════');
  print('  ASYNC / AWAIT & FUTURES');
  print('══════════════════════════════════════\n');

  // --- 1. Future — a value that hasn't arrived yet ---
  print('1. Future basics:');
  Future<String> future = Future(() => 'Hello from the future!');

  // .then() is one way to handle it (older style)
  future.then((value) => print('   .then() -> $value'));

  // --- 2. async/await — cleaner way ---
  print('2. async/await:');
  String result = await _fetchData();
  print('   await -> $result\n');

  // --- 3. Simulating a network call ---
  print('3. Simulated network call:');
  print('   Fetching user profile...');
  UserProfile user = await _fetchUserProfile(42);
  print('   ✅ Got: ${user.name} (${user.email})\n');

  // --- 4. Error handling with try/catch ---
  print('4. Error handling:');
  try {
    await _riskyCall(shouldFail: true);
  } catch (e) {
    print('   Caught: $e');
  }
  print("   ✅ App didn't crash!\n");

  // --- 5. Future.wait — run multiple futures in parallel ---
  print('5. Parallel requests:');
  var results = await Future.wait([
    _fetchProfilePic(1),
    _fetchProfilePic(2),
    _fetchProfilePic(3),
  ]);
  print('   All profile pics loaded: $results\n');

  // --- 6. Stream — multiple values over time ---
  print('6. Streams (multiple values over time):');
  Stream<int> countdown = _countdownStream(5);

  // Listen to the stream (non-blocking)
  // We use await for below — but first let's show the listener pattern
  print('   Counting down:');
  await for (final count in countdown) {
    print('   ➡ $count');
  }
  print('   🚀 Blast off!\n');

  // --- 7. Transforming streams ---
  print('7. Stream transformation:');
  Stream<int> numbers = Stream.fromIterable([1, 2, 3, 4, 5]);
  Stream<String> doubled = numbers.map((n) => '${n * 2}');
  await for (final val in doubled) {
    print('   -> $val');
  }

  print('\n══════════════════════════════════════');
  print('  ✅ Async fundamentals done!');
  print('══════════════════════════════════════');
}

// --- Helper functions ---

Future<String> _fetchData() async {
  await Future.delayed(const Duration(milliseconds: 300));
  return 'Data loaded';
}

/// Simulates an API call returning a user profile
Future<UserProfile> _fetchUserProfile(int id) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return UserProfile(
    id: id,
    name: 'Alice Johnson',
    email: 'alice@example.com',
  );
}

Future<String> _fetchProfilePic(int userId) async {
  await Future.delayed(Duration(milliseconds: 200 + userId * 100));
  return 'avatar_${userId}.png';
}

Future<void> _riskyCall({required bool shouldFail}) async {
  await Future.delayed(const Duration(milliseconds: 200));
  if (shouldFail) {
    throw Exception('Something went wrong — but handled safely!');
  }
}

/// Creates a countdown stream that emits n, n-1, ..., 1
Stream<int> _countdownStream(int from) async* {
  for (int i = from; i > 0; i--) {
    yield i; // emit one value
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

class UserProfile {
  final int id;
  final String name;
  final String email;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
  });
}
