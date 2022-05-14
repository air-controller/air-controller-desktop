import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'manage_apps_event.dart';
part 'manage_apps_state.dart';

class ManageAppsBloc extends Bloc<ManageAppsEvent, ManageAppsState> {
  ManageAppsBloc() : super(ManageAppsState());
}
