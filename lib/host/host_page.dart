import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';

class HostPage extends StatefulWidget {
  const HostPage({Key? key}) : super(key: key);

  @override
  State<HostPage> createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  final FlutterBlePeripheral blePeripheral = FlutterBlePeripheral();
  bool isSupported = false;
  bool isHosting = false;

  @override
  void initState() {
    blePeripheral.isSupported().then((bool value) {
      setState(() {
        isSupported = value;
      });
    });
    blePeripheral.isAdvertising().then((bool value) => isHosting = value);
    blePeripheral.getAdvertisingStateChange().listen((bool event) {
      setState(() {
        isHosting = event;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host'),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey[100],
          child: Column(
            children: <Widget>[
              ListTile(
                title: const Text('Device support BLE Peripheral'),
                trailing: Icon(
                  isSupported ? Icons.check : Icons.close,
                  color: isSupported ? Colors.green : Colors.black,
                ),
              ),
              ListTile(
                title: const Text('Device is hosting BLE Peripheral'),
                trailing: Icon(
                  isHosting ? Icons.check : Icons.close,
                  color: isHosting ? Colors.green : Colors.black,
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  if (!isHosting)
                    ElevatedButton(
                      onPressed: () {
                        final AdvertiseData data = AdvertiseData();
                        data.connectable = true;
                        data.includeDeviceName = false;
                        data.manufacturerId = 1234;
                        data.timeout = 1000;
                        data.manufacturerData = <int>[1, 2, 3, 4, 5, 6];
                        data.txPowerLevel =
                            AdvertisePower.ADVERTISE_TX_POWER_ULTRA_LOW;
                        data.advertiseMode =
                            AdvertiseMode.ADVERTISE_MODE_LOW_LATENCY;
                        data.uuid = '6f67019a-928f-4c0c-9bb8-08beaecf7221';
                        blePeripheral.start(data);
                      },
                      child: const Text('Host'),
                    ),
                  if (isHosting)
                    ElevatedButton(
                      onPressed: () {
                        blePeripheral.stop();
                      },
                      child: const Text('Stop hosting'),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
