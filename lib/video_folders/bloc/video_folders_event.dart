part of 'video_folders_bloc.dart';

class VideoFoldersEvent extends Equatable {
  const VideoFoldersEvent();

  @override
  List<Object?> get props => [];
}

class VideoFoldersSubscriptionRequested extends VideoFoldersEvent {
  const VideoFoldersSubscriptionRequested();
}

class VideoFoldersOpenStatusChanged extends VideoFoldersEvent {
  final VideoFolderOpenStatus status;

  const VideoFoldersOpenStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class VideoFoldersCheckedChanged extends VideoFoldersEvent {
  final VideoFolderItem videoFolder;

  const VideoFoldersCheckedChanged(this.videoFolder);

  @override
  List<Object?> get props => [videoFolder];
}

class VideoFoldersKeyStatusChanged extends VideoFoldersEvent {
  final VideoFoldersBoardKeyStatus keyStatus;

  const VideoFoldersKeyStatusChanged(this.keyStatus);

  @override
  List<Object?> get props => [this.keyStatus];
}

class VideoFoldersCheckAll extends VideoFoldersEvent {
  const VideoFoldersCheckAll();
}

class VideoFoldersClearAll extends VideoFoldersEvent {
  const VideoFoldersClearAll();
}

class VideoFoldersVideosCheckedChanged extends VideoFoldersEvent {
  final VideoItem video;

  const VideoFoldersVideosCheckedChanged(this.video);

  @override
  List<Object?> get props => [video];
}

class VideoFoldersMenuStatusChanged extends VideoFoldersEvent {
  final VideoFoldersOpenMenuStatus status;

  const VideoFoldersMenuStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class VideoFoldersDeleteSubmitted extends VideoFoldersEvent {
  final List<VideoFolderItem> videoFolders;

  const VideoFoldersDeleteSubmitted(this.videoFolders);

  @override
  List<Object?> get props => [this.videoFolders];
}

class VideoFoldersCopySubmitted extends VideoFoldersEvent {
  final List<VideoFolderItem> folders;
  final String dir;

  const VideoFoldersCopySubmitted(this.folders, this.dir);

  @override
  List<Object?> get props => [folders, dir];
}

class VideoFoldersCopyStatusChanged extends VideoFoldersEvent {
  final VideoFoldersCopyStatusUnit status;

  const VideoFoldersCopyStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class VideoFoldersCancelCopy extends VideoFoldersEvent {
  const VideoFoldersCancelCopy();
}

class VideoFoldersVideosCopySubmitted extends VideoFoldersEvent {
  final List<VideoItem> videos;
  final String dir;

  const VideoFoldersVideosCopySubmitted(this.videos, this.dir);

  @override
  List<Object?> get props => [videos, dir];
}

class VideoFoldersDeleteVideosSubmitted extends VideoFoldersEvent {
  final List<VideoItem> videos;

  const VideoFoldersDeleteVideosSubmitted(this.videos);

  List<Object?> get props => [this.videos];
}

class VideoFoldersUploadVideos extends VideoFoldersEvent {
  final VideoFolderItem? folder;
  final List<File> videos;

  const VideoFoldersUploadVideos({
    this.folder,
    required this.videos,
  });

  @override
  List<Object?> get props => [folder, videos];
}

class VideoFoldersUploadStatusChanged extends VideoFoldersEvent {
  final VideoFoldersUploadStatusUnit status;
  final int addedVideoCount;
  final VideoFolderItem? folder;

  const VideoFoldersUploadStatusChanged(
      {required this.status, this.addedVideoCount = 0, this.folder = null});

  @override
  List<Object?> get props => [status, addedVideoCount, folder];
}
