// import 'package:flutter/material.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:tapon_vending/bluetooth_service.dart.dart';

// class ConnectToMachinePage extends StatefulWidget {
//   @override
//   _ConnectToMachinePageState createState() => _ConnectToMachinePageState();
// }

// class _ConnectToMachinePageState extends State<ConnectToMachinePage> {
//   final BluetoothService _bluetoothService = BluetoothService();
//   List<DiscoveredDevice> _devices = [];
//   bool _isConnected = false;

//   @override
//   void initState() {
//     super.initState();
//     _startScanning();
//   }
  

//   void _startScanning() {
//     _bluetoothService.scanForDevices().listen((devices) {
//       setState(() {
//         _devices = devices;
//       });
//     });
//   }

//   Future<void> _connectToDevice(DiscoveredDevice device) async {
//     await _bluetoothService.connectToDevice(device);
//     setState(() {
//       _isConnected = true;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Connected to ${device.name}")),
//     );
//   }

//   Future<void> _sendTestCommand() async {
//     if (_isConnected) {
//       await _bluetoothService.sendData("VEND");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Command sent to vending machine")),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Not connected to a device")),
//       );
//     }
//   }

//   void _disconnect() {
//     _bluetoothService.disconnect();
//     setState(() {
//       _isConnected = false;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Disconnected")),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Connect to Machine")),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _devices.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(_devices[index].name.isEmpty ? "Unknown Device" : _devices[index].name),
//                   subtitle: Text(_devices[index].id),
//                   onTap: () => _connectToDevice(_devices[index]),
//                 );
//               },
//             ),
//           ),
//           if (_isConnected)
//             Column(
//               children: [
//                 ElevatedButton(
//                   onPressed: _sendTestCommand,
//                   child: Text("Send Test Command"),
//                 ),
//                 ElevatedButton(
//                   onPressed: _disconnect,
//                   child: Text("Disconnect"),
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:tapon_vending/bluetooth_service.dart.dart';
import 'package:tapon_vending/home/home_view.dart';


class ConnectToMachinePage extends StatefulWidget {
  @override
  _ConnectToMachinePageState createState() => _ConnectToMachinePageState();
}

class _ConnectToMachinePageState extends State<ConnectToMachinePage> {
  final BluetoothService _bluetoothService = BluetoothService();
  List<DiscoveredDevice> _devices = [];
  StreamSubscription<List<DiscoveredDevice>>? _scanSubscription;
  bool _isScanning = false;
  bool _isConnected = false;
  String? _connectedDeviceId;

  @override
  void initState() {
    super.initState();
    _requestPermissions().then((_) => _checkBleStatus());
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (statuses.values.every((status) => status.isGranted)) {
      print("✅ All permissions granted!");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please grant Bluetooth and Location permissions!")),
      );
    }
  }

  void _checkBleStatus() {
_bluetoothService.ble.statusStream.listen((status) {
  print('BLE Status: $status');
  if (status == BleStatus.poweredOff) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please turn on Bluetooth")),
    );
  }
});

  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    _scanSubscription = _bluetoothService.scanForDevices().listen((devices) {
      setState(() {
        _devices = devices;
      });
    }, onDone: () {
      setState(() => _isScanning = false);
    });
  }

  void _stopScan() {
    _scanSubscription?.cancel();
    setState(() => _isScanning = false);
  }

  Future<void> _connectToDevice(DiscoveredDevice device) async {
  _stopScan();
  try {
    await _bluetoothService.connectToDevice(device);
    setState(() {
      _isConnected = _bluetoothService.isConnected;
      _connectedDeviceId = device.id;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Connected to ${device.name}")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Connection failed: $e")),
    );
  }
}


  void _disconnectFromDevice() {
    _bluetoothService.disconnect();
    setState(() {
      _isConnected = false;
      _connectedDeviceId = null;
    });
  }

  @override
  void dispose() {
    _stopScan();
    _disconnectFromDevice();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Connect to Machine")),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _isScanning ? null : _startScan,
                child: Text("Scan for Devices"),
              ),
              ElevatedButton(
                onPressed: _isScanning ? _stopScan : null,
                child: Text("Stop Scanning"),
              ),
            ],
          ),
          if (_isScanning) CircularProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                return ListTile(
                  title: Text(device.name.isNotEmpty ? device.name : "Unknown Device"),
                  subtitle: Text(device.id),
                    trailing: ElevatedButton(
                    onPressed: () async {
                      await _connectToDevice(device);
                      if (_isConnected) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                      }
                    },
                    child: Text("Connect"),
                    ),
                  
                );
              },
            ),
          ),
          if (_isConnected) ...[
            Text("Connected to: $_connectedDeviceId"),
            ElevatedButton(
              onPressed: _disconnectFromDevice,
              child: Text("Disconnect"),
            ),
          ],
        ],
      ),
    );
  }
}
