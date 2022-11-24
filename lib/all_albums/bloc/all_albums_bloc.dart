import 'dart:async';
import 'dart:io';

import 'package:air_controller/constant.dart';
import 'package:air_controller/util/common_util.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/album_item.dart';
import '../../model/image_item.dart';
import '../../repository/file_repository.dart';
import '../../repository/image_repository.dart';

part 'all_albums_event.dart';
part 'all_albums_state.dart';

class AllAlbumsBloc extends Bloc<AllAlbumsEvent, AllAlbumsState> {
  final ImageRepository _imageRepository;
  final FileRepository _fileRepository;

  AllAlbumsBloc(
      {required ImageRepository imageRepository,
      required FileRepository fileRepository})
      : _imageRepository = imageRepository,
        _fileRepository = fileRepository,
        super(AllAlbumsState()) {
    on<AllAlbumSubscriptionRequested>(_onSubscriptionRequested);
    on<AllAlbumsCheckedChanged>(_onCheckedAlbumChanged);
    on<AllAlbumsKeyStatusChanged>(_onKeyStatusChanged);
    on<AllAlbumsShortcutKeyTriggered>(_onShortcutKeyTriggered);
    on<AllAlbumsClearChecked>(_onClearChecked);
    on<AllAlbumsMenuStatusChanged>(_onMenuStatusChanged);
    on<AllAlbumsImagesRequested>(_onAlbumImagesRequested);
    on<AllAlbumsOpenStatusChanged>(_onAlbumOpenStatusChanged);
    on<AllAlbumsImageCheckedChanged>(_onCheckedImageChanged);
    on<AllAlbumsImageClearChecked>(_onImageClearChecked);
    on<AllAlbumsClearDeletedImage>(_onClearDeletedImage);
    on<AllAlbumsDeleteSubmitted>(_onDeleteSubmitted);
    on<AllAlbumsCopySubmitted>(_onCopyAlbumsSubmitted);
    on<AllAlbumsCancelCopySubmitted>(_onCancelCopySubmitted);
    on<AllAlbumsCopyStatusChanged>(_onCopyAlbumsStatusChanged);
    on<AllAlbumsDeleteImagesSubmitted>(_onDeleteImagesSubmitted);
    on<AllAlbumsCopyImagesSubmitted>(_onCopyImagesSubmitted);
    on<AllAlbumsUploadPhotos>(_onUploadPhotos);
    on<AllAlbumsUploadStatusChanged>(_onUploadStatusChanged);
    on<AllAlbumsDownloadAlbumsToLocal>(_onDownloadAlbumsToLocal);
    on<AllAlbumsDownloadImagesToLocal>(_onDownloadImagesToLocal);
  }

  void _onSubscriptionRequested(
      AllAlbumSubscriptionRequested event, Emitter<AllAlbumsState> emit) async {
    emit(state.copyWith(status: AllAlbumsStatus.loading));

    try {
      List<AlbumItem> albums = await _imageRepository.getAllAlbums();
      emit(state.copyWith(albums: albums, status: AllAlbumsStatus.success));
    } on Exception catch (e) {
      emit(state.copyWith(
          status: AllAlbumsStatus.failure,
          failureReason: CommonUtil.convertHttpError(e)));
    }
  }

