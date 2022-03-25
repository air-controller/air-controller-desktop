part of 'enter_bloc.dart';

abstract class EnterEvent extends Equatable {
  const EnterEvent();

  @override
  List<Object?> get props => [];
}

class EnterNetworkChanged extends EnterEvent {
  final bool isConnected;
  final String? networkName;
  final NetworkType networkType;

  const EnterNetworkChanged(this.isConnected, this.networkName, this.networkType);

  @override
  List<Object?> get props => [isConnected, networkName, networkType];
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