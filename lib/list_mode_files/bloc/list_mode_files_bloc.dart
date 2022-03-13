import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'list_mode_files_event.dart';
part 'list_mode_files_state.dart';

class ListModeFilesBloc extends Bloc<ListModeFilesEvent, ListModeFilesState> {
  ListModeFilesBloc() : super(ListModeFilesState());

}