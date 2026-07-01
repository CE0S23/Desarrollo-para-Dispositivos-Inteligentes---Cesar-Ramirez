import 'dart:async';
import 'dart:math';

class SensorSimulator {
  int _steps = 0;
  int _heartRate = 72;
  double _calories = 0.0;
  String _status = 'reposo';

  final _stepsCtrl = StreamController<int>.broadcast();
  final _heartRateCtrl = StreamController<int>.broadcast();
  final _caloriesCtrl = StreamController<double>.broadcast();
  final _statusCtrl = StreamController<String>.broadcast();

  int get steps => _steps;
  int get heartRate => _heartRate;
  int get calories => _calories.toInt();
  String get status => _status;

  Stream<int> get stepsStream => _stepsCtrl.stream;
  Stream<int> get heartRateStream => _heartRateCtrl.stream;
  Stream<double> get caloriesStream => _caloriesCtrl.stream;
  Stream<String> get statusStream => _statusCtrl.stream;

  Timer? _timer;
  int _ticks = 0;
  final Random _random = Random();

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _update();
    });
  }

  void _update() {
    _ticks++;
    if (_ticks % 30 == 0) {
      const statuses = ['reposo', 'caminando', 'corriendo'];
      _status = statuses[_random.nextInt(statuses.length)];
    }

    if (_status == 'caminando') {
      _steps += _random.nextInt(2) + 1;
    } else if (_status == 'corriendo') {
      _steps += _random.nextInt(4) + 3;
    }

    int targetHr = 72;
    if (_status == 'caminando') targetHr = 95;
    if (_status == 'corriendo') targetHr = 145;

    _heartRate += _random.nextInt(7) - 3;
    if (_heartRate < targetHr - 10) _heartRate = targetHr - 10;
    if (_heartRate > targetHr + 10) _heartRate = targetHr + 10;

    _calories += _steps * 0.00004;

    _stepsCtrl.add(_steps);
    _heartRateCtrl.add(_heartRate);
    _caloriesCtrl.add(_calories);
    _statusCtrl.add(_status);
  }

  void stop() {
    _timer?.cancel();
    _stepsCtrl.close();
    _heartRateCtrl.close();
    _caloriesCtrl.close();
    _statusCtrl.close();
  }
}
