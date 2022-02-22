
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_assistant_client/home2/bloc/home_event.dart';
import 'package:mobile_assistant_client/home2/bloc/home_state.dart';
import 'package:mobile_assistant_client/repository/common_repository.dart';

import '../../model/mobile_info.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final CommonRepository _commonRepository;

  HomeBloc({required CommonRepository commonRepository})
      : _commonRepository = commonRepository,
        super(HomeState(tab: HomeTab.image)) {
    on<HomeTabChanged>(_onHomeTabChanged);
    on<HomeSubscriptionRequested>(_onSubscriptionRequested);
  }

  void _onHomeTabChanged(
      HomeTabChanged event,
      Emitter<HomeState> emit) {
    emit(state.copyWith(tab: event.tab));
  }

  void _onSubscriptionRequested(
      HomeSubscriptionRequested event,
      Emitter<HomeState> emit) async {
    MobileInfo mobileInfo = await _commonRepository.getMobileInfo();
    emit(state.copyWith(mobileInfo: mobileInfo));
  }
}
