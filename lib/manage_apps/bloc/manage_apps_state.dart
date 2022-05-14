part of 'manage_apps_bloc.dart';

enum ManageAppsStatus { initial, loading, success, failure }

enum ManageAppsTab { mine, preInstalled }

enum ManageAppsSortColumn { appName, size }

enum ManageAppsSortDirection { ascending, descending }

enum ManageAppsInstallStatus {
  initial,
  startUpload,
  uploading,
  uploadSuccess,
  uploadFailure
}

class ManageAppsInstallStatusUnit extends Equatable {
  final ManageAppsInstallStatus status;
  final int current;
  final int total;
  final String? failureReason;
  final bool isRunInBackground;

  const ManageAppsInstallStatusUnit(
      {this.status = ManageAppsInstallStatus.initial,
      this.current = 0,
      this.total = 0,
      this.failureReason,
      this.isRunInBackground = false});

  @override
  List<Object?> get props =>
      [status, current, total, failureReason, isRunInBackground];

  ManageAppsInstallStatusUnit copyWith(
      {ManageAppsInstallStatus? status,
      int? current,
      int? total,
      String? failureReason,
      bool? isRunInBackground}) {
    return ManageAppsInstallStatusUnit(
        status: status ?? this.status,
        current: current ?? this.current,
        total: total ?? this.total,
        failureReason: failureReason ?? this.failureReason,
        isRunInBackground: isRunInBackground ?? this.isRunInBackground);
  }
}

enum ManageAppsKeyStatus { none, ctrlDown, shiftDown }

enum ManageAppsCtrlAStatus { none, tap }

enum ManageAppsExportApksStatus {
  initial,
  start,
  exporting,
  exportSuccess,
  exportFailure
}

class ManageAppsExportApksStatusUnit extends Equatable {
  final ManageAppsExportApksStatus status;
  final int current;
  final int total;
  final String? failureReason;
  final bool isRunInBackground;

  const ManageAppsExportApksStatusUnit(
      {this.status = ManageAppsExportApksStatus.initial,
      this.current = 0,
      this.total = 0,
      this.failureReason,
      this.isRunInBackground = false});

  @override
  List<Object?> get props =>
      [status, current, total, failureReason, isRunInBackground];

  ManageAppsExportApksStatusUnit copyWith(
      {ManageAppsExportApksStatus? status,
      int? current,
      int? total,
      String? failureReason,
      bool? isRunInBackground}) {
    return ManageAppsExportApksStatusUnit(
        status: status ?? this.status,
        total: total ?? this.total,
        current: current ?? this.current,
        failureReason: failureReason ?? this.failureReason,
        isRunInBackground: isRunInBackground ?? this.isRunInBackground);
  }
}

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
  final ManageAppsInstallStatusUnit installStatus;
  final ManageAppsKeyStatus keyStatus;
  final ManageAppsCtrlAStatus ctrlAStatus;
  final ManageAppsExportApksStatusUnit exportApksStatus;
  final String userAppsKeyword;

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
      this.sortDirection = ManageAppsSortDirection.ascending,
      this.installStatus = const ManageAppsInstallStatusUnit(),
      this.keyStatus = ManageAppsKeyStatus.none,
      this.ctrlAStatus = ManageAppsCtrlAStatus.none,
      this.exportApksStatus = const ManageAppsExportApksStatusUnit(),
      this.userAppsKeyword = ""});

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
        sortDirection,
        installStatus,
        keyStatus,
        ctrlAStatus,
        exportApksStatus,
        userAppsKeyword
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
      ManageAppsSortDirection? sortDirection,
      ManageAppsInstallStatusUnit? installStatus,
      ManageAppsKeyStatus? keyStatus,
      ManageAppsCtrlAStatus? ctrlAStatus,
      ManageAppsExportApksStatusUnit? exportApksStatus,
      String? userAppsKeyword}) {
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
        sortDirection: sortDirection ?? this.sortDirection,
        installStatus: installStatus ?? this.installStatus,
        keyStatus: keyStatus ?? this.keyStatus,
        ctrlAStatus: ctrlAStatus ?? this.ctrlAStatus,
        exportApksStatus: exportApksStatus ?? this.exportApksStatus,
        userAppsKeyword: userAppsKeyword ?? this.userAppsKeyword);
  }
}
