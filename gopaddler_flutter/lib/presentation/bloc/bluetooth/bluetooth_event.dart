part of 'bluetooth_bloc.dart';

abstract class BluetoothEvent extends Equatable {
  const BluetoothEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para solicitar permisos de Bluetooth
class RequestBluetoothPermissionsEvent extends BluetoothEvent {
  const RequestBluetoothPermissionsEvent();
}

/// Evento para iniciar escaneo de dispositivos
class StartBluetoothScanEvent extends BluetoothEvent {
  final Duration duration;

  const StartBluetoothScanEvent({this.duration = const Duration(seconds: 10)});

  @override
  List<Object?> get props => [duration];
}

/// Evento para detener escaneo de dispositivos
class StopBluetoothScanEvent extends BluetoothEvent {
  const StopBluetoothScanEvent();
}

/// Evento para conectar a un dispositivo
class ConnectDeviceEvent extends BluetoothEvent {
  final String deviceId;
  final String type; // 'heart_rate' or 'cadence'

  const ConnectDeviceEvent({required this.deviceId, required this.type});

  @override
  List<Object?> get props => [deviceId, type];
}

/// Evento para desconectar de un dispositivo
class DisconnectDeviceEvent extends BluetoothEvent {
  final String deviceId;

  const DisconnectDeviceEvent(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

/// Evento interno cuando se descubre un dispositivo
class BluetoothDeviceFoundEvent extends BluetoothEvent {
  final DiscoveredDevice device;

  const BluetoothDeviceFoundEvent(this.device);

  @override
  List<Object?> get props => [device.device.remoteId];
}

/// Evento interno cuando se recibe una lectura de FC
class HeartRateReceivedEvent extends BluetoothEvent {
  final int bpm;

  const HeartRateReceivedEvent(this.bpm);

  @override
  List<Object?> get props => [bpm];
}

/// Evento interno cuando se recibe una lectura de cadencia
class CadenceReceivedEvent extends BluetoothEvent {
  final int rpm;

  const CadenceReceivedEvent(this.rpm);

  @override
  List<Object?> get props => [rpm];
}

/// Evento para error en Bluetooth
class BluetoothErrorEvent extends BluetoothEvent {
  final String message;

  const BluetoothErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}
