import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';


class BluetoothService {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  late Stream<DiscoveredDevice> scanStream;
  late QualifiedCharacteristic txCharacteristic;
  late QualifiedCharacteristic rxCharacteristic;
    
  // Add this getter
  FlutterReactiveBle get ble => _ble;


  bool isConnected = false;
  String serviceUUID = "12345678-1234-5678-1234-56789abcdef0"; // Change to your ESP32 service UUID
  String txUUID = "12345678-1234-5678-1234-56789abcdef1"; // ESP32 TX UUID
  String rxUUID = "12345678-1234-5678-1234-56789abcdef2"; // ESP32 RX UUID

  /// Start scanning for ESP32 devices
  Stream<List<DiscoveredDevice>> scanForDevices() async* {
    List<DiscoveredDevice> devices = [];
    scanStream = _ble.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency);
    await for (final device in scanStream) {
      if (!devices.any((d) => d.id == device.id)) {
        devices.add(device);
        yield devices;
      }
    }
  }

  /// Connect to a selected device
  Future<void> connectToDevice(DiscoveredDevice device) async {
    await _ble.connectToDevice(id: device.id).first;
    isConnected = true;
    

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
    
  }

  /// Send data to ESP32
  Future<void> sendData(String data) async {
    if (isConnected) {
      await _ble.writeCharacteristicWithResponse(txCharacteristic, value: data.codeUnits);
    }
  }

  /// Listen for incoming data from ESP32
  Stream<List<int>> receiveData() {
    return _ble.subscribeToCharacteristic(rxCharacteristic);
  }

  /// Disconnect from the device
  void disconnect() {
    _ble.deinitialize();
    isConnected = false;
  }
}
