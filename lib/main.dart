import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:medir_distancia_bluetooth/ble_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensores BLE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Sensores BLE'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sensores BLE'),
        ),
        body: GetBuilder<BleController>(
            init: BleController(),
            builder: (BleController controller) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<List<ScanResult>>(
                      stream: controller.scanResults,
                      builder: (context, snapshop) {
                        if (snapshop.hasData) {
                          return SizedBox(
                              height: 700,
                              child: ListView.builder(
                                  itemCount: snapshop.data?.length,
                                  itemBuilder: (context, index) {
                                    final data = snapshop.data![index];
                                    return Card(
                                      elevation: 2,
                                      child: ListTile(
                                        title: Text(data.device.name),
                                        subtitle: Text(data.device.id.id),
                                        trailing: Text(data.rssi.toString()),
                                      ),
                                    );
                                  }));
                        } else {
                          return const Center(
                            child: Text("Nenhum dispositivo encontrado"),
                          );
                        }
                      }),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () => controller.scanDevices(),
                      child: const Text('Buscar')),
                ],
              ));
            }));
  }
}
