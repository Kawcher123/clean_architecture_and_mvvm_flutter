import 'package:clean_auth_app/features/users/domain/entities/user.dart';
import 'package:clean_auth_app/features/users/domain/repositories/user_repository.dart';
import 'package:clean_auth_app/features/users/domain/usecases/get_users.dart';
import 'package:clean_auth_app/features/users/presentation/providers/user_provider.dart';
import 'package:clean_auth_app/features/users/presentation/screens/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

/// Lightweight fake repository used by the integration harness.
///
/// This keeps the test deterministic (no live HTTP) while still exercising
/// Provider → UseCase → Repository → UI as one flow.
class FakeUserRepository implements UserRepository {
  FakeUserRepository({this.shouldFail = false});

  bool shouldFail;
  int callCount = 0;

  @override
  Future<List<User>> getUsers({bool forceRefresh = false}) async {
    callCount += 1;
    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (shouldFail) {
      throw Exception('Unable to load users');
    }

    return const [
      User(id: 1, name: 'Integration Alice', email: 'alice@test.com'),
      User(id: 2, name: 'Integration Bob', email: 'bob@test.com'),
    ];
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Users feature end-to-end: load, show list, refresh',
      (tester) async {
    final repository = FakeUserRepository();
    final provider = UserProvider(GetUsers(repository));

    await tester.pumpWidget(
      ChangeNotifierProvider<UserProvider>.value(
        value: provider,
        child: const MaterialApp(home: UserScreen()),
      ),
    );

    // First pump builds the screen; second runs the post-frame fetch.
    await tester.pump();
    await tester.pump();
    expect(provider.isLoading, isTrue);

    // Data appears after the fake repository delay.
    await tester.pumpAndSettle();
    expect(find.text('Integration Alice'), findsOneWidget);
    expect(find.text('alice@test.com'), findsOneWidget);
    expect(find.text('Integration Bob'), findsOneWidget);
    expect(repository.callCount, 1);

    // Pull-to-refresh / app bar refresh
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(repository.callCount, greaterThanOrEqualTo(2));
    expect(find.text('Integration Alice'), findsOneWidget);
  });

  testWidgets('Users feature shows error then recovers on Retry',
      (tester) async {
    final repository = FakeUserRepository(shouldFail: true);
    final provider = UserProvider(GetUsers(repository));

    await tester.pumpWidget(
      ChangeNotifierProvider<UserProvider>.value(
        value: provider,
        child: const MaterialApp(home: UserScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.textContaining('Unable to load users'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    repository.shouldFail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Integration Alice'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });
}
