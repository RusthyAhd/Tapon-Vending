import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:convert';
import 'dart:async';

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
  String rxUUID = "abcd0002-1111-2222-3333-abcdefabcdef"; // ESP32 RX UUID

  /// Start scanning for ESP32 devices
  Stream<List<DiscoveredDevice>> scanForDevices() async* {
    print('\n🔍 SCANNING FOR BLUETOOTH DEVICES...');
    List<DiscoveredDevice> devices = [];
    scanStream = _ble.scanForDevices(
      withServices: [Uuid.parse(serviceUUID)],
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
    final completer = Completer<void>();
    StreamSubscription<ConnectionStateUpdate>? subscription;

    try {
      print('\n🔗 CONNECTING TO DEVICE: ${device.name}');
      print('   Device ID: ${device.id}');

      subscription = _ble.connectToDevice(id: device.id).listen(
        (connectionState) async {
          print("Connection state update: ${connectionState.connectionState}");
          if (connectionState.connectionState == DeviceConnectionState.connected) {
            isConnected = true;
            print('✅ DEVICE CONNECTED SUCCESSFULLY');

            try {
              // 🔥 REQUIRED: Discover services
              print('🧠 Discovering services...');
              final services = await _ble.discoverServices(device.id);
              for (final service in services) {
                print("Service found: ${service.serviceId}");
                for (final char in service.characteristics) {
                  print("  Characteristic: ${char.characteristicId}");
                }
              }
              print('🧠 SERVICES DISCOVERED: ${services.length}');

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

              print('📡 TX/RX Characteristics READY\n');
              if (!completer.isCompleted) completer.complete();
            } catch (e) {
              print('❌ SERVICE DISCOVERY FAILED: $e');
              if (!completer.isCompleted) completer.completeError(e);
            }
          } else if (connectionState.connectionState ==
              DeviceConnectionState.disconnected) {
            isConnected = false;
            print('❌ DEVICE DISCONNECTED');
            if (!completer.isCompleted) {
              completer.completeError('Disconnected during setup');
            }
          }
        },
        onError: (error) {
          print('❌ CONNECTION ERROR: $error');
          isConnected = false;
          if (!completer.isCompleted) completer.completeError(error);
        },
      );

      // Wait for connection and discovery to complete
      await completer.future;
    } catch (e) {
      print('❌ CONNECTION FAILED: $e');
      isConnected = false;
      rethrow;
    } finally {
      // NOTE: We don't cancel the subscription here because we want to stay connected
      // but in a real app you might want to manage this subscription.
    }
  }


  /// Send data to ESP32
Future<void> sendData(String data) async {
  print('📡 SENDING DATA TO DEVICE...');
  print('   Data: "$data"');
  print('   Connection Status: $isConnected');

  if (!isConnected) return;

  try {
    await _ble.writeCharacteristicWithoutResponse(
      txCharacteristic,
      value: utf8.encode(data),
    );
    print('✅ DATA SENT SUCCESSFULLY\n');
  } catch (e) {
    print('❌ ERROR SENDING DATA: $e\n');
  }
}


  /// Send slot ID to vending machine
Future<void> sendSlotId(int slotId) async {
  print('\n🎯 SENDING SLOT COMMAND: $slotId');

  if (!isConnected) {
    print('❌ NOT CONNECTED');
    return;
  }

  await sendData("SLOT:$slotId");
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
