import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/weather_utils.dart';

class WeatherProvider extends ChangeNotifier {
  Weather? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  int _tempUnit = 0; // 0 = Celsius, 1 = Fahrenheit

  // Getters
  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get temperatureUnit => _tempUnit == 0 ? '°C' : '°F';

  // Getter dinámico para la temperatura convertida
  String get displayTemperature {
    if (_weather == null) return '--';
    if (_tempUnit == 0) {
      return '${_weather!.temperature}';
    } else {
      double fTemp = WeatherUtils.celsiusToFahrenheit(_weather!.temperature);
      return fTemp.toStringAsFixed(1); // Muestra 1 decimal
    }
  }

  Future<void> loadWeather(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simula red
      _weather = Weather(
        city: city,
        temperature: 24, // Temperatura base en Celsius
        condition: 'cloudy',
        humidity: 65,
      );
    } catch (e) {
      _errorMessage = 'Error loading weather: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleTemperatureUnit() {
    _tempUnit = _tempUnit == 0 ? 1 : 0;
    notifyListeners();
  }
}