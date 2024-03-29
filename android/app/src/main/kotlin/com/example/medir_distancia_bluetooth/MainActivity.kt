package com.example.medir_distancia_bluetooth

import android.bluetooth.BluetoothManager
import android.os.Build
import androidx.annotation.RequiresApi
import com.example.medir_distancia_bluetooth.blescanner.BleScanEventChannel
import com.example.medir_distancia_bluetooth.blescanner.BleScanRunner
import com.example.medir_distancia_bluetooth.blescanner.manager.BleScanManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private lateinit var bleScanRunner: BleScanRunner
    private lateinit var btManager: BluetoothManager
    private lateinit var bleScanManager: BleScanManager
    @RequiresApi(Build.VERSION_CODES.M)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)


        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "ble_scanner/event/devices")
            .setStreamHandler(BleScanEventChannel(context))

        btManager = getSystemService(BluetoothManager::class.java)
        bleScanRunner = BleScanRunner(btManager,0,context)
        bleScanManager = bleScanRunner.init()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ble_scanner/method")
            .setMethodCallHandler{ call, result ->
                when (call.method) {
                    "startScan" -> {
                        bleScanManager.scanBleDevices()
                        result.success(null)
                    }
                    "stopScan" -> {
                        bleScanRunner.stop()
                        result.success((null))
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }

    }
}
