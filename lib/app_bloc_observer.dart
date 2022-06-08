import 'package:bloc/bloc.dart';

import 'bootstrap.dart';
import 'constant.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);

    if (Constant.ENABLE_BLOC_LOG) {
      logger.d('onChange(${bloc.runtimeType}, $change)');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (Constant.ENABLE_BLOC_LOG) {
      logger.d('onError(${bloc.runtimeType}, $error, $stackTrace)');
    }
    super.onError(bloc, error, stackTrace);
  }
}
