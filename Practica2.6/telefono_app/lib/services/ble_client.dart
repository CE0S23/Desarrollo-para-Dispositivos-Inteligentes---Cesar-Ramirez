import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/activity_data.dart';
import '../ble_constants.dart';

class BleClient {
  BluetoothDevice? _device;
  final List<StreamSubscription> _subs = [];
  final _dataCtrl = StreamController<ActivityData>.broadcast();
  bool _connected = false;

  ActivityData _current = ActivityData(
    steps: 0,
    heartRate: 0,
    calories: 0,
    status: 'sin datos',
    timestamp: DateTime.now(),
  );

  Stream<ActivityData> get dataStream => _dataCtrl.stream;
  bool get isConnected => _connected;

  Future<void> scanAndConnect() async {
    final completer = Completer<BluetoothDevice>();

    final scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        final uuids = r.advertisementData.serviceUuids.map((e) => e.toString().toLowerCase());
        if (uuids.contains(BleConstants.serviceUUID.toLowerCase())) {
          if (!completer.isCompleted) {
            completer.complete(r.device);
          }
        }
      }
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      _device = await completer.future.timeout(const Duration(seconds: 16));
      await _connect();
    } on TimeoutException {
      throw Exception('Wearable no encontrado en 15 segundos');
    } finally {
      await FlutterBluePlus.stopScan();
      await scanSub.cancel();
    }
  }

  Future<void> _connect() async {
    if (_device == null) return;

    await _device!.connect();
    _connected = true;

    final stateSub = _device!.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _connected = false;
      }
    });
    _subs.add(stateSub);

    await _discoverAndSubscribe();
  }

  Future<void> _discoverAndSubscribe() async {
    if (_device == null) return;
    
    final services = await _device!.discoverServices();
    
    for (BluetoothService service in services) {
      if (service.uuid.toString().toLowerCase() == BleConstants.serviceUUID.toLowerCase()) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            final sub = characteristic.lastValueStream.listen((bytes) {
              _handleValue(characteristic.uuid.toString().toLowerCase(), bytes);
            });
            _subs.add(sub);
          }
        }
      }
    }
  }

  void _handleValue(String uuid, List<int> bytes) {
    if (bytes.isEmpty) return;

    try {
      if (uuid == BleConstants.stepsUUID.toLowerCase()) {
        final val = ByteData.sublistView(Uint8List.fromList(bytes)).getInt32(0, Endian.little);
        _current = _current.copyWith(steps: val);
      } else if (uuid == BleConstants.heartRateUUID.toLowerCase()) {
        final val = bytes[0];
        _current = _current.copyWith(heartRate: val);
      } else if (uuid == BleConstants.caloriesUUID.toLowerCase()) {
        final val = ByteData.sublistView(Uint8List.fromList(bytes)).getInt16(0, Endian.little);
        _current = _current.copyWith(calories: val);
      } else if (uuid == BleConstants.statusUUID.toLowerCase()) {
        final val = utf8.decode(bytes);
        _current = _current.copyWith(status: val);
      }
      _dataCtrl.add(_current);
    } catch (e) {
      // ignore: avoid_print
      print('Error al parsear bytes: $e');
    }
  }

  Future<void> disconnect() async {
    for (var sub in _subs) {
      await sub.cancel();
    }
    _subs.clear();
    await _device?.disconnect();
    _connected = false;
  }

  void dispose() {
    _dataCtrl.close();
  }
}
