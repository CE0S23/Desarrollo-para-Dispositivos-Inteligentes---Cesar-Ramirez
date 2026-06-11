import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/weather_model.dart';
import '../utils/weather_utils.dart';
import '../services/ble_service.dart'; // Importa el nuevo servicio

class WeatherProvider extends ChangeNotifier {
  Weather? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  int _tempUnit = 0; 
  
  // Variables BLE [cite: 541]
  final BLEService _bleService = BLEService();
  BluetoothDevice? _connectedDevice;
  bool _isBleConnected = false;

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get temperatureUnit => _tempUnit == 0 ? '°C' : '°F';
  bool get isBleConnected => _isBleConnected; // Getter para la UI
  BLEService get bleService => _bleService;

  String get displayTemperature {
    if (_weather == null) return '--';
    if (_tempUnit == 0) return '${_weather!.temperature}';
    return WeatherUtils.celsiusToFahrenheit(_weather!.temperature).toStringAsFixed(1);
  }

  // Carga inicial normal
  Future<void> loadWeather(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1)); 
      _weather = Weather(city: city, temperature: 24, condition: 'cloudy', humidity: 65);
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleTemperatureUnit() {
    _tempUnit = _tempUnit == 0 ? 1 : 0;
    notifyListeners();
  }

  // --- NUEVA LÓGICA BLE --- 

  Future<void> connectToWearable(BluetoothDevice device) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _bleService.connect(device); // 
      _connectedDevice = device;
      _isBleConnected = true;
      _bleService.stopScan();

      // Escuchar si se desconecta de repente [cite: 541, 562]
      device.connectionState.listen((BluetoothConnectionState state) {
        if (state == BluetoothConnectionState.disconnected) {
          _isBleConnected = false;
          _connectedDevice = null;
          _errorMessage = "Sin conexión BLE"; // 
          notifyListeners();
        }
      });

      // Leer la temperatura 
      int? newTemp = await _bleService.readTemperature(device);
      if (newTemp != null && _weather != null) {
        _weather = Weather(
          city: "Wearable Data",
          temperature: newTemp,
          condition: 'sunny',
          humidity: _weather!.humidity,
        );
      } else {
        _errorMessage = "No se pudo leer el wearable";
      }

    } catch (e) {
      _errorMessage = 'Error conectando BLE: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> disconnectWearable() async {
    if (_connectedDevice != null) {
      await _bleService.disconnect(_connectedDevice!); // [cite: 562]
    }
  }
}