  void _onCheckedAlbumChanged(
      AllAlbumsCheckedChanged event, Emitter<AllAlbumsState> emit) {
    List<AlbumItem> albums = state.albums;
    List<AlbumItem> checkedAlbums = [...state.checkedAlbums];
    AlbumItem album = event.album;

    AllAlbumsBoardKeyStatus keyStatus = state.keyStatus;

    if (!checkedAlbums.contains(album)) {
      if (keyStatus == AllAlbumsBoardKeyStatus.ctrlDown) {
        checkedAlbums.add(album);
      } else if (keyStatus == AllAlbumsBoardKeyStatus.shiftDown) {
        if (checkedAlbums.length == 0) {
          checkedAlbums.add(album);
        } else if (checkedAlbums.length == 1) {
          int index = checkedAlbums.indexOf(checkedAlbums[0]);

          int current = albums.indexOf(album);

          if (current > index) {
            checkedAlbums = albums.sublist(index, current + 1);
          } else {
            checkedAlbums = albums.sublist(index, current + 1);
          }
        } else {
          int maxIndex = 0;
          int minIndex = 0;

          for (int i = 0; i < checkedAlbums.length; i++) {
            AlbumItem current = checkedAlbums[i];
            int index = albums.indexOf(current);
            if (index < 0) {
              continue;
            }

            if (index > maxIndex) {
              maxIndex = index;
            }

            if (index < minIndex) {
              minIndex = index;
            }
          }

          int current = albums.indexOf(album);

          if (current >= minIndex && current <= maxIndex) {
            checkedAlbums = albums.sublist(current, maxIndex + 1);
          } else if (current < minIndex) {
            checkedAlbums = albums.sublist(current, maxIndex + 1);
          } else if (current > maxIndex) {
            checkedAlbums = albums.sublist(minIndex, current + 1);
          }
        }
      } else {
        checkedAlbums.clear();
        checkedAlbums.add(album);
      }
    } else {
      if (keyStatus == AllAlbumsBoardKeyStatus.ctrlDown) {
        checkedAlbums.remove(album);
      } else if (keyStatus == AllAlbumsBoardKeyStatus.shiftDown) {
        checkedAlbums.remove(album);
      }
    }

    emit(state.copyWith(checkedAlbums: checkedAlbums));
  }

  void _onKeyStatusChanged(
      AllAlbumsKeyStatusChanged event, Emitter<AllAlbumsState> emit) {
    emit(state.copyWith(keyStatus: event.keyStatus));
  }

  void _onShortcutKeyTriggered(
      AllAlbumsShortcutKeyTriggered event, Emitter<AllAlbumsState> emit) {
    if (state.albumOpenStatus.isOpened) {
      emit(state.copyWith(
          loadImagesInAlbumStatus: state.loadImagesInAlbumStatus
              .copyWith(checkedImages: state.loadImagesInAlbumStatus.images)));
    } else {
      emit(state.copyWith(checkedAlbums: state.albums));
    }
  }

  void _onClearChecked(
      AllAlbumsClearChecked event, Emitter<AllAlbumsState> emit) {
    emit(state.copyWith(checkedAlbums: []));
  }

  void _onMenuStatusChanged(
      AllAlbumsMenuStatusChanged event, Emitter<AllAlbumsState> emit) {
    emit(state.copyWith(openMenuStatus: event.status));
  }

  void _onAlbumImagesRequested(
      AllAlbumsImagesRequested event, Emitter<AllAlbumsState> emit) async {
    emit(state.copyWith(
        loadImagesInAlbumStatus: state.loadImagesInAlbumStatus
            .copyWith(status: LoadImagesInAlbumStatus.loading)));

    try {
      List<ImageItem> images =
          await _imageRepository.getImagesInAlbum(event.album);

      emit(state.copyWith(
          loadImagesInAlbumStatus: state.loadImagesInAlbumStatus.copyWith(
              status: LoadImagesInAlbumStatus.success, images: images)));
    } on Exception catch (e) {
      emit(state.copyWith(
          loadImagesInAlbumStatus: state.loadImagesInAlbumStatus.copyWith(
              status: LoadImagesInAlbumStatus.failure,
              error: CommonUtil.convertHttpError(e))));
    }
  }

  void _onAlbumOpenStatusChanged(
      AllAlbumsOpenStatusChanged event, Emitter<AllAlbumsState> emit) {
    if (event.isOpened) {
      emit(state.copyWith(
          albumOpenStatus: AlbumOpenStatus(
              isOpened: event.isOpened, current: event.current)));
    } else {
      emit(state.copyWith(
          albumOpenStatus:
              AlbumOpenStatus(isOpened: event.isOpened, current: event.current),
          loadImagesInAlbumStatus: state.loadImagesInAlbumStatus
              .copyWith(checkedImages: [], images: [])));
    }
  }

