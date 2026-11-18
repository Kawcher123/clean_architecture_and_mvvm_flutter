package com.cleanarchitecture.clean_auth_app;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build;
import android.widget.Toast;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

/**
 * Android host Activity written in Java.
 *
 * Registers a MethodChannel so Flutter (Dart) can call native APIs:
 * - getDeviceInfo
 * - showNativeMessage
 */
public class MainActivity extends FlutterActivity {
    private static final String CHANNEL =
            "com.cleanarchitecture.clean_auth_app/native_device";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                CHANNEL
        ).setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "getDeviceInfo":
                    result.success(getDeviceInfo());
                    break;
                case "showNativeMessage": {
                    final String message = call.argument("message");
                    Toast.makeText(
                            MainActivity.this,
                            message != null ? message : "",
                            Toast.LENGTH_SHORT
                    ).show();
                    result.success(true);
                    break;
                }
                default:
                    result.notImplemented();
                    break;
            }
        });
    }

    private Map<String, Object> getDeviceInfo() {
        final Map<String, Object> info = new HashMap<>();
        info.put("platform", "Android");
        info.put("model", Build.MODEL);
        info.put("manufacturer", Build.MANUFACTURER);
        info.put("osVersion", Build.VERSION.RELEASE);
        info.put("batteryLevel", getBatteryLevel());
        info.put("source", "Java MainActivity MethodChannel");
        return info;
    }

    private int getBatteryLevel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            final BatteryManager batteryManager =
                    (BatteryManager) getSystemService(Context.BATTERY_SERVICE);
            if (batteryManager != null) {
                return batteryManager.getIntProperty(
                        BatteryManager.BATTERY_PROPERTY_CAPACITY
                );
            }
        }

        final Intent batteryStatus = registerReceiver(
                null,
                new IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        );
        if (batteryStatus == null) {
            return -1;
        }

        final int level = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
        final int scale = batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        if (level < 0 || scale <= 0) {
            return -1;
        }
        return Math.round(level * 100f / scale);
    }
}
