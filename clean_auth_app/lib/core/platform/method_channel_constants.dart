/// Shared MethodChannel names and method identifiers.
///
/// Keep these in Dart (and mirror them in Java / Swift).
/// Changing a name on only one side will break the bridge.
class MethodChannelConstants {
  MethodChannelConstants._();

  static const String nativeDeviceChannel =
      'com.cleanarchitecture.clean_auth_app/native_device';

  static const String getDeviceInfo = 'getDeviceInfo';
  static const String showNativeMessage = 'showNativeMessage';
}
