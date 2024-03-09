// import 'dart:io';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _permissionStatus;
  final PermissionHandlerPlatform _permissionHandler =
      PermissionHandlerPlatform.instance;
  var _ble = [];

  @override
  initState() {
    super.initState();
    requestPermission(Permission.bluetoothConnect);
    requestPermission(Permission.bluetoothScan);
    initFlutterBlue();
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await _permissionHandler.requestPermissions([permission]);
    setState(() {
      print(status);
      _permissionStatus = status[permission] ?? PermissionStatus.denied;
      print(_permissionStatus);
    });
  }

  Future<void> initFlutterBlue() async {
    // first, check if bluetooth is supported by your hardware
    // Note: The platform is initialized on the first call to any FlutterBluePlus method.
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }

    // handle bluetooth on & off
    // note: for iOS the initial state is typically BluetoothAdapterState.unknown
    // note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    var subscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print(state);
      if (state == BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc

        // listen to scan results
        // Note: `onScanResults` only returns live scan results, i.e. during scanning
        // Use: `scanResults` if you want live scan results *or* the results from a previous scan
        var subscriptionInner = FlutterBluePlus.onScanResults.listen(
          (results) {
            if (results.isNotEmpty) {
              results.forEach((r) {
                print(
                    '${r.device.remoteId}: "${r.advertisementData.advName}" found!');
              }); // the most recently found device
            }
          },
          onError: (e) => print(e),
        );

        // cleanup: cancel subscription when scanning stops
        // FlutterBluePlus.cancelWhenScanComplete(subscriptionInner);

        // Wait for Bluetooth enabled & permission granted
        // In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
        FlutterBluePlus.adapterState
            .where((val) => val == BluetoothAdapterState.on)
            .first;

        // Start scanning w/ timeout
        // Optional: you can use `stopScan()` as an alternative to using a timeout
        // Note: scan filters use an *or* behavior. i.e. if you set `withServices` & `withNames`
        //   we return all the advertisments that match any of the specified services *or* any
        //   of the specified names.
        FlutterBluePlus.startScan(
            // withServices: [Guid("180D")],
            //withNames: ["Holy-IOT"],
            timeout: Duration(seconds: 150));

        // wait for scanning to stop
        FlutterBluePlus.isScanning.where((val) => val == false).first;
      } else {
        // show an error to the user, etc
        const errorSnack = SnackBar(
          content: Text('Veja seu bluetooth!'),
        );
        print('Erro ao ativar bluetooth!');

        // Find the ScaffoldMessenger in the widget tree
        // and use it to show a SnackBar.
        ScaffoldMessenger.of(context).showSnackBar(errorSnack);
      }
    });

    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    // cancel to prevent duplicate listeners
    // subscription.cancel();
  }

  // int _counter = 0;

  // void _incrementCounter() {
  //   setState(() {
  //     // This call to setState tells the Flutter framework that something has
  //     // changed in this State, which causes it to rerun the build method below
  //     // so that the display can reflect the updated values. If we changed
  //     // _counter without calling setState(), then the build method would not be
  //     // called again, and so nothing would appear to happen.
  //     _counter++;
  //   });
  // }

  // _MyHomePageState() {
  // Start scanning
  // flutterBlue.startScan(timeout: const Duration(seconds: 4));

  // // Listen to scan results
  // flutterBlue.scanResults.listen((results) {
  //   // do something with scan results
  //   for (ScanResult r in results) {
  //     print('${r.device.name} found! rssi: ${r.rssi}');
  //   }
  // });

  // Stop scanning
  // flutterBlue.stopScan();
  // }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('teste'),
            SizedBox(
              height: 600,
              child: ListView(
                  children: Permission.values
                      .where((permission) {
                        return permission == Permission.bluetoothScan ||
                            permission == Permission.bluetoothConnect;
                      })
                      .map((permission) => PermissionWidget(permission))
                      .toList()),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {}, //_incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class PermissionWidget extends StatefulWidget {
  const PermissionWidget(this._permission, {super.key});

  final Permission _permission;

  @override
  _PermissionState createState() => _PermissionState(_permission);
}

class _PermissionState extends State<PermissionWidget> {
  _PermissionState(this._permission);

  final Permission _permission;
  final PermissionHandlerPlatform _permissionHandler =
      PermissionHandlerPlatform.instance;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();

    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {
    final status = await _permissionHandler.checkPermissionStatus(_permission);
    setState(() => _permissionStatus = status);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListTile(
      title: Text(_permission.toString()),
      subtitle: Text(_permissionStatus.toString()),
    );
  }
}
