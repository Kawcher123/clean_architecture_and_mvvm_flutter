import 'package:flutter/material.dart';

import '../../domain/entities/device_info.dart';
import '../../domain/usecases/get_device_info.dart';
import '../../domain/usecases/show_native_message.dart';

class NativeDeviceProvider extends ChangeNotifier {
  final GetDeviceInfo getDeviceInfoUseCase;
  final ShowNativeMessage showNativeMessageUseCase;

  NativeDeviceProvider({
    required this.getDeviceInfoUseCase,
    required this.showNativeMessageUseCase,
  });

  DeviceInfo? deviceInfo;
  bool isLoading = false;
  String? error;

  Future<void> loadDeviceInfo() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      deviceInfo = await getDeviceInfoUseCase();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> showMessage(String message) async {
    try {
      await showNativeMessageUseCase(message);
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
