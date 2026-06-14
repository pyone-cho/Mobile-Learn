/// Phase 1: Dart Fundamentals — Classes, Mixins & Constructors
///
/// Run: dart run bin/phase1/04_classes.dart
///
/// Dart classes are the blueprint for all Flutter widgets.
/// Mastering constructors, factories, and mixins is key.

import 'dart:convert';

void main() {
  print('══════════════════════════════════════');
  print('  CLASSES, CONSTRUCTORS & MIXINS');
  print('══════════════════════════════════════\n');

  // --- 1. Basic class with named parameters ---
  print('1. Basic class:');
  final user = User(id: 1, name: 'Alice');
  user.printInfo();
  print('');

  // --- 2. Named constructors ---
  print('2. Named constructors:');
  final anonymous = User.anonymous();
  anonymous.printInfo();

  final guest = User.guest();
  guest.printInfo();
  print('');

  // --- 3. Factory constructor (fromJson) ---
  print('3. Factory fromJson:');
  String json = '{"id": 42, "name": "Bob", "email": "bob@example.com"}';
  Map<String, dynamic> parsedJson = jsonDecode(json);
  final bob = User.fromJson(parsedJson);
  bob.printInfo();
  print('   toJson: ${bob.toJson()}\n');

  // --- 4. Const constructor ---
  print('4. Const constructors:');
  // const constructors create compile-time constants — super efficient!
  const origin = const Point(0, 0);
  const p1 = const Point(2, 3);
  const p2 = const Point(2, 3);
  print('   origin: $origin');
  print('   p1 == p2: ${identical(p1, p2)} (same const instance!)\n');

  // --- 5. Inheritance ---
  print('5. Inheritance:');
  final admin = AdminUser(id: 100, name: 'Charlie', role: 'superadmin');
  admin.printInfo();
  admin.printRole();
  print('');

  // --- 6. Mixins (reuse without inheritance) ---
  print('6. Mixins:');
  final logger = LoggerService();
  logger.log('App started');
  logger.warn('Low disk space');
  // We didn't need to extend a Logger class — we mixed it in!
  print('');

  // --- 7. Enums with properties ---
  print('7. Enhanced enums:');
  for (final status in Status.values) {
    print('   ${status.name}: ${status.label} (${status.isActive ? "active" : "inactive"})');
  }
  print('');

  // --- 8. Sealed class (Dart 3+) ---
  print('8. Sealed classes + pattern matching:');
  final results = [
    Success(data: 'Hello!'),
    Failure(error: 'Connection lost'),
    Loading(),
  ];

  for (final r in results) {
    switch (r) {
      case Success(data: var data):
        print('   ✅ $data');
      case Failure(error: var error):
        print('   ❌ $error');
      case Loading():
        print('   ⏳ Loading...');
    }
  }
  print('');

  // --- 9. Practical: Model with fromJson/toJson ---
  print('9. Real-world model:');
  final apiResponse = '''
  {
    "products": [
      {"id": 1, "title": "Laptop", "price": 999.99},
      {"id": 2, "title": "Mouse", "price": 29.99}
    ]
  }''';
  final products = ProductList.fromJson(jsonDecode(apiResponse));
  for (final p in products.items) {
    print('   #${p.id} ${p.title} — \$${p.price}');
  }
  print('');

  print('══════════════════════════════════════');
  print('  ✅ Classes done!');
  print('══════════════════════════════════════');
}

// --- 1 & 2 & 3: User class ---
class User {
  final int id;
  final String name;
  final String? email;

  // Standard constructor with named params + required
  const User({required this.id, required this.name, this.email});

  // Named constructor: anonymous user
  User.anonymous()
      : id = 0,
        name = 'Anonymous',
        email = null;

  // Named constructor: guest with defaults
  User.guest()
      : id = -1,
        name = 'Guest',
        email = 'guest@example.com';

  // Factory: deserialize from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String?,
    );
  }

  void printInfo() {
    final emailPart = email != null ? ' <$email>' : '';
    print('   👤 #$id $name$emailPart');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
}

// --- 4: Const class ---
class Point {
  final int x;
  final int y;

  const Point(this.x, this.y);

  @override
  String toString() => '($x, $y)';
}

// --- 5: Inheritance ---
class AdminUser extends User {
  final String role;

  // super() calls the parent constructor
  AdminUser({required super.id, required super.name, required this.role});

  void printRole() {
    print('   🔑 Role: $role');
  }
}

// --- 6: Mixin ---
mixin Logging {
  void log(String message) {
    _print('[LOG]', message);
  }

  void warn(String message) {
    _print('[WARN]', message);
  }

  void error(String message) {
    _print('[ERROR]', message);
  }

  void _print(String level, String msg) {
    final timestamp = DateTime.now().toIso8601String().split('T').last;
    print('   $level $timestamp — $msg');
  }
}

class LoggerService with Logging {}

// --- 7: Enhanced enum ---
enum Status {
  pending('Pending Review', false),
  approved('Approved', true),
  rejected('Rejected', false),
  published('Published', true);

  final String label;
  final bool isActive;

  const Status(this.label, this.isActive);
}

// --- 8: Sealed class ---
sealed class ApiResult {}

class Success extends ApiResult {
  final String data;
  Success({required this.data});
}

class Failure extends ApiResult {
  final String error;
  Failure({required this.error});
}

class Loading extends ApiResult {}

// --- 9: Product model ---
class Product {
  final int id;
  final String title;
  final double price;

  const Product({
    required this.id,
    required this.title,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Untitled',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ProductList {
  final List<Product> items;

  const ProductList({required this.items});

  factory ProductList.fromJson(Map<String, dynamic> json) {
    final list = json['products'] as List<dynamic>? ?? [];
    return ProductList(
      items: list
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
