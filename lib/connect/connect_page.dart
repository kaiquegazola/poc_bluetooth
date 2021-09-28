import 'dart:async';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({Key? key}) : super(key: key);

  @override
  _ConnectPageState createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  BluetoothDevice? selectedDevice;
  StreamController<String> status = StreamController<String>();
  String? lastStatus;
  FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Connect'),
        ),
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
                        flutterBlue.startScan(
                          timeout: const Duration(seconds: 15),
                          withServices: <Guid>[
                            Guid('6f67019a-928f-4c0c-9bb8-08beaecf7221'),
                          ],
                        );
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
                                  onTap: () async {
                                    if (await deviceConnected(e.device)) {
                                      setState(() {
                                        selectedDevice = e.device;
                                      });
                                    } else {
                                      connectDevice(e.device);
                                    }
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
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
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
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateColor.resolveWith(
                      (Set<MaterialState> states) => Colors.black,
                    ),
                    backgroundColor: MaterialStateColor.resolveWith(
                      (Set<MaterialState> states) => Colors.tealAccent,
                    ),
                  ),
                  onPressed: selectedDevice != null ? () {} : null,
                  child: const Text('Send data'),
                ),
                StreamBuilder<List<BluetoothDevice>>(
                  stream: flutterBlue.connectedDevices.asStream(),
                  initialData: const <BluetoothDevice>[],
                  builder: (BuildContext context,
                      AsyncSnapshot<List<BluetoothDevice>> snapshot) {
                    return Column(
                      children: <Widget>[
                        ...snapshot.data!
                            .map((BluetoothDevice e) =>
                                Text('${deviceName(e)} - Connected'))
                            .toList()
                      ],
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
              elevation: 5.0,
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
                          ) +
                          (device == selectedDevice ? '\n(selected)' : ''),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: device == selectedDevice
                            ? Colors.deepPurpleAccent
                            : Colors.blue,
                        height: 1.5,
                      ),
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
        await device.connect();
        final bool connected = await deviceConnected(device);
        if (connected) {
          status.add('Connected to $name.');
          // verifyService(device);
        } else {
          status.add('Failed to connect in $name.');
        }
      }
      status.add('Already connected to $name');
    } catch (e) {
      status.add('error in connect device: $e');
    }
  }

  Future<void> verifyService(BluetoothDevice device) async {
    final String name = deviceName(device);
    status.add('Finding services of $name...');
    final List<BluetoothService> services = await device.discoverServices();
    if (services.any((BluetoothService element) =>
        element.uuid.toString() == '6f67019a-928f-4c0c-9bb8-08beaecf7221')) {
      status.add('Service stabled successful!');
    } else {
      status.add("$name doesn't have desired service...");
      device.disconnect();
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
