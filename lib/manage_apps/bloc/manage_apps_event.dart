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
  final bool isUserApps;
  final ManageAppsSortColumn sortColumn;
  final ManageAppsSortDirection sortDirection;

  const ManageAppsSortChanged(
      {this.isUserApps = true,
      required this.sortColumn,
      required this.sortDirection});

  @override
  List<Object?> get props => [isUserApps, sortColumn, sortDirection];
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

class ManageAppsUserAppCheckChanged extends ManageAppsEvent {
  final AppInfo app;

  const ManageAppsUserAppCheckChanged(this.app);

  @override
  List<Object?> get props => [app];
}

class ManageAppsKeyStatusChanged extends ManageAppsEvent {
  final ManageAppsKeyStatus keyStatus;

  const ManageAppsKeyStatusChanged(this.keyStatus);

  @override
  List<Object?> get props => [this.keyStatus];
}

class ManageAppsCtrlAStatusChanged extends ManageAppsEvent {
  final ManageAppsCtrlAStatus status;
  const ManageAppsCtrlAStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
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

class ManageAppsUserAppsKeyWordChanged extends ManageAppsEvent {
  final String keyword;

  const ManageAppsUserAppsKeyWordChanged(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class ManageAppsItemCountChanged extends ManageAppsEvent {
  final ManageAppsItemCount itemCount;

  const ManageAppsItemCountChanged(this.itemCount);

  @override
  List<Object?> get props => [itemCount];
}
