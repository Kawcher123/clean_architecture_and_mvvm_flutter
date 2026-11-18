class DeviceInfo {
  final String platform;
  final String model;
  final String manufacturer;
  final int batteryLevel;
  final String osVersion;
  final String source;

  const DeviceInfo({
    required this.platform,
    required this.model,
    required this.manufacturer,
    required this.batteryLevel,
    required this.osVersion,
    required this.source,
  });
}
