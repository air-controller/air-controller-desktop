import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/arrangement_mode.dart';

part 'home_image_event.dart';
part 'home_image_state.dart';

class HomeImageBloc extends Bloc<HomeImageEvent, HomeImageState> {
  HomeImageBloc() : super(HomeImageState()) {
    on<HomeImageTabChanged>(_onTabChanged);
    on<HomeImageArrangementChanged>(_onArrangementChanged);
    on<HomeImageDeleteStatusChanged>(_onDeleteStatusChanged);
    on<HomeImageDeleteTrigger>(_onDeleteImagesTrigger);
    on<HomeImageCountChanged>(_onImageCountChanged);
    on<HomeImageArrangementVisibilityChanged>(_onArrangementVisibilityChanged);
    on<HomeImageBackVisibilityChanged>(_onBackVisibilityChanged);
    on<HomeImageBackTapStatusChanged>(_onBackTapStatusChanged);
  }

  void _onTabChanged(HomeImageTabChanged event, Emitter<HomeImageState> emit) {
    emit(state.copyWith(tab: event.tab));
  }

  void _onArrangementChanged(
      HomeImageArrangementChanged event, Emitter<HomeImageState> emit) {
    emit(state.copyWith(arrangement: event.arrangement));
  }

  void _onDeleteStatusChanged(
      HomeImageDeleteStatusChanged event, Emitter<HomeImageState> emit) {
    emit(state.copyWith(isDeleteEnabled: event.isDeleteEnabled));
  }

  void _onDeleteImagesTrigger(
      HomeImageDeleteTrigger event, Emitter<HomeImageState> emit) {
    emit(state.copyWith(
        deleteTapStatus: HomeImageDeleteTapStatusUnit(
            tab: event.currentTab,
            status: HomeImageDeleteTapStatus.tap
        )
    ));

    emit(state.copyWith(
        deleteTapStatus: HomeImageDeleteTapStatusUnit(
          tab: state.deleteTapStatus.tab,
            status: HomeImageDeleteTapStatus.initial
        )
    ));
  }

  void _onImageCountChanged(
      HomeImageCountChanged event, Emitter<HomeImageState> emit) {
    emit(state.copyWith(imageCount: event.count));
  }

  void _onArrangementVisibilityChanged(
      HomeImageArrangementVisibilityChanged event,
      Emitter<HomeImageState> emit) {
    emit(state.copyWith(isArrangementVisible: event.visible));
  }

  void _onBackVisibilityChanged(
      HomeImageBackVisibilityChanged event,
      Emitter<HomeImageState> emit) {
    emit(state.copyWith(isBackBtnVisible: event.visible));
  }

  void _onBackTapStatusChanged(
      HomeImageBackTapStatusChanged event,
      Emitter<HomeImageState> emit) {
    emit(state.copyWith(
      backTapStatus: event.status
    ));

    emit(state.copyWith(
        backTapStatus: HomeImageBackTapStatus.initial
    ));
  }
}