  void _onCheckedImageChanged(
      AllAlbumsImageCheckedChanged event, Emitter<AllAlbumsState> emit) {
    List<ImageItem> allImages = state.loadImagesInAlbumStatus.images;
    List<ImageItem> checkedImages = [
      ...state.loadImagesInAlbumStatus.checkedImages
    ];
    ImageItem image = event.image;

    AllAlbumsBoardKeyStatus keyStatus = state.keyStatus;

    if (!checkedImages.contains(image)) {
      if (keyStatus == AllAlbumsBoardKeyStatus.ctrlDown) {
        checkedImages.add(image);
      } else if (keyStatus == AllAlbumsBoardKeyStatus.shiftDown) {
        if (checkedImages.length == 0) {
          checkedImages.add(image);
        } else if (checkedImages.length == 1) {
          int index = allImages.indexOf(checkedImages[0]);

          int current = allImages.indexOf(image);

          if (current > index) {
            checkedImages = allImages.sublist(index, current + 1);
          } else {
            checkedImages = allImages.sublist(current, index + 1);
          }
        } else {
          int maxIndex = 0;
          int minIndex = 0;

          for (int i = 0; i < checkedImages.length; i++) {
            ImageItem current = checkedImages[i];
            int index = allImages.indexOf(current);
            if (index < 0) {
              continue;
            }

            if (index > maxIndex) {
              maxIndex = index;
            }

            if (index < minIndex) {
              minIndex = index;
            }
          }

          int current = allImages.indexOf(image);

          if (current >= minIndex && current <= maxIndex) {
            checkedImages = allImages.sublist(current, maxIndex + 1);
          } else if (current < minIndex) {
            checkedImages = allImages.sublist(current, maxIndex + 1);
          } else if (current > maxIndex) {
            checkedImages = allImages.sublist(minIndex, current + 1);
          }
        }
      } else {
        checkedImages.clear();
        checkedImages.add(image);
      }
    } else {
      if (keyStatus == AllAlbumsBoardKeyStatus.ctrlDown) {
        checkedImages.remove(image);
      } else if (keyStatus == AllAlbumsBoardKeyStatus.shiftDown) {
        checkedImages.remove(image);
      } else {
        checkedImages.clear();
        checkedImages.add(image);
      }
    }

    emit(state.copyWith(
        loadImagesInAlbumStatus: state.loadImagesInAlbumStatus
            .copyWith(checkedImages: checkedImages)));
  }

  void _onImageClearChecked(
      AllAlbumsImageClearChecked event, Emitter<AllAlbumsState> emit) {
    emit(state.copyWith(
        loadImagesInAlbumStatus:
            state.loadImagesInAlbumStatus.copyWith(checkedImages: [])));
  }

  void _onClearDeletedImage(
      AllAlbumsClearDeletedImage event, Emitter<AllAlbumsState> emit) {
    List<ImageItem> images = [...state.loadImagesInAlbumStatus.images];
    List<ImageItem> checkedImages = [
      ...state.loadImagesInAlbumStatus.checkedImages
    ];

    images.removeWhere((image) => image.id == event.image.id);
    checkedImages.removeWhere((image) => image.id == event.image.id);

    emit(state.copyWith(
        loadImagesInAlbumStatus: state.loadImagesInAlbumStatus
            .copyWith(images: images, checkedImages: checkedImages)));
  }

  void _onDeleteSubmitted(
      AllAlbumsDeleteSubmitted event, Emitter<AllAlbumsState> emit) async {
    emit(state.copyWith(
        deleteAlbumStatus:
            AllAlbumsDeleteStatusUnit(status: AllAlbumsDeleteStatus.loading)));

    try {
      await _fileRepository
          .deleteFiles(event.albums.map((album) => album.path).toList());

      List<AlbumItem> albums = [...state.albums];
      List<AlbumItem> checkedAlbums = [...state.checkedAlbums];

      albums.removeWhere((album) => event.albums.contains(album));
      checkedAlbums.removeWhere((album) => event.albums.contains(album));

      emit(state.copyWith(
          albums: albums,
          checkedAlbums: checkedAlbums,
          deleteAlbumStatus: AllAlbumsDeleteStatusUnit(
              status: AllAlbumsDeleteStatus.success, albums: albums)));
    } on Exception catch (e) {
      emit(state.copyWith(
          deleteAlbumStatus: AllAlbumsDeleteStatusUnit(
              status: AllAlbumsDeleteStatus.failure,
              failureReason: CommonUtil.convertHttpError(e))));
    }
  }

