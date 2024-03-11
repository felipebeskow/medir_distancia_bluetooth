import 'dart:async';
import 'dart:io';

import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:get/get.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  FlutterBlue ble = FlutterBlue.instance;

  Future scanDevices() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.nearbyWifiDevices.request().isGranted &&
        await Permission.locationWhenInUse.request().isGranted &&
        await Permission.bluetooth.request().isGranted &&
        await Permission.location.request().isGranted) {
      ble.startScan(timeout: const Duration(seconds: 10));
      ble.stopScan();

      BeaconsPlugin.channel.setMethodCallHandler((call) async {
        if (call.method == 'isPermissionDialogShown') {
          //Do something here
        }
      });
      // if you need to monitor also major and minor use the original version and not this fork
      BeaconsPlugin.addRegion(
          "Holy-IOT (iBeacon)", "FDA50693-A4E2-4FB1-aFCF-C6EB07647825");

      if (Platform.isAndroid) {
        BeaconsPlugin.channel.setMethodCallHandler((call) async {
          if (call.method == 'scannerReady') {
            await BeaconsPlugin.startMonitoring();
            print('monitar ble');
          }
        });
      } else if (Platform.isIOS) {
        await BeaconsPlugin.startMonitoring();
      }

      await BeaconsPlugin.startMonitoring();
      print('monitar ble');

      if (Platform.isAndroid) {
        //Prominent disclosure
        await BeaconsPlugin.setDisclosureDialogMessage(
            title: "Need Location Permission",
            message: "This app collects location data to work with beacons.");

        //Only in case, you want the dialog to be shown again. By Default, dialog will never be shown if permissions are granted.
        await BeaconsPlugin.clearDisclosureDialogShowFlag(false);
      }

      final StreamController<String> beaconEventsController =
          StreamController<String>.broadcast();
      BeaconsPlugin.listenToBeacons(beaconEventsController);

      beaconEventsController.stream.listen(
          (data) {
            if (data.isNotEmpty) {
              print("Beacons DataReceived: " + data);
            }
          },
          onDone: () {},
          onError: (error) {
            print("Error: $error");
          });
    }
  }

  Stream<List<ScanResult>> get scanResults => ble.scanResults;
}
