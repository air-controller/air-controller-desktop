import 'dart:async';

import 'package:air_controller/model/app_info.dart';
import 'package:air_controller/repository/aircontroller_client.dart';
import 'package:air_controller/repository/common_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class ManageAppsBloc extends Bloc<ManageAppsEvent, ManageAppsState> {
  final CommonRepository _repository;

  final StreamController<ManageAppsProgressIndicatorStatus>
      _progressIndicatorStreamController = StreamController();
  Stream<ManageAppsProgressIndicatorStatus> get progressIndicatorStream =>
      _progressIndicatorStreamController.stream;

  final StreamController<ManageAppsItemCount>
      _itemCountStreamController = StreamController();
  Stream<ManageAppsItemCount> get itemCountStream =>
      _itemCountStreamController.stream;    

  ManageAppsBloc(CommonRepository repository)
      : _repository = repository,
        super(ManageAppsState()) {
    on<ManageAppsSubscriptionRequested>(_onSubscriptionRequested);
    on<ManageAppsSortChanged>(_onSortChanged);
    on<ManageAppsInstallStatusChanged>(_onInstallStatusChanged);
    on<ManageAppsCancelInstallation>(_onCancelInstallation);
    on<ManageAppsIndicatorStatusChanged>(_onProgressIndicatorStatusChanged);
    on<ManageAppsUserAppCheckChanged>(_onUserAppCheckChanged);
    on<ManageAppsKeyStatusChanged>(_onKeyStatusChanged);
    on<ManageAppsCtrlAStatusChanged>(_onCtrlAStatusChanged);
    on<ManageAppsExportStatusChanged>(_onExportStatusChanged);
    on<ManageAppsCancelExport>(_onExportCancelled);
    on<ManageAppsUserAppsKeyWordChanged>(_onUserAppsKeywordChanged);
    on<ManageAppsItemCountChanged>(_onItemCountChanged);
  }

  void _onSubscriptionRequested(ManageAppsSubscriptionRequested event,
      Emitter<ManageAppsState> emit) async {
    emit(state.copyWith(status: ManageAppsStatus.loading));

    try {
      final apps = await _repository.getInstalledApps();
      List<AppInfo> userApps = apps.where((app) => !app.isSystemApp).toList();
      _sortApps(userApps, ManageAppsSortColumn.appName,
          ManageAppsSortDirection.ascending);

      List<AppInfo> systemApps = apps.where((app) => app.isSystemApp).toList();
      _sortApps(systemApps, ManageAppsSortColumn.appName,
          ManageAppsSortDirection.ascending);

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
    if (event.isUserApps) {
      List<AppInfo> userApps = [...state.userApps];
      _sortApps(userApps, event.sortColumn, event.sortDirection);

      emit(state.copyWith(
          userApps: userApps,
          sortColumn: event.sortColumn,
          sortDirection: event.sortDirection));
    } else {
      List<AppInfo> systemApps = [...state.systemApps];
      _sortApps(systemApps, event.sortColumn, event.sortDirection);

      emit(state.copyWith(
          systemApps: systemApps,
          sortColumn: event.sortColumn,
          sortDirection: event.sortDirection));
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
      ManageAppsUserAppCheckChanged event, Emitter<ManageAppsState> emit) {
    List<AppInfo> userApps = [...state.userApps];
    List<AppInfo> checkedUserApps = [...state.checkedUserApps];
    AppInfo app = event.app;

    ManageAppsKeyStatus keyStatus = state.keyStatus;

    if (!checkedUserApps.contains(app)) {
      if (keyStatus == ManageAppsKeyStatus.ctrlDown) {
        checkedUserApps.add(app);
      } else if (keyStatus == ManageAppsKeyStatus.shiftDown) {
        if (checkedUserApps.length == 0) {
          checkedUserApps.add(app);
        } else if (checkedUserApps.length == 1) {
          int index = userApps.indexOf(checkedUserApps[0]);

          int current = userApps.indexOf(app);

          if (current > index) {
            checkedUserApps = userApps.sublist(index, current + 1);
          } else {
            checkedUserApps = userApps.sublist(current, index + 1);
          }
        } else {
          int maxIndex = 0;
          int minIndex = 0;

          for (int i = 0; i < checkedUserApps.length; i++) {
            AppInfo current = checkedUserApps[i];
            int index = userApps.indexOf(current);
            if (index < 0) {
              continue;
            }

            if (index > maxIndex) {
              maxIndex = index;
            }

            if (index < minIndex) {
              minIndex = index;
            }
          }

          int current = userApps.indexOf(app);

          if (current >= minIndex && current <= maxIndex) {
            checkedUserApps = userApps.sublist(current, maxIndex + 1);
          } else if (current < minIndex) {
            checkedUserApps = userApps.sublist(current, maxIndex + 1);
          } else if (current > maxIndex) {
            checkedUserApps = userApps.sublist(minIndex, current + 1);
          }
        }
      } else {
        checkedUserApps.clear();
        checkedUserApps.add(app);
      }
    } else {
      if (keyStatus == ManageAppsKeyStatus.ctrlDown) {
        checkedUserApps.remove(app);
      } else if (keyStatus == ManageAppsKeyStatus.shiftDown) {
        checkedUserApps.remove(app);
      } else {
        checkedUserApps.clear();
        checkedUserApps.add(app);
      }
    }
    emit(state.copyWith(checkedUserApps: checkedUserApps));
  }

  void _onKeyStatusChanged(
      ManageAppsKeyStatusChanged event, Emitter<ManageAppsState> emit) {
    emit(state.copyWith(keyStatus: event.keyStatus));
  }

  void _onCtrlAStatusChanged(
      ManageAppsCtrlAStatusChanged event, Emitter<ManageAppsState> emit) {
    if (event.status == ManageAppsCtrlAStatus.tap) {
      if (state.tab == ManageAppsTab.mine) {
        final checkedUserApps = [...state.userApps];
        emit(state.copyWith(
            checkedUserApps: checkedUserApps, ctrlAStatus: event.status));
      }
      return;
    }

    emit(state.copyWith(ctrlAStatus: event.status));
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
      ManageAppsUserAppsKeyWordChanged event, Emitter<ManageAppsState> emit) {
    String keyword = event.keyword.trim();

    if (keyword.isEmpty) {
      final userApps =
          state.apps.where((element) => !element.isSystemApp).toList();
      _sortApps(userApps, state.sortColumn, state.sortDirection);

      emit(state.copyWith(userAppsKeyword: keyword, userApps: userApps));
    } else {
      final userApps = state.userApps
          .where((element) =>
              element.name.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
      emit(state.copyWith(userApps: userApps, userAppsKeyword: keyword));
    }
  }

  void _onItemCountChanged(
      ManageAppsItemCountChanged event, Emitter<ManageAppsState> emit) {
    if (_itemCountStreamController.isClosed) return;

    _itemCountStreamController.add(event.itemCount);
  }
}
