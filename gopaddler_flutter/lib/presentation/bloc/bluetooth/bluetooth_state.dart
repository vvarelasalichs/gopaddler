part of 'bluetooth_bloc.dart';

abstract class BluetoothState extends Equatable {
  const BluetoothState();

  @override
  List<Object?> get props => [];
}

class BluetoothInitial extends BluetoothState {
  const BluetoothInitial();
}

class BluetoothPermissionRequesting extends BluetoothState {
  const BluetoothPermissionRequesting();
}

class BluetoothPermissionDenied extends BluetoothState {
  final String reason;

  const BluetoothPermissionDenied(this.reason);

  @override
  List<Object?> get props => [reason];
}

class BluetoothPermissionGranted extends BluetoothState {
  const BluetoothPermissionGranted();
}

class BluetoothScanning extends BluetoothState {
  final List<DiscoveredDevice> discoveries;

  const BluetoothScanning(this.discoveries);

  @override
  List<Object?> get props => [discoveries];

  BluetoothScanning copyWith({List<DiscoveredDevice>? discoveries}) {
    return BluetoothScanning(discoveries ?? this.discoveries);
  }
}

class BluetoothConnecting extends BluetoothState {
  final String deviceId;

  const BluetoothConnecting(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class BluetoothConnected extends BluetoothState {
  final List<flutter_blue_plus.BluetoothDevice> connectedDevices;
  final int? lastHeartRate;
  final int? lastCadence;

  const BluetoothConnected({
    required this.connectedDevices,
    this.lastHeartRate,
    this.lastCadence,
  });

  @override
  List<Object?> get props => [connectedDevices, lastHeartRate, lastCadence];

  BluetoothConnected copyWith({
    List<flutter_blue_plus.BluetoothDevice>? connectedDevices,
    int? lastHeartRate,
    int? lastCadence,
  }) {
    return BluetoothConnected(
      connectedDevices: connectedDevices ?? this.connectedDevices,
      lastHeartRate: lastHeartRate ?? this.lastHeartRate,
      lastCadence: lastCadence ?? this.lastCadence,
    );
  }
}

class BluetoothDisconnected extends BluetoothState {
  const BluetoothDisconnected();
}

class BluetoothError extends BluetoothState {
  final String message;

  const BluetoothError(this.message);

  @override
  List<Object?> get props => [message];
}
