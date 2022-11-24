part of 'music_home_bloc.dart';

class MusicHomeEvent extends Equatable {
  const MusicHomeEvent();

  @override
  List<Object?> get props => [];
}

class MusicHomeSubscriptionRequested extends MusicHomeEvent {
  const MusicHomeSubscriptionRequested();
}

class MusicHomeCheckedChanged extends MusicHomeEvent {
  final AudioItem music;

  const MusicHomeCheckedChanged(this.music);

  @override
  List<Object?> get props => [music];
}

class MusicHomeKeyStatusChanged extends MusicHomeEvent {
  final MusicHomeBoardKeyStatus keyStatus;

  const MusicHomeKeyStatusChanged(this.keyStatus);

  @override
  List<Object?> get props => [this.keyStatus];
}

class MusicHomeCheckAll extends MusicHomeEvent {
  const MusicHomeCheckAll();
}

class MusicHomeClearChecked extends MusicHomeEvent {
  const MusicHomeClearChecked();
}

class MusicHomeMenuStatusChanged extends MusicHomeEvent {
  final MusicHomeOpenMenuStatus status;

  const MusicHomeMenuStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class MusicHomeDeleteSubmitted extends MusicHomeEvent {
  final List<AudioItem> musics;

  const MusicHomeDeleteSubmitted(this.musics);

  @override
  List<Object?> get props => [musics];
}

class MusicHomeCopyMusicsSubmitted extends MusicHomeEvent {
  final List<AudioItem> musics;
  final String dir;

  const MusicHomeCopyMusicsSubmitted(this.musics, this.dir);

  @override
  List<Object?> get props => [musics, dir];
}

class MusicHomeCopyStatusChanged extends MusicHomeEvent {
  final MusicHomeCopyStatusUnit status;

  const MusicHomeCopyStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class MusicHomeCancelCopySubmitted extends MusicHomeEvent {
  const MusicHomeCancelCopySubmitted();
}

class MusicHomeSortInfoChanged extends MusicHomeEvent {
  final MusicHomeSortColumn sortColumn;
  final MusicHomeSortDirection sortDirection;

  const MusicHomeSortInfoChanged(this.sortColumn, this.sortDirection);

  @override
  List<Object?> get props => [sortColumn, sortDirection];
}

class MusicHomeUploadAudios extends MusicHomeEvent {
  final List<File> audios;

  const MusicHomeUploadAudios(this.audios);

  @override
  List<Object?> get props => [audios];
}

class MusicHomeUploadStatusChanged extends MusicHomeEvent {
  final MusicHomeUploadStatusUnit status;

  const MusicHomeUploadStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class MusicHomeDownloadToLocal extends MusicHomeEvent {
  final List<AudioItem> musics;

  const MusicHomeDownloadToLocal(this.musics);

  @override
  List<Object?> get props => [musics];
}
