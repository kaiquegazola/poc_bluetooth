import 'package:flutter/material.dart';

import 'connect/connect_page.dart';
import 'host/host_page.dart';

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
      home: const ChoosePage(),
    );
  }
}

class ChoosePage extends StatelessWidget {
  const ChoosePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.grey[100],
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const ConnectPage(),
                    ),
                  );
                },
                child: const Text('Connect'),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const HostPage(),
                    ),
                  );
                },
                child: const Text('Host'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
