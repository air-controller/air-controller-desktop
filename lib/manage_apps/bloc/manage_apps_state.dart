part of 'manage_apps_bloc.dart';

enum ManageAppsStatus { initial, loading, success, failure }

enum ManageAppsTab { mine, preInstalled }

enum ManageAppsSortColumn { appName, size }

enum ManageAppsSortDirection { ascending, descending }

class ManageAppsState extends Equatable {
  final ManageAppsTab tab;
  final ManageAppsStatus status;
  final List<AppInfo> apps;
  final List<AppInfo> userApps;
  final List<AppInfo> filterUserApps;
  final List<AppInfo> checkedUserApps;
  final List<AppInfo> systemApps;
  final List<AppInfo> filterSystemApps;
  final List<AppInfo> checkedSystemApps;
  final String? failureReason;
  final ManageAppsSortColumn sortColumn;
  final ManageAppsSortDirection sortDirection;

  const ManageAppsState(
      {this.tab = ManageAppsTab.mine,
      this.status = ManageAppsStatus.initial,
      this.apps = const [],
      this.userApps = const [],
      this.filterUserApps = const [],
      this.checkedUserApps = const [],
      this.systemApps = const [],
      this.filterSystemApps = const [],
      this.checkedSystemApps = const [],
      this.failureReason = null,
      this.sortColumn = ManageAppsSortColumn.appName,
      this.sortDirection = ManageAppsSortDirection.ascending});

  @override
  List<Object?> get props => [
        tab,
        status,
        apps,
        userApps,
        filterUserApps,
        checkedUserApps,
        systemApps,
        filterSystemApps,
        checkedSystemApps,
        failureReason,
        sortColumn,
        sortDirection
      ];

  ManageAppsState copyWith(
      {ManageAppsTab? tab,
      ManageAppsStatus? status,
      List<AppInfo>? apps,
      List<AppInfo>? userApps,
      List<AppInfo>? filterUserApps,
      List<AppInfo>? checkedUserApps,
      List<AppInfo>? systemApps,
      List<AppInfo>? filterSystemApps,
      List<AppInfo>? checkedSystemApps,
      String? failureReason,
      ManageAppsSortColumn? sortColumn,
      ManageAppsSortDirection? sortDirection}) {
    return ManageAppsState(
        tab: tab ?? this.tab,
        status: status ?? this.status,
        apps: apps ?? this.apps,
        userApps: userApps ?? this.userApps,
        filterUserApps: filterUserApps ?? this.filterUserApps,
        checkedUserApps: checkedUserApps ?? this.checkedUserApps,
        systemApps: systemApps ?? this.systemApps,
        filterSystemApps: filterSystemApps ?? this.filterSystemApps,
        checkedSystemApps: checkedSystemApps ?? this.checkedSystemApps,
        failureReason: failureReason ?? this.failureReason,
        sortColumn: sortColumn ?? this.sortColumn,
        sortDirection: sortDirection ?? this.sortDirection);
  }
}
