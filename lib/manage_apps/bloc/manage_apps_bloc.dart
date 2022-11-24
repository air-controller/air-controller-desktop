import 'dart:async';

import 'package:air_controller/manage_apps/view/data_grid_holder.dart';
import 'package:air_controller/model/app_info.dart';
import 'package:air_controller/repository/aircontroller_client.dart';
import 'package:air_controller/repository/common_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../util/common_util.dart';

part 'manage_apps_event.dart';
part 'manage_apps_state.dart';

class ManageAppsProgressIndicatorStatus extends Equatable {
  final bool visible;
  final int current;
  final int total;

  const ManageAppsProgressIndicatorStatus(
      {this.visible = false, this.current = 0, this.total = 0});

  @override
  List<Object?> get props => [visible, current, total];
}

class ManageAppsItemCount extends Equatable {
  final int checkedCount;
  final int total;

  const ManageAppsItemCount({this.checkedCount = 0, this.total = 0});

  @override
  List<Object?> get props => [checkedCount, total];
}

class ManageAppsHomeBloc extends Bloc<ManageAppsEvent, ManageAppsState> {
  final CommonRepository _repository;

  final StreamController<ManageAppsProgressIndicatorStatus>
      _progressIndicatorStreamController = StreamController();
  Stream<ManageAppsProgressIndicatorStatus> get progressIndicatorStream =>
      _progressIndicatorStreamController.stream;

  final StreamController<ManageAppsItemCount> _itemCountStreamController =
      StreamController();
  Stream<ManageAppsItemCount> get itemCountStream =>
      _itemCountStreamController.stream;

  ManageAppsHomeBloc(CommonRepository repository)
      : _repository = repository,
        super(ManageAppsState()) {
    on<ManageAppsSubscriptionRequested>(_onSubscriptionRequested);
    on<ManageAppsSortChanged>(_onSortChanged);
    on<ManageAppsInstallStatusChanged>(_onInstallStatusChanged);
    on<ManageAppsCancelInstallation>(_onCancelInstallation);
    on<ManageAppsIndicatorStatusChanged>(_onProgressIndicatorStatusChanged);
    on<ManageAppsCheckChanged>(_onUserAppCheckChanged);
    on<ManageAppsExportStatusChanged>(_onExportStatusChanged);
    on<ManageAppsCancelExport>(_onExportCancelled);
    on<ManageAppsKeyWordChanged>(_onUserAppsKeywordChanged);
    on<ManageAppsItemCountChanged>(_onItemCountChanged);
    on<ManageAppsTabChanged>(_onTabChanged);
    on<ManageAppsOpenContextMenu>(_onOpenContextMenu);
    on<ManageAppsWebExportApks>(_onWebExportApks);
  }

  void _onSubscriptionRequested(ManageAppsSubscriptionRequested event,
      Emitter<ManageAppsState> emit) async {
    emit(state.copyWith(status: ManageAppsStatus.loading));

    try {
      final apps = await _repository.getInstalledApps();
      List<AppInfo> userApps = apps.where((app) => !app.isSystemApp).toList();
      _sortApps(
          userApps, state.userAppsSortColumn, state.userAppsSortDirection);

      List<AppInfo> systemApps = apps.where((app) => app.isSystemApp).toList();
      _sortApps(systemApps, state.systemAppsSortColumn,
          state.systemAppsSortDirection);

      emit(state.copyWith(
          userApps: userApps,
          systemApps: systemApps,
          apps: apps,
          status: ManageAppsStatus.success));
    } on BusinessError catch (e) {
      emit(state.copyWith(
          status: ManageAppsStatus.failure, failureReason: e.message));
    }
  }

  void _onSortChanged(
      ManageAppsSortChanged event, Emitter<ManageAppsState> emit) async {
    bool isUserApps = state.tab == ManageAppsTab.mine;
    if (isUserApps) {
      List<AppInfo> userApps = [...state.userApps];
      _sortApps(userApps, event.sortColumn, event.sortDirection);

      emit(state.copyWith(
          userApps: userApps,
          userAppsSortColumn: event.sortColumn,
          userAppsSortDirection: event.sortDirection));
    } else {
      List<AppInfo> systemApps = [...state.systemApps];
      _sortApps(systemApps, event.sortColumn, event.sortDirection);

      emit(state.copyWith(
          systemApps: systemApps,
          systemAppsSortColumn: event.sortColumn,
          systemAppsSortDirection: event.sortDirection));
    }
  }

  void _sortApps(List<AppInfo> apps, ManageAppsSortColumn sortColumn,
      ManageAppsSortDirection sortDirection) {
    apps.sort((appA, appB) {
      if (sortColumn == ManageAppsSortColumn.appName) {
        if (sortDirection == ManageAppsSortDirection.ascending) {
          return appA.name.compareTo(appB.name);
        } else {
          return appB.name.compareTo(appA.name);
        }
      }

      if (sortColumn == ManageAppsSortColumn.size) {
        if (sortDirection == ManageAppsSortDirection.ascending) {
          return appA.size.compareTo(appB.size);
        } else {
          return appB.size.compareTo(appA.size);
        }
      }

      return 0;
    });
  }

