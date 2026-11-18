import 'package:flutter/services.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/platform/method_channel_constants.dart';
import '../models/device_info_model.dart';

/// Talks to Android (Java) / iOS (Swift) through a MethodChannel.
///
/// This is a Data Layer concern — Domain never imports MethodChannel.
class NativeDeviceDataSource {
  final MethodChannel channel;

  NativeDeviceDataSource({MethodChannel? channel})
      : channel = channel ??
            const MethodChannel(MethodChannelConstants.nativeDeviceChannel);

  Future<DeviceInfoModel> getDeviceInfo() async {
    try {
      final result = await channel.invokeMethod<Map<dynamic, dynamic>>(
        MethodChannelConstants.getDeviceInfo,
      );

      if (result == null) {
        throw const AppException('Native layer returned empty device info');
      }

      return DeviceInfoModel.fromMap(result);
    } on PlatformException catch (e) {
      throw AppException(e.message ?? 'Failed to get device info from native');
    } on MissingPluginException {
      throw const AppException(
        'Native MethodChannel is not registered. Run on Android/iOS device or emulator.',
      );
    }
  }

  Future<void> showNativeMessage(String message) async {
    try {
      await channel.invokeMethod<void>(
        MethodChannelConstants.showNativeMessage,
        {'message': message},
      );
    } on PlatformException catch (e) {
      throw AppException(e.message ?? 'Failed to show native message');
    } on MissingPluginException {
      throw const AppException(
        'Native MethodChannel is not registered. Run on Android/iOS device or emulator.',
      );
    }
  }
}
