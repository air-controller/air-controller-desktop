part of 'all_videos_bloc.dart';

class AllVideosEvent extends Equatable {
  const AllVideosEvent();

  @override
  List<Object?> get props => [];
}

class AllVideosSubscriptionRequested extends AllVideosEvent {
  const AllVideosSubscriptionRequested();
}

class AllVideosCheckedChanged extends AllVideosEvent {
  final VideoItem video;

  const AllVideosCheckedChanged(this.video);

  @override
  List<Object?> get props => [video];
}

class AllVideosKeyStatusChanged extends AllVideosEvent {
  final AllVideosBoardKeyStatus keyStatus;

  const AllVideosKeyStatusChanged(this.keyStatus);

  @override
  List<Object?> get props => [keyStatus];
}

class AllVideosClearChecked extends AllVideosEvent {
  const AllVideosClearChecked();
}

class AllVideosCheckAll extends AllVideosEvent {
  const AllVideosCheckAll();
}

class AllVideosOpenMenuStatusChanged extends AllVideosEvent {
  final AllVideosOpenMenuStatus status;

  const AllVideosOpenMenuStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class AllVideosDeleteSubmitted extends AllVideosEvent {
  final List<VideoItem> videos;

  const AllVideosDeleteSubmitted(this.videos);

  @override
  List<Object?> get props => [videos];
}

class AllVideosCopySubmitted extends AllVideosEvent {
  final List<VideoItem> videos;
  final String dir;

  const AllVideosCopySubmitted(this.videos, this.dir);

  @override
  List<Object?> get props => [videos, dir];
}

class AllVideosCopyStatusChanged extends AllVideosEvent {
  final AllVideosCopyStatusUnit status;

  const AllVideosCopyStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class AllVideosCancelCopy extends AllVideosEvent {
  const AllVideosCancelCopy();
}

class AllVideosUploadVideos extends AllVideosEvent {
  final List<File> videos;

  const AllVideosUploadVideos(this.videos);

  @override
  List<Object?> get props => [videos];
}

class AllVideosUploadStatusChanged extends AllVideosEvent {
  final AllVideosUploadStatusUnit status;

  const AllVideosUploadStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class AllVideosDownloadToLocal extends AllVideosEvent {
  final List<VideoItem> videos;

  const AllVideosDownloadToLocal(this.videos);

  @override
  List<Object?> get props => [videos];
}