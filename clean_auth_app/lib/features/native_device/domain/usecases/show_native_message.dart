import '../repositories/native_device_repository.dart';

class ShowNativeMessage {
  final NativeDeviceRepository repository;

  ShowNativeMessage(this.repository);

  Future<void> call(String message) {
    if (message.trim().isEmpty) {
      throw ArgumentError('Message cannot be empty');
    }
    return repository.showNativeMessage(message.trim());
  }
}
