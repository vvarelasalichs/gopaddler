import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../utils/app_logger.dart';

/// Dispositivo Bluetooth descubierto con información aditional
class DiscoveredDevice {
  final BluetoothDevice device;
  final int rssi;
  final List<int> advertisementData;

  DiscoveredDevice({
    required this.device,
    required this.rssi,
    required this.advertisementData,
  });

  String get name => device.name.isNotEmpty ? device.name : 'Unknown';
}

/// Servicio de Bluetooth que maneja conexión y suscripción a sensores
class BluetoothService {
  static const String _tag = 'BluetoothService';

  static const String _heartRateServiceUuid =
      '0000180d-0000-1000-8000-00805f9b34fb';
  static const String _heartRateCharacteristicUuid =
      '00002a37-0000-1000-8000-00805f9b34fb';

  static const String _cyclingSpeedCadenceServiceUuid =
      '00001816-0000-1000-8000-00805f9b34fb';
  static const String _cyclingSpeedCadenceCharacteristicUuid =
      '00002a5b-0000-1000-8000-00805f9b34fb';

  final Map<String, BluetoothDevice> _connectedDevices = {};
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  final StreamController<DiscoveredDevice> _discoveredDevicesController =
      StreamController<DiscoveredDevice>.broadcast();
  final StreamController<int> _heartRateController =
      StreamController<int>.broadcast();
  final StreamController<int> _cadenceController =
      StreamController<int>.broadcast();

  StreamSubscription<List<int>>? _heartRateSubscription;
  StreamSubscription<List<int>>? _cadenceSubscription;

  /// Solicita permisos de Bluetooth
  Future<bool> requestPermissions() async {
    try {
      AppLogger.info('Solicitando permisos de Bluetooth', tag: _tag);

      bool isAdapterOn = await FlutterBluePlus.isSupported;
      if (!isAdapterOn) {
        AppLogger.warning('Bluetooth no soportado en este dispositivo',
            tag: _tag);
        return false;
      }

      // Android 12+ requiere permisos específicos de BLE
      // En Flutter, estos se manejan a través de flutter_blue_plus
      return true;
    } catch (e) {
      AppLogger.error('Error solicitando permisos de Bluetooth',
          tag: _tag, exception: e);
      return false;
    }
  }

  /// Inicia escaneo de dispositivos Bluetooth
  Stream<DiscoveredDevice> startScan(
      {Duration duration = const Duration(seconds: 10)}) {
    try {
      AppLogger.info('Iniciando escaneo de Bluetooth', tag: _tag);

      FlutterBluePlus.startScan(
        timeout: duration,
        removeIfGone: const Duration(seconds: 5),
      );

      _scanSubscription = FlutterBluePlus.onScanResults.listen(
        (results) {
          for (ScanResult r in results) {
            final device = DiscoveredDevice(
              device: r.device,
              rssi: r.rssi,
              advertisementData: [],
            );
            _discoveredDevicesController.add(device);
          }
        },
        onError: (error) {
          AppLogger.error('Error en escaneo Bluetooth',
              tag: _tag, exception: error);
          _discoveredDevicesController.addError(error);
        },
      );

      return _discoveredDevicesController.stream;
    } catch (e) {
      AppLogger.error('Error iniciando escaneo', tag: _tag, exception: e);
      rethrow;
    }
  }

  /// Detiene el escaneo de Bluetooth
  Future<void> stopScan() async {
    try {
      AppLogger.info('Deteniendo escaneo de Bluetooth', tag: _tag);
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;
    } catch (e) {
      AppLogger.error('Error deteniendo escaneo', tag: _tag, exception: e);
      rethrow;
    }
  }

  /// Conecta a un dispositivo Bluetooth
  /// [type] puede ser 'heart_rate' o 'cadence'
  Future<void> connectDevice(String deviceId, String type) async {
    try {
      AppLogger.info('Conectando a dispositivo: $deviceId', tag: _tag);

      final device = BluetoothDevice(
        remoteId: DeviceIdentifier(deviceId),
      );

      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevices[deviceId] = device;

      AppLogger.info('Dispositivo conectado: $deviceId', tag: _tag);

      // Suscribir a características según el tipo
      if (type == 'heart_rate') {
        await _subscribeToHeartRate(device);
      } else if (type == 'cadence') {
        await _subscribeToCadence(device);
      }
    } catch (e) {
      AppLogger.error('Error conectando a dispositivo',
          tag: _tag, exception: e);
      rethrow;
    }
  }

