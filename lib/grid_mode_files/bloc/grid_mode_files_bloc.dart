
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/file_repository.dart';
import 'grid_mode_files_event.dart';
import 'grid_mode_files_state.dart';

class GridModeFilesBloc extends Bloc<GridModeFilesEvent, GridModeFilesState> {
  final FileRepository _fileRepository;

  GridModeFilesBloc(FileRepository fileRepository) :
      _fileRepository = fileRepository,
        super(GridModeFilesState()) {
  }
}