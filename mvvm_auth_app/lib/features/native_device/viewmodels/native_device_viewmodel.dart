import 'package:flutter/material.dart';

import '../models/device_info_model.dart';
import '../services/native_device_service.dart';

class NativeDeviceViewModel extends ChangeNotifier {
  final NativeDeviceService nativeDeviceService;

  NativeDeviceViewModel(this.nativeDeviceService);

  DeviceInfoModel? deviceInfo;
  bool isLoading = false;
  String? error;

  Future<void> loadDeviceInfo() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      deviceInfo = await nativeDeviceService.getDeviceInfo();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> showMessage(String message) async {
    try {
      await nativeDeviceService.showNativeMessage(message);
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
