import 'package:clean_auth_app/core/platform/method_channel_constants.dart';
import 'package:clean_auth_app/features/native_device/data/datasources/native_device_datasource.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(MethodChannelConstants.nativeDeviceChannel);
  late NativeDeviceDataSource dataSource;

  setUp(() {
    dataSource = NativeDeviceDataSource(channel: channel);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getDeviceInfo maps native Map into DeviceInfoModel', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      expect(call.method, MethodChannelConstants.getDeviceInfo);
      return <String, Object?>{
        'platform': 'Android',
        'model': 'Pixel 8',
        'manufacturer': 'Google',
        'osVersion': '14',
        'batteryLevel': 87,
        'source': 'mock',
      };
    });

    final info = await dataSource.getDeviceInfo();

    expect(info.platform, 'Android');
    expect(info.model, 'Pixel 8');
    expect(info.batteryLevel, 87);
    expect(info.source, 'mock');
  });

  test('showNativeMessage invokes channel with message argument', () async {
    MethodCall? captured;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      captured = call;
      return true;
    });

    await dataSource.showNativeMessage('Hello native');

    expect(captured?.method, MethodChannelConstants.showNativeMessage);
    expect(captured?.arguments, {'message': 'Hello native'});
  });
}
