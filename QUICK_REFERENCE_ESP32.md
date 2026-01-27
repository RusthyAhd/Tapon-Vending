# 🎯 Quick Reference - ESP32 Developer

## What Your ESP32 Needs to Do

1. **Advertise as BLE Peripheral** with service UUID: `12345678-1234-5678-1234-56789abcdef0`
2. **Listen on TX Characteristic** (UUID: `12345678-1234-5678-1234-56789abcdef1`) for commands from app
3. **Send Status on RX Characteristic** (UUID: `12345678-1234-5678-1234-56789abcdef2`) to app
4. **Parse incoming commands** like `SLOT:3\n` → extract slot ID
5. **Activate motor** for that slot
6. **Detect item dispensing** via sensors
7. **Send status back** like `OK:3\n` or `ERR:3\n`

---

## Message Protocol

| Direction | Format | Example | Meaning |
|-----------|--------|---------|---------|
| **App → ESP32** | `SLOT:<ID>\n` | `SLOT:3\n` | Dispense from slot 3 |
| **ESP32 → App** | `OK:<ID>\n` | `OK:3\n` | Successfully dispensed slot 3 |
| **ESP32 → App** | `ERR:<ID>\n` | `ERR:3\n` | Failed to dispense slot 3 |
| **ESP32 → App** | `EMPTY:<ID>\n` | `EMPTY:3\n` | Slot 3 is empty |

**Encoding:** UTF-8 (standard ASCII)  
**Terminator:** Newline `\n` (0x0A)  
**Length:** 7 bytes for `SLOT:3\n`

---

## Minimal ESP32 Code Template

```cpp
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define SERVICE_UUID        "12345678-1234-5678-1234-56789abcdef0"
#define TX_CHAR_UUID        "12345678-1234-5678-1234-56789abcdef1"  // Receive commands
#define RX_CHAR_UUID        "12345678-1234-5678-1234-56789abcdef2"  // Send status

BLECharacteristic* pRxCharacteristic;

class WriteCallback : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* pChar) {
    std::string cmd = pChar->getValue();
    cmd.erase(0, cmd.find_first_not_of(" \n\r\t"));  // Trim
    cmd.erase(cmd.find_last_not_of(" \n\r\t") + 1);
    
    Serial.println("Received: " + String(cmd.c_str()));
    
    // Parse "SLOT:3"
    int slotId = -1;
    if (cmd.find("SLOT:") == 0) {
      slotId = atoi(cmd.substr(5).c_str());
    }
    
    if (slotId > 0) {
      bool ok = dispenseSlot(slotId);
      String response = ok ? ("OK:" + String(slotId)) : ("ERR:" + String(slotId));
      pRxCharacteristic->setValue(response + "\n");
      pRxCharacteristic->notify();
    }
  }
};

bool dispenseSlot(int slot) {
  // TODO: Activate motor for slot, detect item, return success
  Serial.printf("Dispensing slot %d\n", slot);
  return true;
}

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("Starting BLE Server...");
  
  BLEDevice::init("Tapon-Vending");
  BLEServer* pServer = BLEDevice::createServer();
  BLEService* pService = pServer->createService(SERVICE_UUID);
  
  BLECharacteristic* pTxChar = pService->createCharacteristic(
    TX_CHAR_UUID,
    BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_WRITE_NR
  );
  pTxChar->setCallbacks(new WriteCallback());
  
  pRxCharacteristic = pService->createCharacteristic(
    RX_CHAR_UUID,
    BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_READ
  );
  pRxCharacteristic->addDescriptor(new BLE2902());
  
  pService->start();
  BLEDevice::getAdvertising()->addServiceUUID(SERVICE_UUID);
  BLEDevice::getAdvertising()->start();
  
  Serial.println("BLE Service running. Waiting for app connection...");
}

void loop() {
  delay(1000);
}
```

---

## Testing Without Hardware

**Step 1:** Flash ESP32 with BLE service  
**Step 2:** Open Flutter app → Connect screen → Should see "Tapon-Vending"  
**Step 3:** Connect, then simulate a purchase  
**Step 4:** Check ESP32 serial monitor → Should show: `Received: SLOT:3`

---

## Common Issues

| Problem | Check |
|---------|-------|
| Device not visible | Advertising enabled? UUIDs correct? |
| Connected but no commands | TX Characteristic writable? Callback registered? |
| Motor not moving | GPIO configured? Power supplied? Logic inverted? |
| Sensor not detecting | Sensor facing right direction? Threshold calibrated? |

---

## Next: Integrate Your Hardware

1. **Map slots to GPIO pins** (define in code)
2. **Add motor control logic** in `dispenseSlot(int slot)`
3. **Add sensor reading logic** to detect item dispensing
4. **Test each slot individually**
5. **Run full system test** (see main documentation)

**See:** `ESP32_HANDOVER_DOCUMENTATION.md` for detailed implementation guide

---

**Ready?** Let's make this vending machine work! 🚀
