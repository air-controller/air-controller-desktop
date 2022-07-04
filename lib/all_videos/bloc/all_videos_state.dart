part of 'all_videos_bloc.dart';

enum AllVideosStatus { initial, loading, success, failure }

enum AllVideosBoardKeyStatus { none, ctrlDown, shiftDown }

class AllVideosOpenMenuStatus extends Equatable {
  final bool isOpened;
  final Offset? position;
  final dynamic target;

  const AllVideosOpenMenuStatus(
      {this.isOpened = false, this.position = null, this.target = null});

  @override
  List<Object?> get props => [isOpened, position, target];
}

enum AllVideosDeleteStatus { initial, loading, success, failure }

class AllVideosDeleteStatusUnit extends Equatable {
  final AllVideosDeleteStatus status;
  final List<VideoItem> videos;
  final String? failureReason;

  const AllVideosDeleteStatusUnit(
      {this.status = AllVideosDeleteStatus.initial,
      this.videos = const [],
      this.failureReason = null});

  @override
  List<Object?> get props => [status, failureReason, videos];
}

enum AllVideosCopyStatus { initial, start, copying, success, failure }

class AllVideosCopyStatusUnit extends Equatable {
  final AllVideosCopyStatus status;
  final int current;
  final int total;
  final String fileName;
  final String? error;

  const AllVideosCopyStatusUnit(
      {this.status = AllVideosCopyStatus.initial,
      this.current = 0,
      this.total = 0,
      this.fileName = '',
      this.error});

  @override
  List<Object?> get props => [status, current, total, fileName, error];
}

enum AllVideosUploadStatus { initial, start, uploading, failure, success }

class AllVideosUploadStatusUnit extends Equatable {
  final AllVideosUploadStatus status;
  final int total;
  final int current;
  final List<File> photos;
  final String? failureReason;

  const AllVideosUploadStatusUnit(
      {this.status = AllVideosUploadStatus.initial,
      this.total = 1,
      this.current = 0,
      this.photos = const [],
      this.failureReason});

  @override
  List<Object?> get props => [status, total, current, photos, failureReason];

  AllVideosUploadStatusUnit copyWith(
      {AllVideosUploadStatus? status,
      int? total,
      int? current,
      List<File>? photos,
      String? failureReason}) {
    return AllVideosUploadStatusUnit(
        status: status ?? this.status,
        current: current ?? this.current,
        total: total ?? this.total,
        photos: photos ?? this.photos,
        failureReason: failureReason ?? this.failureReason);
  }
}

class AllVideosState extends Equatable {
  final AllVideosStatus status;
  final List<VideoItem> videos;
  final List<VideoItem> checkedVideos;
  final String? failureReason;
  final AllVideosBoardKeyStatus keyStatus;
  final AllVideosOpenMenuStatus openMenuStatus;
  final AllVideosDeleteStatusUnit deleteStatus;
  final AllVideosCopyStatusUnit copyStatus;
  final AllVideosUploadStatusUnit uploadStatus;

  const AllVideosState(
      {this.status = AllVideosStatus.initial,
      this.videos = const [],
      this.checkedVideos = const [],
      this.failureReason = null,
      this.keyStatus = AllVideosBoardKeyStatus.none,
      this.openMenuStatus = const AllVideosOpenMenuStatus(),
      this.deleteStatus = const AllVideosDeleteStatusUnit(),
      this.copyStatus = const AllVideosCopyStatusUnit(),
      this.uploadStatus = const AllVideosUploadStatusUnit()});

  @override
  List<Object?> get props => [
        status,
        videos,
        checkedVideos,
        failureReason,
        keyStatus,
        openMenuStatus,
        deleteStatus,
        copyStatus,
        uploadStatus
      ];

  AllVideosState copyWith(
      {AllVideosStatus? status,
      List<VideoItem>? videos,
      List<VideoItem>? checkedVideos,
      String? failureReason,
      AllVideosBoardKeyStatus? keyStatus,
      AllVideosOpenMenuStatus? openMenuStatus,
      AllVideosDeleteStatusUnit? deleteStatus,
      AllVideosCopyStatusUnit? copyStatus,
      AllVideosUploadStatusUnit? uploadStatus}) {
    return AllVideosState(
        status: status ?? this.status,
        videos: videos ?? this.videos,
        checkedVideos: checkedVideos ?? this.checkedVideos,
        failureReason: failureReason ?? this.failureReason,
        keyStatus: keyStatus ?? this.keyStatus,
        openMenuStatus: openMenuStatus ?? this.openMenuStatus,
        deleteStatus: deleteStatus ?? this.deleteStatus,
        copyStatus: copyStatus ?? this.copyStatus,
        uploadStatus: uploadStatus ?? this.uploadStatus);
  }
}
