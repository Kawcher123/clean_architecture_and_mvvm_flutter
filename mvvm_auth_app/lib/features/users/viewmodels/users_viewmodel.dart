import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class UsersViewModel extends ChangeNotifier {
  final UserService userService;

  UsersViewModel(this.userService);

  List<UserModel> users = [];
  bool isLoading = false;
  bool isOffline = false;
  String? error;

  Future<void> fetchUsers({bool forceRefresh = false}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      users = await userService.getUsers(forceRefresh: forceRefresh);
      isOffline = false;
    } catch (e) {
      error = e.toString();
      final lower = error!.toLowerCase();
      isOffline = lower.contains('internet') || lower.contains('network');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
