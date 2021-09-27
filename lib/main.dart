import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      flutterBlue.startScan(
                        timeout: const Duration(seconds: 30),
                      );
                    });
                  },
                  child: const Text('Start Scan'),
                ),
                ElevatedButton(
                  onPressed: () {
                    return setState(() {
                      flutterBlue.stopScan();
                    });
                  },
                  child: const Text('Stop Scan'),
                ),
              ],
            ),
            StreamBuilder<List<ScanResult>>(
              stream: flutterBlue.scanResults,
              builder: (BuildContext context,
                  AsyncSnapshot<List<ScanResult>> snapshot) {
                if (snapshot.data == null) {
                  return Container();
                }
                if (snapshot.data!.isNotEmpty) {
                  return Wrap(
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      ...snapshot.data!
                          .map(
                            (ScanResult e) => GestureDetector(
                              onTap: () {
                                connectDevice(e.device);
                              },
                              child: _avatar(
                                e.device.name.isNotEmpty
                                    ? e.device.name
                                    : e.device.id.id,
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  );
                } else {
                  return const Text('Nenhum device encontrado.');
                }
              },
            ),
          ],
        ),
      ),
    ));
  }

  Widget _avatar(String deviceName) {
    return AvatarGlow(
      glowColor: Colors.blue,
      endRadius: 60.0,
      duration: const Duration(milliseconds: 2000),
      repeat: true,
      showTwoGlows: true,
      repeatPauseDuration: const Duration(milliseconds: 100),
      child: Material(
        elevation: 8.0,
        shape: const CircleBorder(),
        child: CircleAvatar(
          backgroundColor: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: FittedBox(
              fit: BoxFit.cover,
              child: Text(
                deviceName,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          radius: 40.0,
        ),
      ),
    );
  }

  Future<void> connectDevice(BluetoothDevice device) async {
    try {
      if (!await deviceConnected(device)) {
        device.connect();
      }
    } catch (e) {
      debugPrint('error in connect device: $e');
    }
  }

  Future<bool> deviceConnected(BluetoothDevice device) async {
    final List<BluetoothDevice> list =
        await FlutterBlue.instance.connectedDevices;
    return list.contains(device);
  }
}
