part of 'manage_apps_bloc.dart';

enum ManageAppsStatus { initial, loading, success, failure }

enum ManageAppsTab { mine, preInstalled }

extension ManageAppsTabX on ManageAppsTab {
  static ManageAppsTab converIndexTo(int index) {
    try {
      return ManageAppsTab.values.firstWhere((tab) => tab.index == index);
    } catch (e) {
      return ManageAppsTab.mine;
    }
  }
}

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

class ManageAppContextMenuInfo extends Equatable {
  final Offset position;
  final AppInfo app;

  const ManageAppContextMenuInfo({required this.position, required this.app});

  @override
  List<Object?> get props => [position, app];
}

class ManageAppsState extends Equatable {
  final ManageAppsTab tab;
  final ManageAppsStatus status;
  final List<AppInfo> apps;
  final List<AppInfo> userApps;
  final List<AppInfo> checkedUserApps;
  final List<AppInfo> systemApps;
  final List<AppInfo> checkedSystemApps;
  final String? failureReason;
  final ManageAppsSortColumn userAppsSortColumn;
  final ManageAppsSortDirection userAppsSortDirection;
  final ManageAppsSortColumn systemAppsSortColumn;
  final ManageAppsSortDirection systemAppsSortDirection;
  final ManageAppsInstallStatusUnit installStatus;
  final ManageAppsExportApksStatusUnit exportApksStatus;
  final String keyWord;
  final ManageAppContextMenuInfo? contextMenuInfo;

  const ManageAppsState(
      {this.tab = ManageAppsTab.mine,
      this.status = ManageAppsStatus.initial,
      this.apps = const [],
      this.userApps = const [],
      this.checkedUserApps = const [],
      this.systemApps = const [],
      this.checkedSystemApps = const [],
      this.failureReason = null,
      this.userAppsSortColumn = ManageAppsSortColumn.appName,
      this.userAppsSortDirection = ManageAppsSortDirection.ascending,
      this.systemAppsSortColumn = ManageAppsSortColumn.appName,
      this.systemAppsSortDirection = ManageAppsSortDirection.ascending,
      this.installStatus = const ManageAppsInstallStatusUnit(),
      this.exportApksStatus = const ManageAppsExportApksStatusUnit(),
      this.keyWord = "",
      this.contextMenuInfo});

  @override
  List<Object?> get props => [
        tab,
        status,
        apps,
        userApps,
        checkedUserApps,
        systemApps,
        checkedSystemApps,
        failureReason,
        userAppsSortColumn,
        userAppsSortDirection,
        systemAppsSortColumn,
        systemAppsSortDirection,
        installStatus,
        exportApksStatus,
        keyWord,
        contextMenuInfo
      ];

  ManageAppsState copyWith(
      {ManageAppsTab? tab,
      ManageAppsStatus? status,
      List<AppInfo>? apps,
      List<AppInfo>? userApps,
      List<AppInfo>? checkedUserApps,
      List<AppInfo>? systemApps,
      List<AppInfo>? checkedSystemApps,
      String? failureReason,
      ManageAppsSortColumn? userAppsSortColumn,
      ManageAppsSortDirection? userAppsSortDirection,
      ManageAppsInstallStatusUnit? installStatus,
      ManageAppsExportApksStatusUnit? exportApksStatus,
      String? userAppsKeyword,
      ManageAppsSortColumn? systemAppsSortColumn,
      ManageAppsSortDirection? systemAppsSortDirection,
      ManageAppContextMenuInfo? contextMenuInfo}) {
    return ManageAppsState(
        tab: tab ?? this.tab,
        status: status ?? this.status,
        apps: apps ?? this.apps,
        userApps: userApps ?? this.userApps,
        checkedUserApps: checkedUserApps ?? this.checkedUserApps,
        systemApps: systemApps ?? this.systemApps,
        checkedSystemApps: checkedSystemApps ?? this.checkedSystemApps,
        failureReason: failureReason ?? this.failureReason,
        userAppsSortColumn: userAppsSortColumn ?? this.userAppsSortColumn,
        userAppsSortDirection:
            userAppsSortDirection ?? this.userAppsSortDirection,
        installStatus: installStatus ?? this.installStatus,
        exportApksStatus: exportApksStatus ?? this.exportApksStatus,
        keyWord: userAppsKeyword ?? this.keyWord,
        systemAppsSortColumn: systemAppsSortColumn ?? this.systemAppsSortColumn,
        systemAppsSortDirection:
            systemAppsSortDirection ?? this.systemAppsSortDirection,
        contextMenuInfo: contextMenuInfo ?? this.contextMenuInfo);
  }
}
