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
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  late Stream<DiscoveredDevice> scanStream;
  late QualifiedCharacteristic txCharacteristic;
  late QualifiedCharacteristic rxCharacteristic;

  // Add this getter
  FlutterReactiveBle get ble => _ble;

  bool isConnected = false;
  bool _isServiceDiscovered = false;
  bool _supportsWriteWithResponse = false;
  bool _supportsWriteWithoutResponse = true;
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

    try {
      print('\n🔗 CONNECTING TO DEVICE: ${device.name}');
      print('   Device ID: ${device.id}');

      // Ensure previous connection stream is closed before opening a new one.
      await _connectionSubscription?.cancel();
      _isServiceDiscovered = false;
      _supportsWriteWithResponse = false;
      _supportsWriteWithoutResponse = true;

      _connectionSubscription = _ble.connectToDevice(id: device.id).listen(
        (connectionState) async {
          print("Connection state update: ${connectionState.connectionState}");
          if (connectionState.connectionState ==
              DeviceConnectionState.connected) {
            isConnected = true;
            print('✅ DEVICE CONNECTED SUCCESSFULLY');

            try {
              // 🔥 REQUIRED: Discover services
              print('🧠 Discovering services...');
              final services = await _ble.discoverServices(device.id);

              DiscoveredCharacteristic? txDiscoveredCharacteristic;

              for (final service in services) {
                print("Service found: ${service.serviceId}");
                for (final char in service.characteristics) {
                  print("  Characteristic: ${char.characteristicId}");

                  final isTargetService =
                      service.serviceId.toString().toLowerCase() ==
                          serviceUUID.toLowerCase();
                  final isTxCharacteristic =
                      char.characteristicId.toString().toLowerCase() ==
                          txUUID.toLowerCase();

                  if (isTargetService && isTxCharacteristic) {
                    txDiscoveredCharacteristic = char;
                  }
                }
              }
              print('🧠 SERVICES DISCOVERED: ${services.length}');

              if (txDiscoveredCharacteristic != null) {
                _supportsWriteWithResponse =
                    txDiscoveredCharacteristic.isWritableWithResponse;
                _supportsWriteWithoutResponse =
                    txDiscoveredCharacteristic.isWritableWithoutResponse;
              }

              if (!_supportsWriteWithResponse &&
                  !_supportsWriteWithoutResponse) {
                throw Exception(
                  'TX characteristic does not support write operations. Check ESP32 characteristic properties.',
                );
              }

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

              _isServiceDiscovered = true;
              print('📡 TX/RX Characteristics READY\n');
              print(
                '✍️ Write mode capability -> withResponse: $_supportsWriteWithResponse, withoutResponse: $_supportsWriteWithoutResponse',
              );

              if (!completer.isCompleted) completer.complete();
            } catch (e) {
              print('❌ SERVICE DISCOVERY FAILED: $e');
              _isServiceDiscovered = false;
              if (!completer.isCompleted) completer.completeError(e);
            }
          } else if (connectionState.connectionState ==
              DeviceConnectionState.disconnected) {
            isConnected = false;
            _isServiceDiscovered = false;
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
      _isServiceDiscovered = false;
      rethrow;
    }
  }

  /// Send data to ESP32
  Future<bool> sendData(String data) async {
    print('📡 SENDING DATA TO DEVICE...');
    print('   Data: "$data"');
    print('   Connection Status: $isConnected');

    if (!isConnected) {
      print('❌ SEND ABORTED: DEVICE NOT CONNECTED\n');
      return false;
    }

    if (!_isServiceDiscovered) {
      print('❌ SEND ABORTED: SERVICES NOT READY\n');
      return false;
    }

    try {
      final payload = utf8.encode(data);

      if (_supportsWriteWithoutResponse) {
        await _ble.writeCharacteristicWithoutResponse(
          txCharacteristic,
          value: payload,
        );
      } else if (_supportsWriteWithResponse) {
        await _ble.writeCharacteristicWithResponse(
          txCharacteristic,
          value: payload,
        );
      }

      print('✅ DATA SENT SUCCESSFULLY\n');
      return true;
    } catch (e) {
      print('⚠️ Primary write method failed: $e');

      // Fallback path for devices/firmware that only support the other mode.
      try {
        final payload = utf8.encode(data);
        if (_supportsWriteWithResponse) {
          await _ble.writeCharacteristicWithResponse(
            txCharacteristic,
            value: payload,
          );
        } else {
          await _ble.writeCharacteristicWithoutResponse(
            txCharacteristic,
            value: payload,
          );
        }
        print('✅ DATA SENT SUCCESSFULLY (fallback mode)\n');
        return true;
      } catch (fallbackError) {
        print('❌ ERROR SENDING DATA: $fallbackError\n');
        return false;
      }
    }
  }

  /// Send slot ID to vending machine
  Future<bool> sendSlotId(int slotId) async {
    print('\n🎯 SENDING SLOT COMMAND: $slotId');

    if (!isConnected) {
      print('❌ NOT CONNECTED');
      return false;
    }

    // Keep firmware command format explicit and deterministic.
    return sendData("SLOT:$slotId");
  }

  /// Listen for incoming data from ESP32
  Stream<List<int>> receiveData() {
    return _ble.subscribeToCharacteristic(rxCharacteristic);
  }

  /// Disconnect from the device
  Future<void> disconnect() async {
    print('\n🔌 DISCONNECTING FROM DEVICE...');

    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    isConnected = false;
    _isServiceDiscovered = false;
    print('✅ DISCONNECTED\n');
  }
}
