part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeTabChanged extends HomeEvent {
  final HomeTab tab;

  const HomeTabChanged(this.tab);

  @override
  List<Object?> get props => [tab];
}

class HomeSubscriptionRequested extends HomeEvent {
  const HomeSubscriptionRequested();
}

class HomeCheckUpdateRequested extends HomeEvent {
  final bool isAutoCheck;

  const HomeCheckUpdateRequested({this.isAutoCheck = true});

  @override
  List<Object?> get props => [isAutoCheck];
}

class HomeNewVersionAvailable extends HomeEvent {
  final int publishTime;
  final String version;
  final List<UpdateAsset> assets;
  final String updateInfo;
  final bool isAutoCheck;

  const HomeNewVersionAvailable(this.publishTime, this.version, this.assets,
      this.updateInfo, this.isAutoCheck);

  @override
  List<Object?> get props => [publishTime, version, assets, updateInfo, isAutoCheck];
}

class HomeProgressIndicatorStatusChanged extends HomeEvent {
  final HomeLinearProgressIndicatorStatus status;

  const HomeProgressIndicatorStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class HomeUpdateDownloadStatusChanged extends HomeEvent {
  final UpdateDownloadStatusUnit status;

  const HomeUpdateDownloadStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class HomeCheckUpdateStatusChanged extends HomeEvent {
  final UpdateCheckStatusUnit status;

  const HomeCheckUpdateStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}