import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ble_peripheral/ble_peripheral.dart';
import 'sensor_simulator.dart';
import 'ble_constants.dart';

class BleServer {
  final SensorSimulator simulator;
  bool _advertising = false;
  
  StreamSubscription? _stepsSub;
  StreamSubscription? _heartRateSub;
  StreamSubscription? _caloriesSub;
  StreamSubscription? _statusSub;

  BleServer(this.simulator);

  bool get isAdvertising => _advertising;

  Uint8List _intToBytes(int value) {
    final byteData = ByteData(4);
    byteData.setInt32(0, value, Endian.little);
    return byteData.buffer.asUint8List();
  }

  Uint8List _int16ToBytes(int value) {
    final byteData = ByteData(2);
    byteData.setInt16(0, value, Endian.little);
    return byteData.buffer.asUint8List();
  }

  void startAdvertising() async {
    try {
      await BlePeripheral.initialize();
      await BlePeripheral.clearServices();
      
      final service = BleService(
        uuid: BleConstants.serviceUUID,
        primary: true,
        characteristics: [
          BleCharacteristic(
            uuid: BleConstants.stepsUUID,
            properties: [
              CharacteristicProperties.read.index,
              CharacteristicProperties.notify.index
            ],
            permissions: [AttributePermissions.readable.index],
            value: null,
          ),
          BleCharacteristic(
            uuid: BleConstants.heartRateUUID,
            properties: [
              CharacteristicProperties.read.index,
              CharacteristicProperties.notify.index
            ],
            permissions: [AttributePermissions.readable.index],
            value: null,
          ),
          BleCharacteristic(
            uuid: BleConstants.caloriesUUID,
            properties: [
              CharacteristicProperties.read.index,
              CharacteristicProperties.notify.index
            ],
            permissions: [AttributePermissions.readable.index],
            value: null,
          ),
          BleCharacteristic(
            uuid: BleConstants.statusUUID,
            properties: [
              CharacteristicProperties.read.index,
              CharacteristicProperties.notify.index
            ],
            permissions: [AttributePermissions.readable.index],
            value: null,
          ),
        ],
      );

      await BlePeripheral.addService(service);
      
      await BlePeripheral.startAdvertising(
        services: [BleConstants.serviceUUID],
        localName: 'WearableApp',
      );
      
      _advertising = true;

      _stepsSub = simulator.stepsStream.listen((steps) async {
        if (_advertising) {
          try {
            await BlePeripheral.updateCharacteristic(
              characteristicId: BleConstants.stepsUUID,
              value: _intToBytes(steps),
            );
          } catch (e) {
            debugPrint("Error updating steps: $e");
          }
        }
      });

      _heartRateSub = simulator.heartRateStream.listen((bpm) async {
        if (_advertising) {
          try {
            await BlePeripheral.updateCharacteristic(
              characteristicId: BleConstants.heartRateUUID,
              value: Uint8List.fromList([bpm]),
            );
          } catch (e) {
            debugPrint("Error updating heart rate: $e");
          }
        }
      });

      _caloriesSub = simulator.caloriesStream.listen((cal) async {
        if (_advertising) {
          try {
            await BlePeripheral.updateCharacteristic(
              characteristicId: BleConstants.caloriesUUID,
              value: _int16ToBytes(cal.toInt()),
            );
          } catch (e) {
            debugPrint("Error updating calories: $e");
          }
        }
      });

      _statusSub = simulator.statusStream.listen((status) async {
        if (_advertising) {
          try {
            await BlePeripheral.updateCharacteristic(
              characteristicId: BleConstants.statusUUID,
              value: Uint8List.fromList(utf8.encode(status)),
            );
          } catch (e) {
            debugPrint("Error updating status: $e");
          }
        }
      });
      
    } catch (e) {
      debugPrint("Failed to start advertising: $e");
    }
  }

  void stop() async {
    _advertising = false;
    _stepsSub?.cancel();
    _heartRateSub?.cancel();
    _caloriesSub?.cancel();
    _statusSub?.cancel();
    
    try {
      await BlePeripheral.stopAdvertising();
    } catch (e) {
      debugPrint("Failed to stop advertising: $e");
    }
    
    simulator.stop();
  }
}
