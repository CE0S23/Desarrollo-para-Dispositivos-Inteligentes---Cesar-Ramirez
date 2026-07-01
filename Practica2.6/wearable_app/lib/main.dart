import 'package:flutter/material.dart';
import 'sensor_simulator.dart';
import 'ble_server.dart';

void main() {
  runApp(const WearableApp());
}

class WearableApp extends StatefulWidget {
  const WearableApp({super.key});

  @override
  State<WearableApp> createState() => _WearableAppState();
}

class _WearableAppState extends State<WearableApp> {
  late SensorSimulator _sim;
  late BleServer _server;

  int _steps = 0;
  int _heartRate = 72;
  double _calories = 0.0;
  String _status = 'reposo';
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _sim = SensorSimulator();
    _server = BleServer(_sim);

    _sim.stepsStream.listen((val) => setState(() => _steps = val));
    _sim.heartRateStream.listen((val) => setState(() => _heartRate = val));
    _sim.caloriesStream.listen((val) => setState(() => _calories = val));
    _sim.statusStream.listen((val) => setState(() => _status = val));
  }

  void _toggleActivity() {
    if (!_active) {
      _sim.start();
      _server.startAdvertising();
      setState(() {
        _active = true;
      });
    } else {
      _server.stop();
      setState(() {
        _active = false;
      });
    }
  }

  @override
  void dispose() {
    _server.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_heartRate',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _heartRate > 120 ? Colors.red : Colors.white,
                ),
              ),
              const Text(
                'bpm',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '$_steps pasos',
                style: const TextStyle(fontSize: 16, color: Colors.green),
              ),
              Text(
                '${_calories.toStringAsFixed(2)} kcal',
                style: const TextStyle(fontSize: 14, color: Colors.amber),
              ),
              Text(
                _status,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _active ? Colors.red : Colors.green,
                  minimumSize: const Size(100, 36),
                ),
                onPressed: _toggleActivity,
                child: Text(
                  _active ? 'Detener' : 'Iniciar',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if (_active)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Enviando datos...',
                    style: TextStyle(fontSize: 11, color: Colors.blue),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
