# Tapon Vending Machine - ESP32 & Hardware Integration Guide

---

## 📋 Table of Contents

1. [System Architecture](#system-architecture)
2. [Bluetooth Communication Protocol](#bluetooth-communication-protocol)
3. [BLE Service & Characteristic Configuration](#ble-service--characteristic-configuration)
4. [Message Format & Parsing](#message-format--parsing)
5. [ESP32 Implementation Guide](#esp32-implementation-guide)
6. [Vending Machine Hardware Integration](#vending-machine-hardware-integration)
7. [Testing & Verification](#testing--verification)
8. [Troubleshooting](#troubleshooting)

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUTTER MOBILE APP                      │
│  (iOS/Android - User selects product & confirms purchase)   │
└──────────────────────┬──────────────────────────────────────┘
                       │
         BLE (Bluetooth Low Energy)
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                      ESP32 MODULE                           │
│  (BLE Peripheral - Receives slot commands)                  │
└──────────────────────┬──────────────────────────────────────┘
                       │
          GPIO/PWM/UART/I2C/SPI
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              VENDING MACHINE HARDWARE                        │
│  (Motors, Solenoids, Sensors, Dispensing Logic)            │
└─────────────────────────────────────────────────────────────┘
```

**Data Flow:**
1. User selects product (e.g., Slot 3) in Flutter app
2. App confirms purchase and deducts balance (Firebase)
3. App sends command via BLE: `SLOT:3\n`
4. ESP32 receives command, parses slot ID
5. ESP32 activates correct motor/solenoid for that slot
6. Vending machine dispenses product
7. ESP32 sends status back to app (optional feedback)

---

## Bluetooth Communication Protocol

### Overview
- **Protocol:** BLE (Bluetooth Low Energy)
- **Device Role:** ESP32 acts as **BLE Peripheral (Server)**
- **App Role:** Mobile app acts as **BLE Central (Client)**
- **Connection Requirement:** App must be paired/connected before sending commands
- **Encoding:** UTF-8 text with newline terminator

### BLE Service Structure

**Service:** Custom GATT Service  
**UUID:** `12345678-1234-5678-1234-56789abcdef0`

**Characteristics:**

| Name | UUID | Direction | Property | Purpose |
|------|------|-----------|----------|---------|
| **TX Characteristic** (Receive) | `12345678-1234-5678-1234-56789abcdef1` | App → ESP32 | Write, Write No Response | App sends slot commands to ESP32 |
| **RX Characteristic** (Send) | `12345678-1234-5678-1234-56789abcdef2` | ESP32 → App | Notify, Read | ESP32 sends status/feedback to app |

---

## BLE Service & Characteristic Configuration

### ESP32 Setup (Pseudo-code example)

```cpp
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// UUIDs
#define SERVICE_UUID        "12345678-1234-5678-1234-56789abcdef0"
#define CHAR_TX_UUID        "12345678-1234-5678-1234-56789abcdef1"  // Write from app
#define CHAR_RX_UUID        "12345678-1234-5678-1234-56789abcdef2"  // Notify to app

BLECharacteristic* pTxCharacteristic;  // Receive commands
BLECharacteristic* pRxCharacteristic;  // Send status

class MyCharacteristicCallback : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* pCharacteristic) {
    std::string rxValue = pCharacteristic->getValue();
    if (rxValue.length() > 0) {
      Serial.println("Received command: " + String(rxValue.c_str()));
      handleSlotCommand(rxValue);
    }
  }
};

void setupBLE() {
  BLEDevice::init("Tapon-Vending");  // Device name
  BLEServer* pServer = BLEDevice::createServer();
  
  BLEService* pService = pServer->createService(SERVICE_UUID);
  
  // TX Characteristic (app writes slot commands)
  pTxCharacteristic = pService->createCharacteristic(
    CHAR_TX_UUID,
    BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_WRITE_NR
  );
  pTxCharacteristic->setCallbacks(new MyCharacteristicCallback());
  
  // RX Characteristic (app receives status)
  pRxCharacteristic = pService->createCharacteristic(
    CHAR_RX_UUID,
    BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_READ
  );
  pRxCharacteristic->addDescriptor(new BLE2902());  // Enable notifications
  
  pService->start();
  
  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMaxPreferred(0x12);
  BLEDevice::startAdvertising();
  
  Serial.println("BLE Service initialized. Waiting for connections...");
}
```

---

## Message Format & Parsing

### Command Format (App → ESP32)

**Format:** `SLOT:<SlotID>\n`

**Example Commands:**
```
SLOT:1\n    → Dispense from slot 1
SLOT:2\n    → Dispense from slot 2
SLOT:3\n    → Dispense from slot 3
...
SLOT:20\n   → Dispense from slot 20
```

**Properties:**
- **Prefix:** `SLOT:` (unambiguous identifier)
- **Slot ID:** Integer (1-255, no leading zeros)
- **Terminator:** Newline character `\n` (0x0A)
- **Encoding:** UTF-8 (standard ASCII compatible)
- **Total Length:** 6-8 bytes (e.g., `SLOT:3\n` = 7 bytes)

### Response Format (ESP32 → App) - Optional

**Recommended Status Messages:**
```
OK:<SlotID>\n         → Dispense successful (e.g., OK:3\n)
ERR:<SlotID>\n        → Dispense failed (e.g., ERR:3\n)
BUSY:<SlotID>\n       → Slot busy/already dispensing
EMPTY:<SlotID>\n      → Slot is empty
TIMEOUT:<SlotID>\n    → Dispense timeout
```

**Properties:**
- Confirm the command was executed
- Provides feedback to user (success/error dialog)
- Helps debug communication issues

### Parsing Implementation (C++ Example)

```cpp
void handleSlotCommand(std::string cmd) {
  // Trim whitespace (including \n)
  cmd.erase(0, cmd.find_first_not_of(" \n\r\t"));
  cmd.erase(cmd.find_last_not_of(" \n\r\t") + 1);
  
  int slotId = -1;
  
  // Parse "SLOT:3" format
  if (cmd.find("SLOT:") == 0) {
    std::string idStr = cmd.substr(5);  // Extract after "SLOT:"
    slotId = atoi(idStr.c_str());
  }
  // Fallback: parse plain number "3"
  else {
    slotId = atoi(cmd.c_str());
  }
  
  // Validate
  if (slotId > 0 && slotId <= MAX_SLOTS) {
    Serial.printf("Dispensing slot: %d\n", slotId);
    bool success = dispenseSlot(slotId);
    
    // Send status back
    if (success) {
      pRxCharacteristic->setValue("OK:" + String(slotId) + "\n");
    } else {
      pRxCharacteristic->setValue("ERR:" + String(slotId) + "\n");
    }
    pRxCharacteristic->notify();
    
  } else {
    Serial.println("Invalid slot ID");
    pRxCharacteristic->setValue("ERR:FORMAT\n");
    pRxCharacteristic->notify();
  }
}
```

---

## ESP32 Implementation Guide

### Step 1: GPIO Pin Configuration

**Define your motor/solenoid control pins:**

```cpp
// Motor control pins (example)
#define MOTOR_SLOT_1_PIN   25
#define MOTOR_SLOT_2_PIN   26
#define MOTOR_SLOT_3_PIN   27
// ... etc for all slots

// Sensor pins (example)
#define DISPENSE_SENSOR_PIN  35  // Optical sensor to detect item
#define JAM_SENSOR_PIN       34  // Mechanical jam detection

void configureGPIO() {
  pinMode(MOTOR_SLOT_1_PIN, OUTPUT);
  pinMode(MOTOR_SLOT_2_PIN, OUTPUT);
  pinMode(MOTOR_SLOT_3_PIN, OUTPUT);
  // ... etc
  
  pinMode(DISPENSE_SENSOR_PIN, INPUT);
  pinMode(JAM_SENSOR_PIN, INPUT);
  
  digitalWrite(MOTOR_SLOT_1_PIN, LOW);  // All motors off initially
  digitalWrite(MOTOR_SLOT_2_PIN, LOW);
  digitalWrite(MOTOR_SLOT_3_PIN, LOW);
}
```

### Step 2: Motor/Solenoid Control Routine

```cpp
bool dispenseSlot(int slotId) {
  // Map slot ID to GPIO pin
  int motorPin = getMotorPin(slotId);
  if (motorPin == -1) return false;  // Invalid slot
  
  const int DISPENSE_TIMEOUT_MS = 5000;
  const int DISPENSE_DURATION_MS = 2000;  // Adjust based on motor speed
  
  unsigned long startTime = millis();
  
  // Check slot is not empty (optional sensor)
  if (isSlotEmpty(slotId)) {
    Serial.printf("Slot %d is empty\n", slotId);
    return false;
  }
  
  // Activate motor
  Serial.printf("Activating motor for slot %d\n", slotId);
  digitalWrite(motorPin, HIGH);
  delay(DISPENSE_DURATION_MS);
  digitalWrite(motorPin, LOW);
  
  // Monitor dispense completion (optical sensor)
  while (millis() - startTime < DISPENSE_TIMEOUT_MS) {
    if (dispenseSensorDetected()) {
      Serial.printf("Item detected from slot %d\n", slotId);
      delay(500);  // Wait for item to fully exit
      return true;
    }
    delay(50);
  }
  
  Serial.printf("Timeout dispensing slot %d\n", slotId);
  return false;
}

int getMotorPin(int slotId) {
  switch (slotId) {
    case 1: return MOTOR_SLOT_1_PIN;
    case 2: return MOTOR_SLOT_2_PIN;
    case 3: return MOTOR_SLOT_3_PIN;
    // ... map all slots
    default: return -1;
  }
}

bool dispenseSensorDetected() {
  // Return true if item detected by optical sensor
  return digitalRead(DISPENSE_SENSOR_PIN) == HIGH;
}

bool isSlotEmpty(int slotId) {
  // Return true if slot is empty (implement based on your sensors)
  // Could use load cell, IR sensor, mechanical switch, etc.
  return false;  // Placeholder
}
```

### Step 3: Main Setup & Loop

```cpp
void setup() {
  Serial.begin(115200);
  delay(1000);
  
  Serial.println("\n========================================");
  Serial.println("Tapon Vending Machine - ESP32 Firmware");
  Serial.println("========================================");
  
  configureGPIO();
  setupBLE();
  
  Serial.println("System ready. Waiting for BLE connection...");
}

void loop() {
  // Main loop handles BLE callbacks automatically
  // Optional: Add periodic status checks, sensor monitoring, etc.
  delay(1000);
  
  // Example: Monitor battery, temperature, connectivity status
  if (BLEDevice::getServer()->getConnectedCount() > 0) {
    Serial.println("✓ BLE Client connected");
  } else {
    Serial.println("✗ Waiting for BLE connection");
  }
}
```

---

## Vending Machine Hardware Integration

### Hardware Components Checklist

- [ ] **Motors/Solenoids:** One per slot or multiplexed control
- [ ] **Sensors:**
  - [ ] Item dispensing sensor (optical, mechanical)
  - [ ] Slot empty sensor
  - [ ] Jam detection
- [ ] **Power Management:**
  - [ ] 12V/24V supply for motors
  - [ ] 3.3V regulated supply for ESP32
  - [ ] Relay module or MOSFET driver for motor control
- [ ] **Feedback:**
  - [ ] LED indicators (optional)
  - [ ] Buzzer for errors (optional)
  - [ ] Mechanical switches for slot validation

### Motor Control Options

#### Option A: Direct GPIO → Relay (Simple)
```
ESP32 GPIO → Relay Module → Motor Power Supply
```
- Pros: Simple, reliable
- Cons: Slower, higher latency
- Use for: Low-speed, infrequent dispensing

#### Option B: PWM → MOSFET Driver (Recommended)
```
ESP32 PWM Pin → MOSFET Driver IC → Motor
```
- Pros: Precise speed control, efficient
- Cons: Requires driver IC
- Use for: Fast dispensing, multiple simultaneous motors

#### Option C: Stepper Motor (Precise)
```
ESP32 → Stepper Driver → Stepper Motor
```
- Pros: Accurate position, no feedback sensor needed
- Cons: More complex control logic
- Use for: Carousel-style multi-slot dispensers

### Example: PWM Motor Control

```cpp
#define PWM_FREQUENCY 1000
#define PWM_RESOLUTION 8
#define PWM_PIN 25

void setupMotorPWM() {
  ledcSetup(0, PWM_FREQUENCY, PWM_RESOLUTION);
  ledcAttachPin(PWM_PIN, 0);
  ledcWrite(0, 0);  // Start stopped
}

void setMotorSpeed(int speed) {  // 0-255
  ledcWrite(0, speed);
  Serial.printf("Motor speed: %d\n", speed);
}

bool dispenseSlot(int slotId) {
  setMotorSpeed(200);      // 80% speed
  delay(2000);             // Run for 2 seconds
  setMotorSpeed(0);        // Stop
  return true;
}
```

---

## Testing & Verification

### Phase 1: BLE Connectivity Test

**Objective:** Verify ESP32 advertises and accepts connections

**Steps:**
1. Flash ESP32 with BLE service code
2. Open Flutter app
3. Go to **"Connect to Machine"** screen
4. Scan for devices
5. Verify `Tapon-Vending` appears in device list
6. Tap to connect
7. **Expected:** Console shows: `✅ DEVICE CONNECTED SUCCESSFULLY`

**Logs to check (app terminal):**
```
🔍 SCANNING FOR BLUETOOTH DEVICES...
📱 Found device: name="Tapon-Vending", id=..., rssi=-45
   ✅ Device added to list
🔗 CONNECTING TO DEVICE: Tapon-Vending
✅ DEVICE CONNECTED SUCCESSFULLY
   Connection Status: true
📡 TX/RX Characteristics configured
```

### Phase 2: Command Reception Test

**Objective:** Verify ESP32 receives commands correctly

**Steps:**
1. Connect app to ESP32 (from Phase 1)
2. Purchase a product (slot 3)
3. Confirm purchase dialog
4. **Expected:** Flutter console shows:
   ```
   🎯 BLUETOOTH TRANSMISSION - SLOT ID
      Slot ID: 3
      Connection Status: ✅ CONNECTED
      Command: "SLOT:3\n"
   📡 SENDING DATA TO DEVICE...
      Data: "SLOT:3\n"
   ✅ DATA SENT SUCCESSFULLY (7 bytes)
   ```
5. **Expected:** ESP32 serial console shows:
   ```
   Received command: SLOT:3
   Dispensing slot: 3
   Activating motor for slot 3
   ```

### Phase 3: Hardware Activation Test

**Objective:** Verify motor/solenoid activates for correct slot

**Steps:**
1. Connect app and ESP32
2. Purchase product from slot 1
   - **Expected:** Motor for slot 1 activates (sound/movement)
3. Purchase product from slot 5
   - **Expected:** Motor for slot 5 activates
4. Purchase multiple slots in sequence
   - **Expected:** Correct motor activates each time

### Phase 4: Sensor Feedback Test

**Objective:** Verify sensors detect item dispensing

**Steps:**
1. Ensure all slots have items
2. Place a test item in front of dispense sensor
3. Purchase product
4. **Expected:** Sensor detects item, `OK:3` sent back to app
5. Remove item, purchase again
   - **Expected:** Timeout or sensor not triggered, `ERR:3` sent back

### Phase 5: Error Handling Test

**Objective:** Verify graceful handling of edge cases

**Test Cases:**
- Invalid slot (e.g., slot 99): → `ERR:FORMAT\n`
- Empty slot: → `EMPTY:1\n`
- Motor jam: → `ERR:1\n` (timeout)
- Rapid purchases: → Queue or reject second command

---

## Troubleshooting

### Issue 1: ESP32 Not Discoverable
**Symptoms:** Device doesn't appear in app's scan list

**Causes & Solutions:**
- [ ] BLE advertising not started
  - Check: `BLEDevice::startAdvertising()` is called
- [ ] Service UUID mismatch
  - Verify UUID: `12345678-1234-5678-1234-56789abcdef0`
- [ ] Bluetooth disabled on phone
  - Enable Bluetooth in phone settings
- [ ] Too far away
  - Bring phone within 10m of ESP32

**Debug:**
```cpp
void setup() {
  setupBLE();
  Serial.println("Advertising: " + String(BLEDevice::getAdvertising()->isAdvertising()));
}
```

### Issue 2: Connection Succeeds but No Commands Received
**Symptoms:** App connects but motor doesn't activate

**Causes & Solutions:**
- [ ] TX Characteristic not writable
  - Check: `PROPERTY_WRITE` or `PROPERTY_WRITE_NR` set
- [ ] Write callback not registered
  - Verify: `setCallbacks(new MyCharacteristicCallback())`
- [ ] Characteristic UUID mismatch
  - Verify UUID: `12345678-1234-5678-1234-56789abcdef1`

**Debug:**
```cpp
void onWrite(BLECharacteristic* pCharacteristic) {
  std::string rxValue = pCharacteristic->getValue();
  Serial.print("onWrite called. Value length: ");
  Serial.println(rxValue.length());
  for (char c : rxValue) {
    Serial.printf("  Byte: 0x%02X (%c)\n", c, isprint(c) ? c : '?');
  }
}
```

### Issue 3: Commands Received but Motor Doesn't Activate
**Symptoms:** Serial shows `Dispensing slot: 3` but motor silent

**Causes & Solutions:**
- [ ] GPIO pin configured wrong
  - Check: `pinMode(pin, OUTPUT)` before use
- [ ] Motor control logic inverted
  - Try: `digitalWrite(pin, LOW)` instead of `HIGH`
- [ ] Power not supplied to motor
  - Verify: 12V/24V supply connected to relay/MOSFET
- [ ] Motor wiring incorrect
  - Test: Manual on/off to confirm polarity

**Debug:**
```cpp
void dispenseSlot(int slotId) {
  Serial.printf("Setting pin %d HIGH\n", motorPin);
  digitalWrite(motorPin, HIGH);
  for (int i = 0; i < 20; i++) {
    Serial.printf("  Pin level: %d\n", digitalRead(motorPin));
    delay(100);
  }
  digitalWrite(motorPin, LOW);
}
```

### Issue 4: Sensor Not Detecting Item
**Symptoms:** Motor runs but sensor returns false

**Causes & Solutions:**
- [ ] Sensor not facing dispense chute correctly
  - Reposition: Point sensor at item exit
- [ ] Sensor threshold too high/low
  - Calibrate: Adjust analog threshold or debounce delay
- [ ] Dirty lens (optical sensor)
  - Clean: Wipe sensor lens with soft cloth
- [ ] Item not passing through zone
  - Verify: Motor rotation is sufficient

**Debug:**
```cpp
void loop() {
  int sensorValue = analogRead(DISPENSE_SENSOR_PIN);
  Serial.printf("Sensor raw: %d (threshold: %d)\n", sensorValue, SENSOR_THRESHOLD);
  delay(500);
}
```

---

## Communication Checklist

Before handing off to integration team:

- [ ] **BLE UUIDs Confirmed:**
  - Service UUID: `12345678-1234-5678-1234-56789abcdef0`
  - TX Characteristic: `12345678-1234-5678-1234-56789abcdef1`
  - RX Characteristic: `12345678-1234-5678-1234-56789abcdef2`
  
- [ ] **Message Format Confirmed:**
  - Command: `SLOT:3\n` (with newline)
  - Encoding: UTF-8 (ASCII compatible)
  - Response: `OK:3\n` or `ERR:3\n`

- [ ] **Hardware Mapping:**
  - Slot 1 → Motor Pin X
  - Slot 2 → Motor Pin Y
  - Slot 3 → Motor Pin Z
  - (All slots mapped)

- [ ] **Testing Complete:**
  - [ ] BLE connectivity verified
  - [ ] Command reception verified
  - [ ] Motor activation verified
  - [ ] Sensor feedback verified
  - [ ] Error cases handled

- [ ] **Documentation Updated:**
  - ESP32 firmware source code uploaded to repository
  - Wiring diagram provided
  - Motor/sensor configuration documented
  - Known issues logged

---

## Contact & Support

**Questions about app behavior?**  
Refer to Flutter logs or check: `lib/bluetooth_service.dart.dart`

**Need to change BLE UUIDs?**  
Update both:
- ESP32: Service & Characteristic UUIDs in firmware
- Flutter app: `lib/bluetooth_service.dart.dart` (lines 20-22)

**Last Updated:** January 27, 2026  


