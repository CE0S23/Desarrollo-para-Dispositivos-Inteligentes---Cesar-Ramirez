import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService {
  // UUIDs acortados exactamente como los lee el chip Bluetooth
  final String serviceUUID = "1111";
  final String tempCharacteristicUUID = "2222";
  
  // ... el resto del código se queda igual ...
  
  // ... el resto de tu código de escaneo y conexión se queda exactamente igual

  // Iniciar el escaneo [cite: 554, 558, 559]
  Stream<List<ScanResult>> scanForDevices() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    return FlutterBluePlus.scanResults;
  }

  // Detener escaneo
  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  // Conectar a un dispositivo [cite: 554, 558, 560]
  Future<void> connect(BluetoothDevice device) async {
    await device.connect(autoConnect: false);
  }

  // Desconectar [cite: 541, 562]
  Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
  }

  // Leer la característica y aplicar validación de seguridad
  Future<int?> readTemperature(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();
      
      print("🔍 AUDITORÍA BLE - Buscando en ${services.length} servicios...");
      
      for (BluetoothService service in services) {
        // Imprime el nombre exacto de la carpeta
        print("📁 Servicio encontrado: ${service.uuid.toString()}");
        
        for (BluetoothCharacteristic c in service.characteristics) {
          // Imprime el nombre exacto de lo que hay adentro
          print("   📄 Característica: ${c.uuid.toString()}");
        }

        // Aquí sigue tu código de validación original
        if (service.uuid.toString().toLowerCase() == serviceUUID.toLowerCase()) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() == tempCharacteristicUUID.toLowerCase()) {
              
              List<int> value = await characteristic.read();
              print("🔧 DIAGNÓSTICO - Bytes recibidos: $value"); 
              
              if (value.isEmpty) return null;

              int? parsedTemp;

              if (value.length == 1) {
                parsedTemp = value[0];
                if (parsedTemp > 127) parsedTemp -= 256; 
              } else {
                try {
                  String stringValue = utf8.decode(value).trim();
                  parsedTemp = int.tryParse(stringValue);
                } catch (e) {
                  print("🚨 No era texto UTF-8.");
                }
              }

              if (parsedTemp != null && parsedTemp >= -60 && parsedTemp <= 60) {
                return parsedTemp;
              } else {
                print("🚨 SEGURIDAD BLE - Dato fuera de rango o corrupto: $parsedTemp");
                return null;
              }
            }
          }
        }
      }
    } catch (e) {
      print("🚨 ERROR BLE: $e");
    }
    return null;
  }
}