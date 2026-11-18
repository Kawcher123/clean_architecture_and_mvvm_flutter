import 'package:clean_auth_app/features/users/domain/entities/user.dart';
import 'package:clean_auth_app/features/users/domain/repositories/user_repository.dart';
import 'package:clean_auth_app/features/users/domain/usecases/get_users.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository repository;
  late GetUsers getUsers;

  setUp(() {
    repository = MockUserRepository();
    getUsers = GetUsers(repository);
  });

  const users = [
    User(id: 1, name: 'Alice', email: 'alice@example.com'),
    User(id: 2, name: 'Bob', email: 'bob@example.com'),
  ];

  group('GetUsers use case', () {
    test('returns users from repository', () async {
      when(() => repository.getUsers(forceRefresh: false))
          .thenAnswer((_) async => users);

      final result = await getUsers();

      expect(result, users);
      expect(result.length, 2);
      expect(result.first.name, 'Alice');
      verify(() => repository.getUsers(forceRefresh: false)).called(1);
    });

    test('forwards forceRefresh=true to repository', () async {
      when(() => repository.getUsers(forceRefresh: true))
          .thenAnswer((_) async => users);

      await getUsers(forceRefresh: true);

      verify(() => repository.getUsers(forceRefresh: true)).called(1);
      verifyNever(() => repository.getUsers(forceRefresh: false));
    });

    test('propagates repository errors', () async {
      when(() => repository.getUsers(forceRefresh: any(named: 'forceRefresh')))
          .thenThrow(Exception('network down'));

      expect(() => getUsers(), throwsA(isA<Exception>()));
    });
  });
}
