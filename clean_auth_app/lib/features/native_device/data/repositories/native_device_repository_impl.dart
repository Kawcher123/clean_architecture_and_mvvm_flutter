import '../../domain/entities/device_info.dart';
import '../../domain/repositories/native_device_repository.dart';
import '../datasources/native_device_datasource.dart';

class NativeDeviceRepositoryImpl implements NativeDeviceRepository {
  final NativeDeviceDataSource dataSource;

  NativeDeviceRepositoryImpl(this.dataSource);

  @override
  Future<DeviceInfo> getDeviceInfo() {
    return dataSource.getDeviceInfo();
  }

  @override
  Future<void> showNativeMessage(String message) {
    return dataSource.showNativeMessage(message);
  }
}
