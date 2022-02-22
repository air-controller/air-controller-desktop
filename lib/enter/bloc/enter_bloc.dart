import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_assistant_client/enter/bloc/enter_event.dart';
import 'package:mobile_assistant_client/enter/bloc/enter_state.dart';

import '../../model/Device.dart';

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
      networkName: event.networkName
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