import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as flutter_blue_plus;
import '../../../data/services/bluetooth_service.dart';
import '../../../utils/app_logger.dart';

part 'bluetooth_event.dart';
part 'bluetooth_state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  final BluetoothService _bluetoothService;
  StreamSubscription<DiscoveredDevice>? _deviceDiscoverySubscription;
  StreamSubscription<int>? _heartRateSubscription;
  StreamSubscription<int>? _cadenceSubscription;
  final List<DiscoveredDevice> _discoveredDevices = [];

  BluetoothBloc({required BluetoothService bluetoothService})
      : _bluetoothService = bluetoothService,
        super(const BluetoothInitial()) {
    on<RequestBluetoothPermissionsEvent>(_onRequestPermissions);
    on<StartBluetoothScanEvent>(_onStartScan);
    on<StopBluetoothScanEvent>(_onStopScan);
    on<ConnectDeviceEvent>(_onConnectDevice);
    on<DisconnectDeviceEvent>(_onDisconnectDevice);
    on<BluetoothDeviceFoundEvent>(_onDeviceFound);
    on<HeartRateReceivedEvent>(_onHeartRateReceived);
    on<CadenceReceivedEvent>(_onCadenceReceived);
    on<BluetoothErrorEvent>(_onBluetoothError);
  }

  /// Maneja solicitud de permisos de Bluetooth
  Future<void> _onRequestPermissions(
    RequestBluetoothPermissionsEvent event,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      emit(const BluetoothPermissionRequesting());

      AppLogger.info('Solicitando permisos de Bluetooth', tag: 'BluetoothBloc');
      final granted = await _bluetoothService.requestPermissions();

      if (granted) {
        emit(const BluetoothPermissionGranted());
        AppLogger.info('Permisos de Bluetooth otorgados', tag: 'BluetoothBloc');
      } else {
        emit(const BluetoothPermissionDenied(
            'Permisos de Bluetooth denegados por el usuario'));
        AppLogger.warning('Permisos de Bluetooth denegados',
            tag: 'BluetoothBloc');
      }
    } catch (e) {
      AppLogger.error('Error solicitando permisos de Bluetooth',
          tag: 'BluetoothBloc', exception: e);
      emit(BluetoothError('Error solicitando permisos: $e'));
    }
  }

  /// Maneja inicio de escaneo de dispositivos
  Future<void> _onStartScan(
    StartBluetoothScanEvent event,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      emit(const BluetoothScanning([]));
      _discoveredDevices.clear();

      AppLogger.info('Iniciando escaneo de Bluetooth', tag: 'BluetoothBloc');

      _deviceDiscoverySubscription =
          _bluetoothService.startScan(duration: event.duration).listen(
        (DiscoveredDevice device) {
          // Evitar duplicados
          if (!_discoveredDevices
              .any((d) => d.device.remoteId == device.device.remoteId)) {
            _discoveredDevices.add(device);
          }

          add(BluetoothDeviceFoundEvent(device));
        },
        onError: (error) {
          AppLogger.error('Error en escaneo de Bluetooth',
              tag: 'BluetoothBloc', exception: error);
          add(BluetoothErrorEvent('Error en escaneo: $error'));
        },
        onDone: () {
          AppLogger.info('Escaneo de Bluetooth completado',
              tag: 'BluetoothBloc');
        },
      );
    } catch (e) {
      AppLogger.error('Error iniciando escaneo',
          tag: 'BluetoothBloc', exception: e);
      emit(BluetoothError('Error iniciando escaneo: $e'));
    }
  }

  /// Maneja parada del escaneo
  Future<void> _onStopScan(
    StopBluetoothScanEvent event,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      AppLogger.info('Deteniendo escaneo de Bluetooth', tag: 'BluetoothBloc');

      await _bluetoothService.stopScan();
      await _deviceDiscoverySubscription?.cancel();
      _deviceDiscoverySubscription = null;

      emit(BluetoothDisconnected());
    } catch (e) {
      AppLogger.error('Error deteniendo escaneo',
          tag: 'BluetoothBloc', exception: e);
      emit(BluetoothError('Error deteniendo escaneo: $e'));
    }
  }

  /// Maneja conexión a un dispositivo
  Future<void> _onConnectDevice(
    ConnectDeviceEvent event,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      emit(BluetoothConnecting(event.deviceId));

      AppLogger.info('Conectando a dispositivo: ${event.deviceId}',
          tag: 'BluetoothBloc');

      await _bluetoothService.connectDevice(event.deviceId, event.type);

      // Suscribirse a streams según el tipo
      if (event.type == 'heart_rate') {
        _heartRateSubscription?.cancel();
        _heartRateSubscription =
            _bluetoothService.subscribeToHeartRate().listen(
          (bpm) {
            add(HeartRateReceivedEvent(bpm));
          },
          onError: (error) {
            AppLogger.error('Error en stream de FC',
                tag: 'BluetoothBloc', exception: error);
            add(BluetoothErrorEvent('Error en FC: $error'));
          },
        );
      } else if (event.type == 'cadence') {
        _cadenceSubscription?.cancel();
        _cadenceSubscription = _bluetoothService.subscribeToCadence().listen(
          (rpm) {
            add(CadenceReceivedEvent(rpm));
          },
          onError: (error) {
            AppLogger.error('Error en stream de cadencia',
                tag: 'BluetoothBloc', exception: error);
            add(BluetoothErrorEvent('Error en cadencia: $error'));
          },
        );
      }

      final connectedDevices = _bluetoothService.getConnectedDevices();

      if (state is BluetoothConnected) {
        final currentState = state as BluetoothConnected;
        emit(currentState.copyWith(connectedDevices: connectedDevices));
      } else {
        emit(BluetoothConnected(connectedDevices: connectedDevices));
      }

      AppLogger.info('Dispositivo conectado exitosamente',
          tag: 'BluetoothBloc');
    } catch (e) {
      AppLogger.error('Error conectando a dispositivo',
          tag: 'BluetoothBloc', exception: e);
      emit(BluetoothError('Error conectando: $e'));
    }
  }

  /// Maneja desconexión de dispositivo
  Future<void> _onDisconnectDevice(
    DisconnectDeviceEvent event,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      AppLogger.info('Desconectando dispositivo: ${event.deviceId}',
          tag: 'BluetoothBloc');

      await _bluetoothService.disconnectDevice(event.deviceId);
      final connectedDevices = _bluetoothService.getConnectedDevices();

      if (connectedDevices.isEmpty) {
        emit(const BluetoothDisconnected());
      } else {
        emit(BluetoothConnected(connectedDevices: connectedDevices));
      }

      AppLogger.info('Dispositivo desconectado', tag: 'BluetoothBloc');
    } catch (e) {
      AppLogger.error('Error desconectando dispositivo',
          tag: 'BluetoothBloc', exception: e);
      emit(BluetoothError('Error desconectando: $e'));
    }
  }

  /// Maneja descubrimiento de dispositivo
  Future<void> _onDeviceFound(
    BluetoothDeviceFoundEvent event,
    Emitter<BluetoothState> emit,
  ) async {
    if (state is BluetoothScanning) {
      final currentState = state as BluetoothScanning;
      emit(BluetoothScanning(List.from(_discoveredDevices)));
    }
  }

  /// Maneja recepción de FC
  Future<void> _onHeartRateReceived(
    HeartRateReceivedEvent event,
    Emitter<BluetoothState> emit,
  ) async {
    if (state is BluetoothConnected) {
      final currentState = state as BluetoothConnected;
      emit(currentState.copyWith(lastHeartRate: event.bpm));
      AppLogger.debug('FC actualizado: ${event.bpm} bpm', tag: 'BluetoothBloc');
    }
  }

  /// Maneja recepción de cadencia
  Future<void> _onCadenceReceived(
    CadenceReceivedEvent event,
    Emitter<BluetoothState> emit,
  ) async {
    if (state is BluetoothConnected) {
      final currentState = state as BluetoothConnected;
      emit(currentState.copyWith(lastCadence: event.rpm));
      AppLogger.debug('Cadencia actualizada: ${event.rpm} rpm',
          tag: 'BluetoothBloc');
    }
  }

  /// Maneja errores de Bluetooth
  Future<void> _onBluetoothError(
    BluetoothErrorEvent event,
    Emitter<BluetoothState> emit,
  ) async {
    AppLogger.error('Error de Bluetooth: ${event.message}',
        tag: 'BluetoothBloc');
    emit(BluetoothError(event.message));
  }

  @override
  Future<void> close() async {
    await _deviceDiscoverySubscription?.cancel();
    await _heartRateSubscription?.cancel();
    await _cadenceSubscription?.cancel();
    await _bluetoothService.dispose();
    return super.close();
  }
}
