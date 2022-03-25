part of 'enter_bloc.dart';

enum NetworkType { wifi, ethernet }

class EnterState extends Equatable {
  final bool isNetworkConnected;
  final String? networkName;
  final List<Device> devices;
  final NetworkType networkType;

  const EnterState({
    this.isNetworkConnected = true,
    this.networkName = null,
    this.devices = const [],
    this.networkType = NetworkType.wifi
  });

  @override
  List<Object?> get props => [isNetworkConnected, networkName, devices, networkType];

  EnterState copyWith({
    bool? isNetworkConnected,
    String? networkName,
    List<Device>? devices,
    NetworkType? networkType
  }) {
    return EnterState(
        isNetworkConnected: isNetworkConnected ?? this.isNetworkConnected,
      networkName: networkName ?? this.networkName,
      devices: devices ?? this.devices,
      networkType: networkType ?? this.networkType
    );
  }
}