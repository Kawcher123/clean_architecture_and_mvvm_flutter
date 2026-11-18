import 'package:clean_auth_app/features/users/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel', () {
    test('fromJson maps API fields into model/entity', () {
      final model = UserModel.fromJson({
        'id': 10,
        'name': 'Grace Hopper',
        'email': 'grace@example.com',
        'username': 'ghopper',
        'phone': '123',
        'website': 'example.com',
      });

      expect(model.id, 10);
      expect(model.name, 'Grace Hopper');
      expect(model.email, 'grace@example.com');
      expect(model.username, 'ghopper');
    });

    test('toMap / fromMap round-trip for SQLite cache', () {
      const original = UserModel(
        id: 3,
        name: 'Ada',
        email: 'ada@example.com',
        username: 'ada',
      );

      final map = original.toMap();
      final restored = UserModel.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.email, original.email);
      expect(restored.username, original.username);
      expect(map.containsKey('cached_at'), isTrue);
    });
  });
}
