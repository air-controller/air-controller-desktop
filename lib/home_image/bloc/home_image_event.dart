part of 'home_image_bloc.dart';

abstract class HomeImageEvent extends Equatable {
  const HomeImageEvent();

  @override
  List<Object?> get props => [];
}

class HomeImageTabChanged extends HomeImageEvent {
  final HomeImageTab tab;

  const HomeImageTabChanged({required this.tab});

  @override
  List<Object?> get props => [tab];
}

class HomeImageArrangementChanged extends HomeImageEvent {
  final ArrangementMode arrangement;

  const HomeImageArrangementChanged({required this.arrangement});

  @override
  List<Object?> get props => [arrangement];
}

class HomeImageDeleteStatusChanged extends HomeImageEvent {
  final bool isDeleteEnabled;

  const HomeImageDeleteStatusChanged({required this.isDeleteEnabled});

  @override
  List<Object?> get props => [isDeleteEnabled];
}

class HomeImageDeleteTrigger extends HomeImageEvent {
  final HomeImageTab currentTab;

  const HomeImageDeleteTrigger({required this.currentTab});

  @override
  List<Object?> get props => [currentTab];
}

class HomeImageCountChanged extends HomeImageEvent {
  final HomeImageCount count;

  const HomeImageCountChanged(this.count);

  @override
  List<Object?> get props => [count];
}

class HomeImageArrangementVisibilityChanged extends HomeImageEvent {
  final bool visible;

  const HomeImageArrangementVisibilityChanged(this.visible);

  @override
  List<Object?> get props => [visible];
}

class HomeImageBackVisibilityChanged extends HomeImageEvent {
  final bool visible;

  const HomeImageBackVisibilityChanged(this.visible);

  @override
  List<Object?> get props => [visible];
}

class HomeImageBackTapStatusChanged extends HomeImageEvent {
  final HomeImageBackTapStatus status;

  const HomeImageBackTapStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}