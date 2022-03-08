part of 'enter_bloc.dart';

class EnterState extends Equatable {
  final bool isNetworkConnected;
  final String networkName;
  final List<Device> devices;

  const EnterState({
    this.isNetworkConnected = true,
    this.networkName = "Unknown network name",
    this.devices = const []
  });

  @override
  List<Object?> get props => [isNetworkConnected, devices];

  EnterState copyWith({
    bool? isNetworkConnected,
    String? networkName,
    List<Device>? devices
  }) {
    return EnterState(
        isNetworkConnected: isNetworkConnected ?? this.isNetworkConnected,
      networkName: networkName ?? this.networkName,
      devices: devices ?? this.devices
    );
  }
}