  void _onInstallStatusChanged(
      ManageAppsInstallStatusChanged event, Emitter<ManageAppsState> emit) {
    emit(state.copyWith(installStatus: event.status));
  }

  void _onCancelInstallation(
      ManageAppsCancelInstallation event, Emitter<ManageAppsState> emit) {
    emit(state.copyWith(
        installStatus: ManageAppsInstallStatusUnit(
            status: ManageAppsInstallStatus.initial)));
  }

  void _onProgressIndicatorStatusChanged(ManageAppsIndicatorStatusChanged event,
      Emitter<ManageAppsState> emit) async {
    if (_progressIndicatorStreamController.isClosed) return;

    _progressIndicatorStreamController.add(event.status);
  }

  void _onUserAppCheckChanged(
      ManageAppsCheckChanged event, Emitter<ManageAppsState> emit) {
    bool isUserApps = event.isUserApps;

    if (isUserApps) {
      List<AppInfo> checkedUserApps = [...event.checkedApps];

      emit(state.copyWith(checkedUserApps: checkedUserApps));
    } else {
      List<AppInfo> checkedSystemApps = [...event.checkedApps];

      emit(state.copyWith(checkedSystemApps: checkedSystemApps));
    }
  }

  void _onExportStatusChanged(
      ManageAppsExportStatusChanged event, Emitter<ManageAppsState> emit) {
    emit(state.copyWith(exportApksStatus: event.status));
  }

  void _onExportCancelled(
      ManageAppsCancelExport event, Emitter<ManageAppsState> emit) {
    emit(state.copyWith(
        exportApksStatus: ManageAppsExportApksStatusUnit(
            status: ManageAppsExportApksStatus.initial)));
  }

  void _onUserAppsKeywordChanged(
      ManageAppsKeyWordChanged event, Emitter<ManageAppsState> emit) {
    bool isUserApps = state.tab == ManageAppsTab.mine;
    String keyword = event.keyword.trim();

    if (isUserApps) {
      if (keyword.isEmpty) {
        final userApps =
            state.apps.where((element) => !element.isSystemApp).toList();
        _sortApps(
            userApps, state.userAppsSortColumn, state.userAppsSortDirection);

        emit(state.copyWith(userAppsKeyword: keyword, userApps: userApps));
      } else {
        final userApps = state.userApps
            .where((element) =>
                element.name.toLowerCase().contains(keyword.toLowerCase()))
            .toList();
        emit(state.copyWith(userApps: userApps, userAppsKeyword: keyword));
      }
    } else {
      if (keyword.isEmpty) {
        final systemApps =
            state.apps.where((element) => element.isSystemApp).toList();
        _sortApps(
            systemApps, state.userAppsSortColumn, state.userAppsSortDirection);

        emit(state.copyWith(userAppsKeyword: keyword, systemApps: systemApps));
      } else {
        final systemApps = state.systemApps
            .where((element) =>
                element.name.toLowerCase().contains(keyword.toLowerCase()))
            .toList();
        emit(state.copyWith(systemApps: systemApps, userAppsKeyword: keyword));
      }
    }
  }

  void _onItemCountChanged(
      ManageAppsItemCountChanged event, Emitter<ManageAppsState> emit) {
    if (_itemCountStreamController.isClosed) return;

    _itemCountStreamController.add(event.itemCount);
  }

  void _onTabChanged(
      ManageAppsTabChanged event, Emitter<ManageAppsState> emit) {
    emit(state.copyWith(tab: event.tab));
  }

  @override
  Future<void> close() {
    DataGridHolder.dispose();
    return super.close();
  }

  void _onOpenContextMenu(
      ManageAppsOpenContextMenu event, Emitter<ManageAppsState> emit) {
    final app = event.info.app;

    if (event.isUserApp) {
      final checkedUserApps = [...state.checkedUserApps];

      if (!checkedUserApps.contains(app)) {
        checkedUserApps.add(app);
      }

      emit(state.copyWith(
          contextMenuInfo: event.info, checkedUserApps: checkedUserApps));
    } else {
      final checkedSystemApps = [...state.checkedSystemApps];

      if (!checkedSystemApps.contains(app)) {
        checkedSystemApps.add(app);
      }

      emit(state.copyWith(
          contextMenuInfo: event.info, checkedSystemApps: checkedSystemApps));
    }
  }

  FutureOr<void> _onWebExportApks(
      ManageAppsWebExportApks event, Emitter<ManageAppsState> emit) async {
    emit(state.copyWith(showLoading: true));

    try {
      final bytes = await _repository.readPackagesAsBytes(event.apps);
      String fileName = "";
      if (event.apps.length == 1) {
        fileName = "${event.apps.first.name.split("/").last}.apk";
      } else if (event.apps.length > 1) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        fileName = "apps_$timestamp.zip";
      }
      CommonUtil.downloadAsWebFile(bytes: bytes, fileName: fileName);
      emit(state.copyWith(showLoading: false));
    } catch (e) {
      emit(state.copyWith(
          showLoading: false, showError: true, failureReason: e.toString()));
      emit(state.copyWith(showError: false));
    }
  }
}
