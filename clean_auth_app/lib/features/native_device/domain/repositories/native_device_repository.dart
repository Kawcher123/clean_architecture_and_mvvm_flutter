import '../entities/device_info.dart';

abstract class NativeDeviceRepository {
  Future<DeviceInfo> getDeviceInfo();

  Future<void> showNativeMessage(String message);
}
