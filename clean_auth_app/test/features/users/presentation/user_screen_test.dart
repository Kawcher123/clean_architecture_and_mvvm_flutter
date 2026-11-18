import 'package:clean_auth_app/features/users/domain/entities/user.dart';
import 'package:clean_auth_app/features/users/domain/repositories/user_repository.dart';
import 'package:clean_auth_app/features/users/domain/usecases/get_users.dart';
import 'package:clean_auth_app/features/users/presentation/providers/user_provider.dart';
import 'package:clean_auth_app/features/users/presentation/screens/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository repository;

  setUp(() {
    repository = MockUserRepository();
  });

  Widget buildSubject(UserProvider provider) {
    return ChangeNotifierProvider<UserProvider>.value(
      value: provider,
      child: const MaterialApp(home: UserScreen()),
    );
  }

  testWidgets('shows loading indicator while fetching', (tester) async {
    when(() => repository.getUsers(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return const <User>[];
    });

    final provider = UserProvider(GetUsers(repository));

    await tester.pumpWidget(buildSubject(provider));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('renders user list after successful fetch', (tester) async {
    when(() => repository.getUsers(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer(
      (_) async => const [
        User(id: 1, name: 'Alice', email: 'alice@example.com'),
        User(id: 2, name: 'Bob', email: 'bob@example.com'),
      ],
    );

    final provider = UserProvider(GetUsers(repository));

    await tester.pumpWidget(buildSubject(provider));
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('alice@example.com'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('shows error and Retry when fetch fails', (tester) async {
    when(() => repository.getUsers(forceRefresh: any(named: 'forceRefresh')))
        .thenThrow(Exception('boom'));

    final provider = UserProvider(GetUsers(repository));

    await tester.pumpWidget(buildSubject(provider));
    await tester.pumpAndSettle();

    expect(find.textContaining('boom'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
