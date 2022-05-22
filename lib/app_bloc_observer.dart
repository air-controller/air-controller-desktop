import 'dart:developer';

import 'package:air_controller/enter/enter.dart';
import 'package:air_controller/manage_apps/manage_apps.dart';
import 'package:bloc/bloc.dart';

import 'bootstrap.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is EnterBloc) return;

    if (bloc is ManageAppsHomeBloc) {
      return;
    }

    logger.d('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    logger.d('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}