  /// Desconecta de un dispositivo Bluetooth
  Future<void> disconnectDevice(String deviceId) async {
    try {
      AppLogger.info('Desconectando de dispositivo: $deviceId', tag: _tag);

      final device = _connectedDevices[deviceId];
      if (device != null) {
        await device.disconnect();
        _connectedDevices.remove(deviceId);
      }

      AppLogger.info('Dispositivo desconectado: $deviceId', tag: _tag);
    } catch (e) {
      AppLogger.error('Error desconectando de dispositivo',
          tag: _tag, exception: e);
      rethrow;
    }
  }

  /// Obtiene lista de dispositivos conectados
  List<BluetoothDevice> getConnectedDevices() {
    return _connectedDevices.values.toList();
  }

  /// Stream de lecturas de frecuencia cardíaca (bpm)
  Stream<int> subscribeToHeartRate() {
    return _heartRateController.stream;
  }

  /// Stream de lecturas de cadencia (rpm)
  Stream<int> subscribeToCadence() {
    return _cadenceController.stream;
  }

  /// Suscribe a características de frecuencia cardíaca
  Future<void> _subscribeToHeartRate(BluetoothDevice device) async {
    try {
      AppLogger.info('Suscribiendo a características de FC', tag: _tag);

      final services = await device.discoverServices();

      for (var service in services) {
        if (service.uuid.toString() == _heartRateServiceUuid) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() ==
                _heartRateCharacteristicUuid) {
              await characteristic.setNotifyValue(true);

              _heartRateSubscription?.cancel();
              _heartRateSubscription =
                  characteristic.onValueReceived.listen((value) {
                if (value.isNotEmpty) {
                  final bpm = value[1]; // El byte 1 es el BPM
                  _heartRateController.add(bpm);
                  AppLogger.debug('FC recibido: $bpm bpm', tag: _tag);
                }
              });
            }
          }
        }
      }
    } catch (e) {
      AppLogger.error('Error suscribiendo a FC', tag: _tag, exception: e);
      rethrow;
    }
  }

  /// Suscribe a características de cadencia
  Future<void> _subscribeToCadence(BluetoothDevice device) async {
    try {
      AppLogger.info('Suscribiendo a características de cadencia', tag: _tag);

      final services = await device.discoverServices();

      for (var service in services) {
        if (service.uuid.toString() == _cyclingSpeedCadenceServiceUuid) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() ==
                _cyclingSpeedCadenceCharacteristicUuid) {
              await characteristic.setNotifyValue(true);

              _cadenceSubscription?.cancel();
              _cadenceSubscription =
                  characteristic.onValueReceived.listen((value) {
                if (value.length >= 4) {
                  // Bytes 2-3 contienen RPM
                  final rpm = (value[3] << 8) | value[2];
                  _cadenceController.add(rpm);
                  AppLogger.debug('Cadencia recibida: $rpm rpm', tag: _tag);
                }
              });
            }
          }
        }
      }
    } catch (e) {
      AppLogger.error('Error suscribiendo a cadencia', tag: _tag, exception: e);
      rethrow;
    }
  }

  /// Cierra todos los streams y desconecta dispositivos
  Future<void> dispose() async {
    try {
      AppLogger.info('Cerrando BluetoothService', tag: _tag);

      await _scanSubscription?.cancel();
      await _heartRateSubscription?.cancel();
      await _cadenceSubscription?.cancel();

      for (final device in _connectedDevices.values) {
        try {
          await device.disconnect();
        } catch (e) {
          AppLogger.warning('Error desconectando dispositivo al cerrar',
              tag: _tag);
        }
      }

      _connectedDevices.clear();
      await _discoveredDevicesController.close();
      await _heartRateController.close();
      await _cadenceController.close();
    } catch (e) {
      AppLogger.error('Error cerrando BluetoothService',
          tag: _tag, exception: e);
    }
  }
}
