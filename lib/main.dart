import 'dart:async';

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
      title: 'POC Bluetooth',
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
  StreamController<String> status = StreamController<String>();
  String? lastStatus;
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
                    flutterBlue.startScan(timeout: const Duration(seconds: 30));
                    status.add('Scanning...');
                  },
                  child: const Text('Start Scan'),
                ),
                ElevatedButton(
                  onPressed: () {
                    flutterBlue.stopScan();
                    status.add('Idle.');
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
                                e.device,
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
            StreamBuilder<String>(
              stream: status.stream,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    snapshot.data ?? 'Idle.',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    ));
  }

  Widget _avatar(BluetoothDevice device) {
    return FutureBuilder<bool>(
        future: deviceConnected(device),
        initialData: false,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          return AvatarGlow(
            glowColor: snapshot.data! ? Colors.blue : Colors.grey,
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
                  padding: const EdgeInsets.all(10),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Text(
                      deviceName(
                        device,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                radius: 40.0,
              ),
            ),
          );
        });
  }

  Future<void> connectDevice(BluetoothDevice device) async {
    try {
      final String name = deviceName(device);
      if (!await deviceConnected(device)) {
        status.add('Connecting to $name...');
        return device.connect().then((void v) async {
          final bool connected = await deviceConnected(device);
          status.add(
            connected ? 'Connected to $name.' : 'Failed to connect in $name.',
          );
        });
      }
      status.add('Already connected to $name');
    } catch (e) {
      status.add('error in connect device: $e');
    }
  }

  String deviceName(BluetoothDevice device) {
    return device.name.isNotEmpty ? device.name : device.id.id;
  }

  Future<bool> deviceConnected(BluetoothDevice device) async {
    final List<BluetoothDevice> list = await flutterBlue.connectedDevices;
    return list.contains(device);
  }
}
