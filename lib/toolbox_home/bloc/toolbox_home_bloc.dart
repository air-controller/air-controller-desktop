import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'toolbox_home_event.dart';
part 'toolbox_home_state.dart';

class ToolboxHomeBloc extends Bloc<ToolboxHomeEvent, ToolboxHomeState> {
  ToolboxHomeBloc() : super(ToolboxHomeState());


}
