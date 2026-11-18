import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let channelName = "com.cleanarchitecture.clean_auth_app/native_device"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerNativeDeviceChannel(messenger: engineBridge.applicationRegistrar.messenger())
  }

  /// Registers MethodChannel handlers implemented in Swift.
  private func registerNativeDeviceChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterError(code: "UNAVAILABLE", message: "AppDelegate deallocated", details: nil))
        return
      }

      switch call.method {
      case "getDeviceInfo":
        result(self.getDeviceInfo())
      case "showNativeMessage":
        let args = call.arguments as? [String: Any]
        let message = (args?["message"] as? String) ?? ""
        self.showNativeAlert(message: message)
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func getDeviceInfo() -> [String: Any] {
    let device = UIDevice.current
    device.isBatteryMonitoringEnabled = true

    let battery = device.batteryLevel
    let batteryPercent: Int
    if battery < 0 {
      batteryPercent = -1
    } else {
      batteryPercent = Int((battery * 100).rounded())
    }

    return [
      "platform": "iOS",
      "model": device.model,
      "manufacturer": "Apple",
      "osVersion": device.systemVersion,
      "batteryLevel": batteryPercent,
      "source": "Swift AppDelegate MethodChannel",
    ]
  }

  private func showNativeAlert(message: String) {
    DispatchQueue.main.async {
      guard let controller = self.topViewController() else { return }

      let alert = UIAlertController(
        title: "Native iOS Alert",
        message: message,
        preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      controller.present(alert, animated: true)
    }
  }

  private func topViewController(
    base: UIViewController? = UIApplication.shared.connectedScenes
      .compactMap { ($0 as? UIWindowScene)?.keyWindow }
      .first?
      .rootViewController
  ) -> UIViewController? {
    if let nav = base as? UINavigationController {
      return topViewController(base: nav.visibleViewController)
    }
    if let tab = base as? UITabBarController {
      return topViewController(base: tab.selectedViewController)
    }
    if let presented = base?.presentedViewController {
      return topViewController(base: presented)
    }
    return base
  }
}
