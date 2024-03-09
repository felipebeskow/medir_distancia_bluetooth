import 'package:get/get.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  FlutterBlue ble = FlutterBlue.instance;

  Future scanDevices() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.nearbyWifiDevices.request().isGranted &&
        await Permission.locationWhenInUse.request().isGranted) {
      ble.startScan(timeout: const Duration(seconds: 10));
      ble.stopScan();
    }
  }

  Stream<List<ScanResult>> get scanResults => ble.scanResults;
}
