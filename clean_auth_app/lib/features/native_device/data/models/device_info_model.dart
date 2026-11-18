import '../../domain/entities/device_info.dart';

class DeviceInfoModel extends DeviceInfo {
  const DeviceInfoModel({
    required super.platform,
    required super.model,
    required super.manufacturer,
    required super.batteryLevel,
    required super.osVersion,
    required super.source,
  });

  factory DeviceInfoModel.fromMap(Map<dynamic, dynamic> map) {
    return DeviceInfoModel(
      platform: (map['platform'] ?? 'unknown').toString(),
      model: (map['model'] ?? 'unknown').toString(),
      manufacturer: (map['manufacturer'] ?? 'unknown').toString(),
      batteryLevel: _asInt(map['batteryLevel']),
      osVersion: (map['osVersion'] ?? 'unknown').toString(),
      source: (map['source'] ?? 'native').toString(),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? -1;
  }
}
