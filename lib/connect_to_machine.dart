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
        SnackBar(
            content: Text("Please grant Bluetooth and Location permissions!")),
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

    print('🔍 Starting BLE scan...');

    _scanSubscription = _bluetoothService.scanForDevices().listen((devices) {
      print('📊 Found ${devices.length} devices so far');
      setState(() {
        _devices = devices;
      });
    }, onDone: () {
      print('✅ Scan completed');
      setState(() => _isScanning = false);
    }, onError: (error) {
      print('❌ Scan error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Scan error: $error")),
      );
      setState(() => _isScanning = false);
    });
  }

  void _stopScan() {
    _scanSubscription?.cancel();
    setState(() => _isScanning = false);
  }

  Future<void> _connectToDevice(DiscoveredDevice device) async {
    _stopScan();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Connecting to device...")),
    );

    try {
      print('🔗 Attempting to connect to: ${device.id}');
      await _bluetoothService.connectToDevice(device);
      setState(() {
        _isConnected = _bluetoothService.isConnected;
        _connectedDeviceId = device.id;
      });

      final deviceName = device.name.isNotEmpty ? device.name : device.id;
      print('✅ Connected successfully to: $deviceName');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Connected to $deviceName"),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      print('❌ Connection failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Connection failed: $e"),
            backgroundColor: Colors.red),
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromRGBO(5, 248, 175, 1)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Connect to Machine",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Section with status
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.grey[900]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _isConnected ? Icons.check_circle : Icons.bluetooth_searching,
                  color: _isConnected
                      ? Color.fromRGBO(5, 248, 175, 1)
                      : Colors.white70,
                  size: 60,
                ),
                SizedBox(height: 12),
                Text(
                  _isConnected
                      ? "Connected to Vending Machine"
                      : "Searching for Vending Machines",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_isConnected && _connectedDeviceId != null) ...[
                  SizedBox(height: 8),
                  Text(
                    _connectedDeviceId!,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
                SizedBox(height: 20),
                // Scan Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isConnected) ...[
                      ElevatedButton.icon(
                        onPressed: _isScanning ? _stopScan : _startScan,
                        icon: Icon(
                          _isScanning ? Icons.stop : Icons.search,
                          color: Colors.black,
                        ),
                        label: Text(
                          _isScanning ? "Stop Scan" : "Scan Devices",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(5, 248, 175, 1),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        onPressed: _disconnectFromDevice,
                        icon:
                            Icon(Icons.bluetooth_disabled, color: Colors.white),
                        label: Text(
                          "Disconnect",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Scanning Indicator
          if (_isScanning)
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromRGBO(5, 248, 175, 1),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Scanning...",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

          // Devices List Header
          if (_devices.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    "Available Devices (${_devices.length})",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Devices List
          Expanded(
            child: _devices.isEmpty && !_isScanning
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bluetooth_disabled,
                          size: 80,
                          color: Colors.white24,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No devices found",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Tap 'Scan Devices' to search",
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      final deviceName = device.name.isNotEmpty
                          ? device.name
                          : "Unknown Device";
                      final signalStrength = device.rssi;
                      final isStrongSignal = signalStrength > -70;

                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey[900]!, Colors.grey[850]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white10,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isStrongSignal
                                  ? Color.fromRGBO(5, 248, 175, 0.2)
                                  : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.devices,
                              color: isStrongSignal
                                  ? Color.fromRGBO(5, 248, 175, 1)
                                  : Colors.orange,
                              size: 32,
                            ),
                          ),
                          title: Text(
                            deviceName,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.fingerprint,
                                        size: 14, color: Colors.white38),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        device.id,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white54,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.signal_cellular_alt,
                                      size: 14,
                                      color: isStrongSignal
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "$signalStrength dBm ${isStrongSignal ? '(Strong)' : '(Weak)'}",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isStrongSignal
                                            ? Colors.green
                                            : Colors.orange,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                if (device.serviceUuids.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Icon(Icons.settings_bluetooth,
                                            size: 14, color: Colors.blue),
                                        SizedBox(width: 4),
                                        Text(
                                          "${device.serviceUuids.length} Services",
                                          style: TextStyle(
                                              fontSize: 11, color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              await _connectToDevice(device);
                              if (_isConnected) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(5, 248, 175, 1),
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 3,
                            ),
                            child: Text(
                              "Connect",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
