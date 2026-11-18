class DeviceInfoModel {
  final String platform;
  final String model;
  final String manufacturer;
  final int batteryLevel;
  final String osVersion;
  final String source;

  const DeviceInfoModel({
    required this.platform,
    required this.model,
    required this.manufacturer,
    required this.batteryLevel,
    required this.osVersion,
    required this.source,
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
