import 'package:air_controller/model/app_info.dart';
import 'package:air_controller/repository/aircontroller_client.dart';
import 'package:air_controller/repository/common_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'manage_apps_event.dart';
part 'manage_apps_state.dart';

class ManageAppsBloc extends Bloc<ManageAppsEvent, ManageAppsState> {
  final CommonRepository _repository;

  ManageAppsBloc(CommonRepository repository)
      : _repository = repository,
        super(ManageAppsState()) {
    on<ManageAppsSubscriptionRequested>(_onSubscriptionRequested);
    on<ManageAppsSortChanged>(_onSortChanged);
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
}
