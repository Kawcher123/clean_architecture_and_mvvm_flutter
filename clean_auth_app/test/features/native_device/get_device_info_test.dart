import 'package:clean_auth_app/features/native_device/domain/entities/device_info.dart';
import 'package:clean_auth_app/features/native_device/domain/repositories/native_device_repository.dart';
import 'package:clean_auth_app/features/native_device/domain/usecases/get_device_info.dart';
import 'package:clean_auth_app/features/native_device/domain/usecases/show_native_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNativeDeviceRepository extends Mock
    implements NativeDeviceRepository {}

void main() {
  late MockNativeDeviceRepository repository;

  setUp(() {
    repository = MockNativeDeviceRepository();
  });

  test('GetDeviceInfo returns repository device info', () async {
    const info = DeviceInfo(
      platform: 'iOS',
      model: 'iPhone',
      manufacturer: 'Apple',
      batteryLevel: 55,
      osVersion: '18.0',
      source: 'test',
    );

    when(() => repository.getDeviceInfo()).thenAnswer((_) async => info);

    final result = await GetDeviceInfo(repository)();

    expect(result.platform, 'iOS');
    expect(result.batteryLevel, 55);
    verify(() => repository.getDeviceInfo()).called(1);
  });

  test('ShowNativeMessage rejects empty message', () async {
    final useCase = ShowNativeMessage(repository);

    expect(() => useCase('   '), throwsA(isA<ArgumentError>()));
    verifyNever(() => repository.showNativeMessage(any()));
  });

  test('ShowNativeMessage trims and forwards message', () async {
    when(() => repository.showNativeMessage(any())).thenAnswer((_) async {});

    await ShowNativeMessage(repository)('  hi  ');

    verify(() => repository.showNativeMessage('hi')).called(1);
  });
}
