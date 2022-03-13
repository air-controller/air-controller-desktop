
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_assistant_client/grid_mode_files/bloc/grid_mode_files_event.dart';
import 'package:mobile_assistant_client/grid_mode_files/bloc/grid_mode_files_state.dart';

import '../../repository/file_repository.dart';

class GridModeFilesBloc extends Bloc<GridModeFilesEvent, GridModeFilesState> {
  final FileRepository _fileRepository;

  GridModeFilesBloc(FileRepository fileRepository) :
      _fileRepository = fileRepository,
        super(GridModeFilesState()) {
  }
}