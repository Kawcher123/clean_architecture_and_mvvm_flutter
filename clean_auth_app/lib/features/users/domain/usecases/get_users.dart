import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetUsers {
  final UserRepository repository;

  GetUsers(this.repository);

  Future<List<User>> call({bool forceRefresh = false}) {
    return repository.getUsers(forceRefresh: forceRefresh);
  }
}
