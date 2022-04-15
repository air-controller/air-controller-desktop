
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/video_order_type.dart';

part 'video_home_event.dart';
part 'video_home_state.dart';

class VideoHomeBloc extends Bloc<VideoHomeEvent, VideoHomeState> {
  VideoHomeBloc() : super(VideoHomeState()) {
    on<VideoHomeItemCountChanged>(_onItemCountChanged);
    on<VideoHomeOderTypeChanged>(_onOrderTypeChanged);
    on<VideoHomeDeleteStatusChanged>(_onDeleteStatusChanged);
    on<VideoHomeTabChanged>(_onTabChanged);
    on<VideoHomeBackVisibilityChanged>(_onBackVisibilityChanged);
    on<VideoHomeBackTapStatusChanged>(_onBackTapStatusChanged);
    on<VideoHomeOderTypeVisibilityChanged>(_onOrderTypeVisibilityChanged);
    on<VideoHomeDeleteTapped>(_onDeleteTapStatusChanged);
  }

  void _onItemCountChanged(
      VideoHomeItemCountChanged event,
      Emitter<VideoHomeState> emit) {
    emit(state.copyWith(itemCount: event.itemCount));
  }

  void _onOrderTypeChanged(
      VideoHomeOderTypeChanged event,
      Emitter<VideoHomeState> emit) {
    emit(state.copyWith(orderType: event.orderType));
  }

  void _onDeleteStatusChanged(
      VideoHomeDeleteStatusChanged event,
      Emitter<VideoHomeState> emit) {
    emit(state.copyWith(isDeleteEnabled: event.isDeleteEnabled));
  }

  void _onTabChanged(
      VideoHomeTabChanged event,
      Emitter<VideoHomeState> emit) {
    emit(state.copyWith(tab: event.tab));
  }

  void _onBackVisibilityChanged(
      VideoHomeBackVisibilityChanged event,
      Emitter<VideoHomeState> emit) {
    emit(state.copyWith(isBackVisible: event.visible));
  }

  void _onBackTapStatusChanged(
      VideoHomeBackTapStatusChanged event,
      Emitter<VideoHomeState> emit) {
    emit(state.copyWith(backTapStatus: event.status));
  }

  void _onOrderTypeVisibilityChanged(
      VideoHomeOderTypeVisibilityChanged event,
      Emitter<VideoHomeState> emit) {
    emit(state.copyWith(isOrderTypeVisible: event.visible));
  }
  
  void _onDeleteTapStatusChanged(
      VideoHomeDeleteTapped event,
      Emitter<VideoHomeState> emit) {
    emit(state.copyWith(deleteTapStatus: VideoHomeDeleteTapStatus.tap));
    emit(state.copyWith(deleteTapStatus: VideoHomeDeleteTapStatus.none));
  }
}