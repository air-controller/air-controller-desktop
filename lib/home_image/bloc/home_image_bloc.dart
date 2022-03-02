import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_assistant_client/home_image/bloc/home_image_event.dart';
import 'package:mobile_assistant_client/home_image/bloc/home_image_state.dart';

class HomeImageBloc extends Bloc<HomeImageEvent, HomeImageState> {
  HomeImageBloc() : super(HomeImageState()) {
    on<HomeImageTabChanged>(_onTabChanged);
    on<HomeImageArrangementChanged>(_onArrangementChanged);
    on<HomeImageDeleteStatusChanged>(_onDeleteStatusChanged);
    on<HomeImageDeleteTrigger>(_onDeleteImagesTrigger);
    on<HomeImageCountChanged>(_onImageCountChanged);
    on<HomeImageArrangementVisibilityChanged>(_onArrangementVisibilityChanged);
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
}
