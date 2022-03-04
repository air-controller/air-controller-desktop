part of 'music_home_bloc.dart';

enum MusicHomeStatus { initial, loading, success, failure }

enum MusicHomeSortColumn { folder, name, type, duration, size, modifyTime }

extension MusicHomeSortColumnX on MusicHomeSortColumn {
  static MusicHomeSortColumn convertToColumn(int index) {
    try {
      MusicHomeSortColumn column = MusicHomeSortColumn.values.firstWhere((
          MusicHomeSortColumn column) => column.index == index);
      return column;
    } catch (e) {
      return MusicHomeSortColumn.folder;
    }
  }
}

enum MusicHomeSortDirection { ascending, descending }

enum MusicHomeBoardKeyStatus { none, ctrlDown, shiftDown }

class MusicHomeOpenMenuStatus extends Equatable {
  final bool isOpened;
  final Offset? position;
  final dynamic target;

  const MusicHomeOpenMenuStatus(
      {this.isOpened = false, this.position = null, this.target = null});

  @override
  List<Object?> get props => [isOpened, position, target];
}

enum MusicHomeDeleteStatus { initial, loading, success, failure }

class MusicHomeDeleteStatusUnit extends Equatable {
  final MusicHomeDeleteStatus status;
  final List<AudioItem> musics;
  final String? failureReason;

  const MusicHomeDeleteStatusUnit({
    this.status = MusicHomeDeleteStatus.initial,
    this.musics = const [],
    this.failureReason = null
  });

  @override
  List<Object?> get props => [status, failureReason, musics];
}

enum MusicHomeCopyStatus { initial, start, copying, success, failure }

class MusicHomeCopyStatusUnit extends Equatable {
  final MusicHomeCopyStatus status;
  final int current;
  final int total;
  final String fileName;
  final String? error;

  const MusicHomeCopyStatusUnit({
    this.status = MusicHomeCopyStatus.initial,
    this.current = 0,
    this.total = 0,
    this.fileName = '',
    this.error
  });

  @override
  List<Object?> get props => [status, current, total, fileName, error];
}

class MusicHomeState extends Equatable {
  final List<AudioItem> musics;
  final List<AudioItem> checkedMusics;
  final MusicHomeStatus status;
  final String? failureReason;
  final MusicHomeSortColumn sortColumn;
  final MusicHomeSortDirection sortDirection;
  final MusicHomeBoardKeyStatus keyStatus;
  final MusicHomeOpenMenuStatus openMenuStatus;
  final MusicHomeDeleteStatusUnit deleteStatus;
  final MusicHomeCopyStatusUnit copyStatus;

  const MusicHomeState({
    this.musics = const [],
    this.checkedMusics = const [],
    this.status = MusicHomeStatus.initial,
    this.failureReason = '',
    this.sortColumn = MusicHomeSortColumn.folder,
    this.sortDirection = MusicHomeSortDirection.descending,
    this.keyStatus = MusicHomeBoardKeyStatus.none,
    this.openMenuStatus = const MusicHomeOpenMenuStatus(),
    this.deleteStatus = const MusicHomeDeleteStatusUnit(),
    this.copyStatus = const MusicHomeCopyStatusUnit()
  });

  @override
  List<Object?> get props =>
      [
        musics,
        checkedMusics,
        status,
        failureReason,
        sortColumn,
        sortDirection,
        keyStatus,
        openMenuStatus,
        deleteStatus,
        copyStatus
      ];

  MusicHomeState copyWith({
    List<AudioItem>? musics,
    List<AudioItem>? checkedMusics,
    MusicHomeStatus? status,
    String? failureReason,
    MusicHomeSortColumn? sortColumn,
    MusicHomeSortDirection? sortDirection,
    MusicHomeBoardKeyStatus? keyStatus,
    MusicHomeOpenMenuStatus? openMenuStatus,
    MusicHomeDeleteStatusUnit? deleteStatus,
    MusicHomeCopyStatusUnit? copyStatus
  }) {
    return MusicHomeState(
        musics: musics ?? this.musics,
        checkedMusics: checkedMusics ?? this.checkedMusics,
        status: status ?? this.status,
        failureReason: failureReason ?? this.failureReason,
        sortColumn: sortColumn ?? this.sortColumn,
        sortDirection: sortDirection ?? this.sortDirection,
      keyStatus: keyStatus ?? this.keyStatus,
      openMenuStatus: openMenuStatus ?? this.openMenuStatus,
        deleteStatus: deleteStatus ?? this.deleteStatus,
        copyStatus: copyStatus ?? this.copyStatus
    );
  }
}