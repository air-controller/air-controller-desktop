part of 'all_albums_bloc.dart';

enum AllAlbumsStatus { initial, loading, success, failure }

enum LoadImagesInAlbumStatus { initial, loading, success, failure }

enum AllAlbumsBoardKeyStatus { none, ctrlDown, shiftDown }

enum AllAlbumsDeleteStatus { initial, loading, success, failure }

class AllAlbumsDeleteStatusUnit extends Equatable {
  final AllAlbumsDeleteStatus status;
  final List<AlbumItem> albums;
  final String? failureReason;

  const AllAlbumsDeleteStatusUnit({
    this.status = AllAlbumsDeleteStatus.initial,
    this.albums = const [],
    this.failureReason = null
  });

  @override
  List<Object?> get props => [status, failureReason, albums];
}

enum AllAlbumsCopyStatus { initial, start, copying, success, failure }

enum AllAlbumsFileType { image, album }

class AllAlbumsCopyStatusUnit extends Equatable {
  final AllAlbumsFileType fileType;
  final AllAlbumsCopyStatus status;
  final int current;
  final int total;
  final String fileName;
  final String? error;

  const AllAlbumsCopyStatusUnit({
    required this.fileType,
    this.status = AllAlbumsCopyStatus.initial,
    this.current = 0,
    this.total = 0,
    this.fileName = '',
    this.error
  });

  @override
  List<Object?> get props => [fileType, status, current, total, fileName, error];
}


class AllAlbumsOpenMenuStatus extends Equatable {
  final bool isOpened;
  final Offset? position;
  final dynamic target;

  const AllAlbumsOpenMenuStatus(
      {this.isOpened = false, this.position = null, this.target = null});

  @override
  List<Object?> get props => [isOpened, position, target];
}

class LoadImagesInAlbumStatusUnit extends Equatable {
  final LoadImagesInAlbumStatus status;
  final List<ImageItem> images;
  final List<ImageItem> checkedImages;
  final String? error;

  const LoadImagesInAlbumStatusUnit(
      {this.status = LoadImagesInAlbumStatus.initial,
        this.images = const [],
        this.checkedImages = const [],
        this.error
      });

  @override
  List<Object?> get props => [status, images, checkedImages, error];

  LoadImagesInAlbumStatusUnit copyWith({LoadImagesInAlbumStatus? status,
    List<ImageItem>? images,
    List<ImageItem>? checkedImages,
    String? error
  }) {
    return LoadImagesInAlbumStatusUnit(
        status: status ?? this.status,
        images: images ?? this.images,
        checkedImages: checkedImages ?? this.checkedImages,
        error: error ?? this.error
    );
  }
}

class AlbumOpenStatus extends Equatable {
  final bool isOpened;
  final AlbumItem? current;

  const AlbumOpenStatus({this.isOpened = false, this.current = null});

  @override
  List<Object?> get props => [isOpened, current];
}

class AllAlbumsState extends Equatable {
  final List<AlbumItem> albums;
  final List<AlbumItem> checkedAlbums;
  final AllAlbumsStatus status;
  final String? failureReason;
  final AlbumOpenStatus albumOpenStatus;
  final LoadImagesInAlbumStatusUnit loadImagesInAlbumStatus;
  final AllAlbumsBoardKeyStatus keyStatus;
  final AllAlbumsOpenMenuStatus openMenuStatus;
  final AllAlbumsDeleteStatusUnit deleteAlbumStatus;
  final AllAlbumsCopyStatusUnit copyStatus;

  const AllAlbumsState({this.albums = const [],
    this.checkedAlbums = const [],
    this.status = AllAlbumsStatus.initial,
    this.failureReason,
    this.albumOpenStatus = const AlbumOpenStatus(),
    this.loadImagesInAlbumStatus = const LoadImagesInAlbumStatusUnit(),
    this.keyStatus = AllAlbumsBoardKeyStatus.none,
    this.openMenuStatus = const AllAlbumsOpenMenuStatus(),
    this.deleteAlbumStatus = const AllAlbumsDeleteStatusUnit(),
    this.copyStatus = const AllAlbumsCopyStatusUnit(fileType: AllAlbumsFileType.album)
  });

  @override
  List<Object?> get props =>
      [
        albums,
        checkedAlbums,
        status,
        failureReason,
        albumOpenStatus,
        loadImagesInAlbumStatus,
        keyStatus,
        openMenuStatus,
        deleteAlbumStatus,
        copyStatus
      ];

  AllAlbumsState copyWith({List<AlbumItem>? albums,
    List<AlbumItem>? checkedAlbums,
    AllAlbumsStatus? status,
    String? failureReason,
    AlbumOpenStatus? albumOpenStatus,
    LoadImagesInAlbumStatusUnit? loadImagesInAlbumStatus,
    AllAlbumsBoardKeyStatus? keyStatus,
    AllAlbumsOpenMenuStatus? openMenuStatus,
    AllAlbumsDeleteStatusUnit? deleteAlbumStatus,
    AllAlbumsCopyStatusUnit? copyStatus}) {
    return AllAlbumsState(
        albums: albums ?? this.albums,
        checkedAlbums: checkedAlbums ?? this.checkedAlbums,
        status: status ?? this.status,
        failureReason: failureReason ?? this.failureReason,
        albumOpenStatus: albumOpenStatus ?? this.albumOpenStatus,
        loadImagesInAlbumStatus:
        loadImagesInAlbumStatus ?? this.loadImagesInAlbumStatus,
        keyStatus: keyStatus ?? this.keyStatus,
        openMenuStatus: openMenuStatus ?? this.openMenuStatus,
        deleteAlbumStatus: deleteAlbumStatus ?? this.deleteAlbumStatus,
      copyStatus: copyStatus ?? this.copyStatus
    );
  }
}
