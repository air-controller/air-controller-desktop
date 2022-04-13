import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_assistant_client/repository/common_repository.dart';
import 'package:mobile_assistant_client/util/common_util.dart';
import 'package:mobile_assistant_client/util/update_checker.dart';

import '../../model/mobile_info.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeLinearProgressIndicatorStatus extends Equatable {
  final bool visible;
  final int current;
  final int total;

  const HomeLinearProgressIndicatorStatus({
    this.visible = false,
    this.current = 0,
    this.total = 0
  });

  @override
  List<Object?> get props => [visible, current, total];
}

enum UpdateDownloadStatus { initial, start, downloading, success, failure, stop }

class UpdateDownloadStatusUnit extends Equatable {
  final UpdateDownloadStatus status;
  final String? name;
  final String? path;
  final int totalSize;
  final int currentSize;
  final String? failureReason;

  const UpdateDownloadStatusUnit({this.status = UpdateDownloadStatus.initial,
    this.name, this.path, this.totalSize = 0, this.currentSize = 0, this.failureReason});

  @override
  List<Object?> get props => [status, name, path, totalSize, currentSize, failureReason];
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final CommonRepository _commonRepository;
  final UpdateChecker _updateChecker = UpdateChecker.create();
  final StreamController<HomeLinearProgressIndicatorStatus> _progressIndicatorStreamController = StreamController();
  final StreamController<UpdateDownloadStatusUnit> _updateDownloadStatusController = StreamController();

  Stream<HomeLinearProgressIndicatorStatus> get progressIndicatorStream => _progressIndicatorStreamController.stream;
  Stream<UpdateDownloadStatusUnit> get updateDownloadStatusStream => _updateDownloadStatusController.stream;

  HomeBloc({required CommonRepository commonRepository})
      : _commonRepository = commonRepository,
        super(HomeState(tab: HomeTab.image)) {
    on<HomeTabChanged>(_onHomeTabChanged);
    on<HomeSubscriptionRequested>(_onSubscriptionRequested);
    on<HomeCheckUpdateRequested>(_onCheckUpdateRequested);
    on<HomeNewVersionAvailable>(_onNewVersionAvailable);
    on<HomeProgressIndicatorStatusChanged>(_onProgressIndicatorStatusChanged);
    on<HomeUpdateDownloadStatusChanged>(_onUpdateDownloadStatusChanged);
  }

  void _onHomeTabChanged(HomeTabChanged event, Emitter<HomeState> emit) {
    emit(state.copyWith(tab: event.tab));
  }

  void _onSubscriptionRequested(
      HomeSubscriptionRequested event, Emitter<HomeState> emit) async {
    MobileInfo mobileInfo = await _commonRepository.getMobileInfo();

    String appVersion = await CommonUtil.currentVersion();
    emit(state.copyWith(mobileInfo: mobileInfo, version: appVersion));
  }

  void _onCheckUpdateRequested(
      HomeCheckUpdateRequested event,
      Emitter<HomeState> emit) async {
    _updateChecker.onCheckFailure((error) {
      log("HomeBloc, _onCheckUpdateRequested, onCheckFailure: $error");
    });

    _updateChecker.onNoUpdateAvailable(() {
      log("HomeBloc, _onCheckUpdateRequested, onNoUpdateAvailable");
    });

    _updateChecker.onUpdateAvailable((publishTime, version, assets, updateInfo) {
      log("HomeBloc, _onCheckUpdateRequested, onUpdateAvailable, version: $version, assets size: ${assets.length}, updateInfo: $updateInfo");


      add(HomeNewVersionAvailable(publishTime, version, assets, updateInfo));
    });

    _updateChecker.check();
  }

  void _onNewVersionAvailable(
      HomeNewVersionAvailable event,
      Emitter<HomeState> emit) async {
    final updateAssets = event.assets;

    String name = "";
    String url = "";

    updateAssets.forEach((asset) {
      if (Platform.isMacOS) {
        if (asset.name.endsWith(".dmg")) {
          name = asset.name;
          url = asset.url;
        }
      } else if (Platform.isWindows) {
        if (asset.name.endsWith(".exe")) {
          name = asset.name;
          url = asset.url;
        }
      } else {
        if (asset.name.endsWith(".AppImage")) {
          name = asset.name;
          url = asset.url;
        }
      }
    });

    emit(
      state.copyWith(updateCheckStatus: UpdateCheckResult(
        hasUpdateAvailable: true,
        publishTime: event.publishTime,
        version: event.version,
        updateInfo: event.updateInfo,
        url: url,
        name: name
      ))
    );
  }

  void _onProgressIndicatorStatusChanged(
      HomeProgressIndicatorStatusChanged event,
      Emitter<HomeState> emit) async {
    if (_progressIndicatorStreamController.isClosed) return;

    _progressIndicatorStreamController.add(event.status);
  }

  void _onUpdateDownloadStatusChanged(
      HomeUpdateDownloadStatusChanged event,
      Emitter<HomeState> emit) async {
    if (_updateDownloadStatusController.isClosed) return;

    _updateDownloadStatusController.add(event.status);
  }

  @override
  Future<void> close() {
    _progressIndicatorStreamController.close();
    _updateDownloadStatusController.close();
    return super.close();
  }
}
