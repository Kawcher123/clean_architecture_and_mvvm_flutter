import 'package:flutter/material.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/get_users.dart';

class UserProvider extends ChangeNotifier {
  final GetUsers getUsers;

  UserProvider(this.getUsers);

  List<User> users = [];
  bool isLoading = false;
  bool isOffline = false;
  String? error;

  Future<void> fetchUsers({bool forceRefresh = false}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      users = await getUsers(forceRefresh: forceRefresh);
      isOffline = false;
    } catch (e) {
      error = e.toString();
      if (e.toString().toLowerCase().contains('internet') ||
          e.toString().toLowerCase().contains('network')) {
        isOffline = true;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
