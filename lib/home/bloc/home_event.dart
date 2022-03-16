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