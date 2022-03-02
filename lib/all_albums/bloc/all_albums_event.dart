part of 'all_albums_bloc.dart';

class AllAlbumsEvent extends Equatable {
  const AllAlbumsEvent();

  @override
  List<Object?> get props => [];
}

class AllAlbumSubscriptionRequested extends AllAlbumsEvent {
  const AllAlbumSubscriptionRequested();
}

class AllAlbumsCheckedChanged extends AllAlbumsEvent {
  final AlbumItem album;

  const AllAlbumsCheckedChanged(this.album);

  @override
  List<Object?> get props => [album];
}

class AllAlbumsKeyStatusChanged extends AllAlbumsEvent {
  final AllAlbumsBoardKeyStatus keyStatus;

  const AllAlbumsKeyStatusChanged(this.keyStatus);

  @override
  List<Object?> get props => [this.keyStatus];
}

enum ShortcutKey { ctrlAndA }

class AllAlbumsShortcutKeyTriggered extends AllAlbumsEvent {
  final ShortcutKey shortcutKey;

  const AllAlbumsShortcutKeyTriggered(this.shortcutKey);

  @override
  List<Object?> get props => [this.shortcutKey];
}

class AllAlbumsClearChecked extends AllAlbumsEvent {
  const AllAlbumsClearChecked();
}

class AllAlbumsMenuStatusChanged extends AllAlbumsEvent {
  final AllAlbumsOpenMenuStatus status;

  const AllAlbumsMenuStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class AllAlbumsImagesRequested extends AllAlbumsEvent {
  final AlbumItem album;

  const AllAlbumsImagesRequested(this.album);

  @override
  List<Object?> get props => [album];
}

class AllAlbumsOpenStatusChanged extends AllAlbumsEvent {
  final bool isOpened;
  final AlbumItem? current;

  const AllAlbumsOpenStatusChanged({required this.isOpened, this.current = null});

  @override
  List<Object?> get props => [isOpened, current];
}

class AllAlbumsImageCheckedChanged extends AllAlbumsEvent {
  final ImageItem image;

  const AllAlbumsImageCheckedChanged(this.image);

  @override
  List<Object?> get props => [image];
}

class AllAlbumsImageClearChecked extends AllAlbumsEvent {
  const AllAlbumsImageClearChecked();
}

class AllAlbumsClearDeletedImage extends AllAlbumsEvent {
  final ImageItem image;

  const AllAlbumsClearDeletedImage(this.image);
}

class AllAlbumsDeleteSubmitted extends AllAlbumsEvent {
  final List<AlbumItem> albums;

  const AllAlbumsDeleteSubmitted(this.albums);

  List<Object?> get props => [this.albums];
}

class AllAlbumsCopySubmitted extends AllAlbumsEvent {
  final List<AlbumItem> albums;
  final String dir;

  const AllAlbumsCopySubmitted(this.albums, this.dir);

  @override
  List<Object?> get props => [albums, dir];
}

class AllAlbumsCopyStatusChanged extends AllAlbumsEvent {
  final AllAlbumsCopyStatusUnit status;

  const AllAlbumsCopyStatusChanged(this.status);
}

class AllAlbumsCancelCopySubmitted extends AllAlbumsEvent {
  const AllAlbumsCancelCopySubmitted();
}

class AllAlbumsDeleteImagesSubmitted extends AllAlbumsEvent {
  final List<ImageItem> images;

  const AllAlbumsDeleteImagesSubmitted(this.images);

  List<Object?> get props => [this.images];
}

class AllAlbumsCopyImagesSubmitted extends AllAlbumsEvent {
  final List<ImageItem> images;
  final String dir;

  const AllAlbumsCopyImagesSubmitted(this.images, this.dir);

  @override
  List<Object?> get props => [images, dir];
}