import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:convert';

class BluetoothService {
  // Singleton instance
  static final BluetoothService _instance = BluetoothService._internal();

  factory BluetoothService() {
    return _instance;
  }

  BluetoothService._internal();

  final FlutterReactiveBle _ble = FlutterReactiveBle();
  late Stream<DiscoveredDevice> scanStream;
  late QualifiedCharacteristic txCharacteristic;
  late QualifiedCharacteristic rxCharacteristic;

  // Add this getter
  FlutterReactiveBle get ble => _ble;

  bool isConnected = false;
  String serviceUUID =
      "12345678-1234-5678-1234-56789abcdef0"; // Change to your ESP32 service UUID
  String txUUID = "12345678-1234-5678-1234-56789abcdef1"; // ESP32 TX UUID
  String rxUUID = "12345678-1234-5678-1234-56789abcdef2"; // ESP32 RX UUID

  /// Start scanning for ESP32 devices
  Stream<List<DiscoveredDevice>> scanForDevices() async* {
    print('\n🔍 SCANNING FOR BLUETOOTH DEVICES...');
    List<DiscoveredDevice> devices = [];
    scanStream = _ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
      requireLocationServicesEnabled: false,
    );
    await for (final device in scanStream) {
      // Debug print to see what we're getting
     // print('📱 Found device: name="${device.name}", id=${device.id}, rssi=${device.rssi}');
      //print('   Services: ${device.serviceUuids}');

      if (!devices.any((d) => d.id == device.id)) {
        devices.add(device);
        print('   ✅ Device added to list (Total: ${devices.length})');
        yield devices;
      }
    }
  }

  /// Connect to a selected device
  Future<void> connectToDevice(DiscoveredDevice device) async {
    try {
      print('\n🔗 CONNECTING TO DEVICE: ${device.name}');
      print('   Device ID: ${device.id}');
      
      await _ble.connectToDevice(id: device.id).first;
      isConnected = true;

      print('✅ DEVICE CONNECTED SUCCESSFULLY');
      print('   Connection Status: $isConnected\n');

      // Define the read and write characteristics
      txCharacteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(serviceUUID),
        characteristicId: Uuid.parse(txUUID),
        deviceId: device.id,
      );

      rxCharacteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(serviceUUID),
        characteristicId: Uuid.parse(rxUUID),
        deviceId: device.id,
      );
      
      print('📡 TX/RX Characteristics configured\n');
    } catch (e) {
      print('❌ CONNECTION FAILED: $e');
      isConnected = false;
    }
  }

  /// Send data to ESP32
  Future<void> sendData(String data) async {
    print('📡 SENDING DATA TO DEVICE...');
    print('   Data: "$data"');
    print('   Encoding: UTF-8');
    print('   Connection Status: $isConnected');
    
    if (isConnected) {
      try {
        // Convert to UTF-8 bytes for better interoperability
        List<int> bytes = utf8.encode(data);
        await _ble.writeCharacteristicWithResponse(txCharacteristic,
            value: bytes);
        print('✅ DATA SENT SUCCESSFULLY (${bytes.length} bytes)\n');
      } catch (e) {
        print('❌ ERROR SENDING DATA: $e\n');
      }
    } else {
      print('❌ NOT CONNECTED - Cannot send data\n');
    }
  }

  /// Send slot ID to vending machine
  Future<void> sendSlotId(int slotId) async {
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🎯 BLUETOOTH TRANSMISSION - SLOT ID');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('   Slot ID: $slotId');
    print('   Connection Status: ${isConnected ? '✅ CONNECTED' : '❌ DISCONNECTED'}');
    
    if (isConnected) {
      // Send format: SLOT:3\n (with newline terminator for robust parsing)
      String slotCommand = 'SLOT:$slotId\n';
      print('   Command: "${slotCommand.replaceAll('\n', '\\n')}"');
      await sendData(slotCommand);
    } else {
      print('❌ CANNOT TRANSMIT - Device not connected');
      print('   Please ensure vending machine is connected via Bluetooth');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    }
  }

  /// Listen for incoming data from ESP32
  Stream<List<int>> receiveData() {
    return _ble.subscribeToCharacteristic(rxCharacteristic);
  }

  /// Disconnect from the device
  void disconnect() {
    print('\n🔌 DISCONNECTING FROM DEVICE...');
    _ble.deinitialize();
    isConnected = false;
    print('✅ DISCONNECTED\n');
  }
}
