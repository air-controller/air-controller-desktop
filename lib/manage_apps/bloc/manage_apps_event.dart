part of 'manage_apps_bloc.dart';

class ManageAppsEvent extends Equatable {
  const ManageAppsEvent();

  @override
  List<Object?> get props => [];
}

class ManageAppsSubscriptionRequested extends ManageAppsEvent {
  const ManageAppsSubscriptionRequested();
}

class ManageAppsSortChanged extends ManageAppsEvent {
  final ManageAppsSortColumn sortColumn;
  final ManageAppsSortDirection sortDirection;

  const ManageAppsSortChanged(
      {required this.sortColumn, required this.sortDirection});

  @override
  List<Object?> get props => [sortColumn, sortDirection];
}

class ManageAppsInstallStatusChanged extends ManageAppsEvent {
  final ManageAppsInstallStatusUnit status;

  const ManageAppsInstallStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class ManageAppsCancelInstallation extends ManageAppsEvent {
  const ManageAppsCancelInstallation();
}

class ManageAppsIndicatorStatusChanged extends ManageAppsEvent {
  final ManageAppsProgressIndicatorStatus status;

  const ManageAppsIndicatorStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class ManageAppsCheckChanged extends ManageAppsEvent {
  final List<AppInfo> checkedApps;
  final bool isUserApps;

  const ManageAppsCheckChanged(
      {required this.checkedApps, required this.isUserApps});

  @override
  List<Object?> get props => [checkedApps, isUserApps];
}

class ManageAppsExportStatusChanged extends ManageAppsEvent {
  final ManageAppsExportApksStatusUnit status;

  const ManageAppsExportStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class ManageAppsCancelExport extends ManageAppsEvent {
  const ManageAppsCancelExport();
}

class ManageAppsKeyWordChanged extends ManageAppsEvent {
  final String keyword;

  const ManageAppsKeyWordChanged(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class ManageAppsItemCountChanged extends ManageAppsEvent {
  final ManageAppsItemCount itemCount;

  const ManageAppsItemCountChanged(this.itemCount);

  @override
  List<Object?> get props => [itemCount];
}

class ManageAppsTabChanged extends ManageAppsEvent {
  final ManageAppsTab tab;

  const ManageAppsTabChanged(this.tab);

  @override
  List<Object?> get props => [tab];
}

class ManageAppsOpenContextMenu extends ManageAppsEvent {
  final bool isUserApp;
  final ManageAppContextMenuInfo info;

  const ManageAppsOpenContextMenu({required this.isUserApp, required this.info});

  @override
  List<Object?> get props => [info];
}
