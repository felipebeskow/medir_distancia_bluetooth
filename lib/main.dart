import 'package:flutter/material.dart';
import 'package:medir_distancia_bluetooth/channels/ble_scanner_channel.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
  final BleScannerChannel _channelDevices = BleScannerChannel();
  String _buttonScanText = 'Iniciar';
  bool _buttonScan = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sensores BLE'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder(
                stream: _channelDevices.stream,
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
                                  title: Text(data[0] + '/' + data[1]),
                                  subtitle: Text(data[3]),
                                  trailing: Text(data[2]),
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
              onPressed: _controllScan,
              child: Text(_buttonScanText),
            ),
          ],
        )));
  }

  void _controllScan() async {
    if (_buttonScan) {
      _channelDevices.stopScan();
      setState(() {
        _buttonScan = false;
        _buttonScanText = 'Iniciar';
      });
    } else {
      _channelDevices.startScan();
      setState(() {
        _buttonScan = true;
        _buttonScanText = 'Parar';
      });
    }
  }
}
