import '../entities/device_info.dart';
import '../repositories/native_device_repository.dart';

class GetDeviceInfo {
  final NativeDeviceRepository repository;

  GetDeviceInfo(this.repository);

  Future<DeviceInfo> call() {
    return repository.getDeviceInfo();
  }
}