  void _onCopyAlbumsSubmitted(
      AllAlbumsCopySubmitted event, Emitter<AllAlbumsState> emit) {
    emit(state.copyWith(
        copyStatus: AllAlbumsCopyStatusUnit(
            fileType: AllAlbumsFileType.album,
            status: AllAlbumsCopyStatus.start)));

    String? fileName = null;

    if (event.albums.length == 1) {
      fileName = "${event.albums.single.name}.zip";
    }

    _fileRepository.copyFilesTo(
        fileName: fileName,
        paths: event.albums.map((album) => album.path).toList(),
        dir: event.dir,
        onProgress: (fileName, current, total) {
          add(AllAlbumsCopyStatusChanged(AllAlbumsCopyStatusUnit(
              fileType: AllAlbumsFileType.album,
              status: AllAlbumsCopyStatus.copying,
              fileName: fileName,
              current: current,
              total: total)));
        },
        onDone: (fileName) {
          add(AllAlbumsCopyStatusChanged(AllAlbumsCopyStatusUnit(
              fileType: AllAlbumsFileType.album,
              status: AllAlbumsCopyStatus.success,
              fileName: fileName)));
        },
        onError: (String error) {
          add(AllAlbumsCopyStatusChanged(AllAlbumsCopyStatusUnit(
              fileType: AllAlbumsFileType.album,
              status: AllAlbumsCopyStatus.failure,
              error: error)));
        });
  }

  void _onCancelCopySubmitted(
      AllAlbumsCancelCopySubmitted event, Emitter<AllAlbumsState> emit) {
    _fileRepository.cancelCopy();
  }

  void _onCopyAlbumsStatusChanged(
      AllAlbumsCopyStatusChanged event, Emitter<AllAlbumsState> emit) {
    emit(state.copyWith(copyStatus: event.status));
  }

  void _onDeleteImagesSubmitted(AllAlbumsDeleteImagesSubmitted event,
      Emitter<AllAlbumsState> emit) async {
    emit(state.copyWith(
        deleteAlbumStatus:
            AllAlbumsDeleteStatusUnit(status: AllAlbumsDeleteStatus.loading)));

    try {
      await _fileRepository
          .deleteFiles(event.images.map((album) => album.path).toList());

      List<ImageItem> images = [...state.loadImagesInAlbumStatus.images];
      List<ImageItem> checkedImages = [
        ...state.loadImagesInAlbumStatus.checkedImages
      ];

      final album = state.albumOpenStatus.current;

      if (album != null) {
        final albums = [...state.albums];

        album.photoNum -= event.images.length;

        int index = albums.indexOf(album);
        albums[index] = album;

        if (album.photoNum <= 0) {
          albums.removeAt(index);
        }

        emit(state.copyWith(albums: albums));
      }

      images.removeWhere((image) => event.images.contains(image));
      checkedImages.removeWhere((image) => event.images.contains(image));

      emit(state.copyWith(
          loadImagesInAlbumStatus: state.loadImagesInAlbumStatus
              .copyWith(images: images, checkedImages: checkedImages)));
    } on Exception catch (e) {
      emit(state.copyWith(
          deleteAlbumStatus: AllAlbumsDeleteStatusUnit(
              status: AllAlbumsDeleteStatus.failure,
              failureReason: CommonUtil.convertHttpError(e))));
    }
  }

  void _onCopyImagesSubmitted(
      AllAlbumsCopyImagesSubmitted event, Emitter<AllAlbumsState> emit) {
    emit(state.copyWith(
        copyStatus: AllAlbumsCopyStatusUnit(
            fileType: AllAlbumsFileType.image,
            status: AllAlbumsCopyStatus.start)));

    _fileRepository.copyFilesTo(
        paths: event.images.map((album) => album.path).toList(),
        dir: event.dir,
        onProgress: (fileName, current, total) {
          add(AllAlbumsCopyStatusChanged(AllAlbumsCopyStatusUnit(
              fileType: AllAlbumsFileType.image,
              status: AllAlbumsCopyStatus.copying,
              fileName: fileName,
              current: current,
              total: total)));
        },
        onDone: (fileName) {
          add(AllAlbumsCopyStatusChanged(AllAlbumsCopyStatusUnit(
              fileType: AllAlbumsFileType.image,
              status: AllAlbumsCopyStatus.success,
              fileName: fileName)));
        },
        onError: (String error) {
          add(AllAlbumsCopyStatusChanged(AllAlbumsCopyStatusUnit(
              fileType: AllAlbumsFileType.image,
              status: AllAlbumsCopyStatus.failure,
              error: error)));
        });
  }

