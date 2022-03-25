import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/Device.dart';

part 'enter_event.dart';
part 'enter_state.dart';

class EnterBloc extends Bloc<EnterEvent, EnterState> {
  EnterBloc() : super(EnterState()) {
    on<EnterNetworkChanged>(_onNetworkStatusChanged);
    on<EnterFindMobile>(_onFindMobile);
    on<EnterClearFindMobiles>(_onClearFindMobiles);
  }

  void _onNetworkStatusChanged(
      EnterNetworkChanged event,
      Emitter<EnterState> emit) {
    log("_onNetworkStatusChanged");

    emit(state.copyWith(
      isNetworkConnected: event.isConnected,
      networkName: event.networkName,
      networkType: event.networkType
    ));
  }

  void _onFindMobile(
      EnterFindMobile event,
      Emitter<EnterState> emit) {
    Device device = event.device;

    List<Device> devices = [...state.devices];
    if (!devices.contains(device)) {
      devices.add(device);

      emit(state.copyWith(
          devices: devices
      ));
    }
  }

  void _onClearFindMobiles(
      EnterClearFindMobiles event,
      Emitter<EnterState> emit) {
    emit(state.copyWith(devices: []));
  }
}