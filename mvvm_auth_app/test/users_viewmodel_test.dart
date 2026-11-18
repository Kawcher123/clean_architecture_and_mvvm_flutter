import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvvm_auth_app/features/users/models/user_model.dart';
import 'package:mvvm_auth_app/features/users/services/user_service.dart';
import 'package:mvvm_auth_app/features/users/viewmodels/users_viewmodel.dart';

class MockUserService extends Mock implements UserService {}

void main() {
  late MockUserService service;
  late UsersViewModel viewModel;

  setUp(() {
    service = MockUserService();
    viewModel = UsersViewModel(service);
  });

  test('fetchUsers success updates users list', () async {
    when(() => service.getUsers(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer(
      (_) async => const [
        UserModel(id: 1, name: 'Alice', email: 'a@test.com'),
      ],
    );

    await viewModel.fetchUsers();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.error, isNull);
    expect(viewModel.users.length, 1);
    expect(viewModel.users.first.name, 'Alice');
  });

  test('fetchUsers failure sets error', () async {
    when(() => service.getUsers(forceRefresh: any(named: 'forceRefresh')))
        .thenThrow(Exception('network down'));

    await viewModel.fetchUsers();

    expect(viewModel.users, isEmpty);
    expect(viewModel.error, contains('network down'));
  });
}
