
import 'package:equatable/equatable.dart';

import '../../model/Device.dart';

abstract class EnterEvent extends Equatable {
  const EnterEvent();

  @override
  List<Object?> get props => [];
}

class EnterNetworkChanged extends EnterEvent {
  final bool isConnected;
  final String? networkName;

  const EnterNetworkChanged(this.isConnected, this.networkName);

  @override
  List<Object?> get props => [isConnected, this.networkName];
}

class EnterFindMobile extends EnterEvent {
  final Device device;

  const EnterFindMobile(this.device);

  @override
  List<Object?> get props => [device];
}

class EnterClearFindMobiles extends EnterEvent {
  const EnterClearFindMobiles();
}