  void _onUploadPhotos(
      AllAlbumsUploadPhotos event, Emitter<AllAlbumsState> emit) {
    emit(state.copyWith(
        uploadStatus: state.uploadStatus.copyWith(
            status: AllAlbumsUploadStatus.start, photos: event.photos)));

    _imageRepository.uploadPhotos(
        pos: Constant.posAlbumPictures,
        photos: event.photos,
        path: event.album.path,
        onError: (error) {
          add(AllAlbumsUploadStatusChanged(
              status: state.uploadStatus.copyWith(
                  status: AllAlbumsUploadStatus.failure, failureReason: error),
              album: event.album));
        },
        onUploading: (sent, total) {
          add(AllAlbumsUploadStatusChanged(
              status: state.uploadStatus.copyWith(
                  status: AllAlbumsUploadStatus.uploading,
                  current: sent,
                  total: total),
              album: event.album));
        },
        onSuccess: (images) {
          add(AllAlbumsUploadStatusChanged(
              status: state.uploadStatus.copyWith(
                  status: AllAlbumsUploadStatus.success, images: images),
              album: event.album,
              images: images));
        });
  }

  void _onUploadStatusChanged(
      AllAlbumsUploadStatusChanged event, Emitter<AllAlbumsState> emit) async {
    final isAlbumOpened = state.albumOpenStatus.isOpened;

    if (isAlbumOpened) {
      if (event.status.status == AllAlbumsUploadStatus.success) {
        final images = [...state.loadImagesInAlbumStatus.images];
        List<ImageItem>? uploadedImages = event.images;

        if (uploadedImages != null && uploadedImages.isNotEmpty) {
          images.addAll(uploadedImages);
        }

        final album = event.album;

        final albums = [...state.albums];
        final photos = event.status.photos;
        album.photoNum += photos.length;

        int index = albums.indexOf(album);
        albums[index] = album;

        emit(state.copyWith(
            albums: albums,
            loadImagesInAlbumStatus: state.loadImagesInAlbumStatus.copyWith(
                status: LoadImagesInAlbumStatus.success, images: images)));
      }
    } else {
      if (event.status.status == AllAlbumsUploadStatus.success) {
        final album = event.album;

        final albums = [...state.albums];
        final photos = event.status.photos;
        album.photoNum += photos.length;

        int index = albums.indexOf(album);
        albums[index] = album;
        emit(state.copyWith(albums: albums));
      }
    }

    emit(state.copyWith(uploadStatus: event.status));
  }

  FutureOr<void> _onDownloadAlbumsToLocal(AllAlbumsDownloadAlbumsToLocal event,
      Emitter<AllAlbumsState> emit) async {
    emit(state.copyWith(showLoading: true));

    try {
      final bytes = await _imageRepository.readAlbumsAsBytes(event.albums);

      String fileName = "";
      if (event.albums.length == 1) {
        fileName = "${event.albums.first.path.split("/").last}.zip";
      } else if (event.albums.length > 1) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        fileName = "albums_$timestamp.zip";
      }
      CommonUtil.downloadAsWebFile(bytes: bytes, fileName: fileName);
      emit(state.copyWith(showLoading: false));
    } catch (e) {
      emit(state.copyWith(
          showLoading: false, showError: true, errorMessage: e.toString()));
    }
  }

  FutureOr<void> _onDownloadImagesToLocal(AllAlbumsDownloadImagesToLocal event,
      Emitter<AllAlbumsState> emit) async {
    emit(state.copyWith(showLoading: true));

    try {
      final bytes = await _imageRepository.readImagesAsBytes(event.images);

      String fileName = "";
      if (event.images.length == 1) {
        fileName = "${event.images.first.path.split("/").last}";
      } else if (event.images.length > 1) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        fileName = "images_$timestamp.zip";
      }
      CommonUtil.downloadAsWebFile(bytes: bytes, fileName: fileName);
      emit(state.copyWith(showLoading: false));
    } catch (e) {
      emit(state.copyWith(
          showLoading: false, showError: true, errorMessage: e.toString()));
    }
  }
}
