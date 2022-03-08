part of 'video_home_bloc.dart';

class VideoHomeEvent extends Equatable {
  const VideoHomeEvent();

  @override
  List<Object?> get props => [];
}

class VideoHomeItemCountChanged extends VideoHomeEvent {
  final VideoHomeItemCount itemCount;

  const VideoHomeItemCountChanged(this.itemCount);

  @override
  List<Object?> get props => [itemCount];
}

class VideoHomeOderTypeChanged extends VideoHomeEvent {
  final VideoOrderType orderType;

  const VideoHomeOderTypeChanged(this.orderType);

  @override
  List<Object?> get props => [orderType];
}

class VideoHomeDeleteStatusChanged extends VideoHomeEvent {
  final bool isDeleteEnabled;

  const VideoHomeDeleteStatusChanged(this.isDeleteEnabled);

  @override
  List<Object?> get props => [isDeleteEnabled];
}

class VideoHomeTabChanged extends VideoHomeEvent {
  final VideoHomeTab tab;

  const VideoHomeTabChanged(this.tab);

  @override
  List<Object?> get props => [tab];
}

class VideoHomeBackVisibilityChanged extends VideoHomeEvent {
  final bool visible;

  const VideoHomeBackVisibilityChanged(this.visible);

  @override
  List<Object?> get props => [visible];
}

class VideoHomeBackTapStatusChanged extends VideoHomeEvent {
  final VideoHomeBackTapStatus status;

  const VideoHomeBackTapStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class VideoHomeOderTypeVisibilityChanged extends VideoHomeEvent {
  final bool visible;

  const VideoHomeOderTypeVisibilityChanged(this.visible);

  @override
  List<Object?> get props => [visible];
}

class VideoHomeDeleteTapped extends VideoHomeEvent {
  const VideoHomeDeleteTapped();
}