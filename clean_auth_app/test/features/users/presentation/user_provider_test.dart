import 'package:clean_auth_app/features/users/domain/entities/user.dart';
import 'package:clean_auth_app/features/users/domain/repositories/user_repository.dart';
import 'package:clean_auth_app/features/users/domain/usecases/get_users.dart';
import 'package:clean_auth_app/features/users/presentation/providers/user_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository repository;
  late UserProvider provider;

  setUp(() {
    repository = MockUserRepository();
    provider = UserProvider(GetUsers(repository));
  });

  const users = [
    User(id: 1, name: 'Alice', email: 'alice@example.com'),
  ];

  test('fetchUsers success updates users and clears loading', () async {
    when(() => repository.getUsers(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => users);

    final future = provider.fetchUsers();
    expect(provider.isLoading, isTrue);

    await future;

    expect(provider.isLoading, isFalse);
    expect(provider.error, isNull);
    expect(provider.users, users);
    expect(provider.isOffline, isFalse);
  });

  test('fetchUsers failure sets error message', () async {
    when(() => repository.getUsers(forceRefresh: any(named: 'forceRefresh')))
        .thenThrow(Exception('Failed to load users'));

    await provider.fetchUsers();

    expect(provider.isLoading, isFalse);
    expect(provider.users, isEmpty);
    expect(provider.error, contains('Failed to load users'));
  });

  test('network-like errors mark isOffline true', () async {
    when(() => repository.getUsers(forceRefresh: any(named: 'forceRefresh')))
        .thenThrow(Exception('No internet connection'));

    await provider.fetchUsers();

    expect(provider.isOffline, isTrue);
    expect(provider.error, contains('internet'));
  });
}
