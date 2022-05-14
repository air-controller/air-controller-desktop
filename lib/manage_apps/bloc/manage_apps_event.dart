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
