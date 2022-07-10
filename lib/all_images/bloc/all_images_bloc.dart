import 'dart:developer';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/image_item.dart';
import '../../repository/image_repository.dart';
import '../../util/common_util.dart';
import '../model/all_image_copy_status.dart';
import '../model/all_image_menu_arguments.dart';
import '../model/all_image_delete_status.dart';
import '../model/all_image_upload_status.dart';

part 'all_images_event.dart';
part 'all_images_state.dart';

class AllImagesBloc extends Bloc<AllImagesEvent, AllImagesState> {
  final ImageRepository _imageRepository;
  final bool _isFromCamera;

  AllImagesBloc(
      {required ImageRepository imageRepository, bool isFromCamera = false})
      : _imageRepository = imageRepository,
        _isFromCamera = isFromCamera,
        super(AllImagesState()) {
    on<AllImageSubscriptionRequested>(_onSubscriptionRequested);
    on<AllImagesShortcutKeyTriggered>(_onShortcutKeyTriggered);
    on<AllImagesClearChecked>(_onClearChecked);
    on<AllImagesCheckedImagesChanged>(_onCheckedImageChanged);
    on<AllImageKeyStatusChanged>(_onKeyStatusChanged);
    on<AllImagesOpenMenu>(_onOpenContextMenu);
    on<AllImagesClearDeleted>(_onClearDeletedImages);
    on<AllImagesDeleteSubmitted>(_onDeleteSubmitted);
    on<AllImagesCopyImagesSubmitted>(_onCopySubmitted);
    on<AllImagesCancelCopySubmitted>(_onCancelCopySubmitted);
    on<AllImagesCopyStatusChanged>(_onCopyStatusChanged);
    on<AllImagesUploadPhotos>(_onUploadPhotos);
    on<AllImagesUploadStatusChanged>(_onUploadStatusChanged);
  }

  void _onSubscriptionRequested(
      AllImageSubscriptionRequested event, Emitter<AllImagesState> emit) async {
    emit(state.copyWith(status: AllImagesStatus.loading));

    try {
      List<ImageItem> allImages = [];

      if (_isFromCamera) {
        allImages = await _imageRepository.getCameraImages();
      } else {
        allImages = await _imageRepository.getAllImages();
      }

      emit(state.copyWith(status: AllImagesStatus.success, images: allImages));
    } catch (e) {
      emit(state.copyWith(status: AllImagesStatus.failure));
    }
  }

  void _onShortcutKeyTriggered(
      AllImagesShortcutKeyTriggered event, Emitter<AllImagesState> emit) {
    log("_onShortcutKeyTriggered, images size: ${state.images.length}");
    emit(state.copyWith(checkedImages: state.images));
  }

  void _onClearChecked(
      AllImagesClearChecked event, Emitter<AllImagesState> emit) {
    emit(state.copyWith(checkedImages: []));
  }

  void _onCheckedImageChanged(
      AllImagesCheckedImagesChanged event, Emitter<AllImagesState> emit) {
    List<ImageItem> allImages = state.images;
    List<ImageItem> checkedImages = [...state.checkedImages];
    ImageItem image = event.image;

    AllImagesBoardKeyStatus keyStatus = state.keyStatus;

    if (!checkedImages.contains(image)) {
      if (keyStatus == AllImagesBoardKeyStatus.ctrlDown) {
        checkedImages.add(image);
      } else if (keyStatus == AllImagesBoardKeyStatus.shiftDown) {
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
      if (keyStatus == AllImagesBoardKeyStatus.ctrlDown) {
        checkedImages.remove(image);
      } else if (keyStatus == AllImagesBoardKeyStatus.shiftDown) {
        checkedImages.remove(image);
      } else {
        checkedImages.clear();
        checkedImages.add(image);
      }
    }

    emit(state.copyWith(checkedImages: checkedImages));
  }

  void _onKeyStatusChanged(
      AllImageKeyStatusChanged event, Emitter<AllImagesState> emit) {
    emit(state.copyWith(keyStatus: event.keyStatus));
  }

  void _onOpenContextMenu(
      AllImagesOpenMenu event, Emitter<AllImagesState> emit) {
    emit(state.copyWith(contextMenuArguments: event.arguments));
  }

  void _onClearDeletedImages(
      AllImagesClearDeleted event, Emitter<AllImagesState> emit) {
    List<ImageItem> images = [...state.images];
    List<ImageItem> checkedImages = [...state.checkedImages];

    images.removeWhere((image) => event.images.contains(image));
    checkedImages.removeWhere((image) => event.images.contains(image));

    emit(state.copyWith(images: images, checkedImages: checkedImages));
  }

  void _onDeleteSubmitted(
      AllImagesDeleteSubmitted event, Emitter<AllImagesState> emit) async {
    emit(state.copyWith(
        deleteStatus: AllImageDeleteImagesStatusUnit(
            status: AllImageDeleteImagesStatus.loading)));

    try {
      await _imageRepository.deleteImages(event.images);

      List<ImageItem> images = [...state.images];
      List<ImageItem> checkedImages = [...state.checkedImages];

      images.removeWhere((image) => event.images.contains(image));
      checkedImages.removeWhere((image) => event.images.contains(image));

      emit(state.copyWith(
          deleteStatus: AllImageDeleteImagesStatusUnit(
              status: AllImageDeleteImagesStatus.success, images: images),
          images: images,
          checkedImages: checkedImages));
    } on Exception catch (e) {
      emit(state.copyWith(
          deleteStatus: AllImageDeleteImagesStatusUnit(
              status: AllImageDeleteImagesStatus.failure,
              failureReason: CommonUtil.convertHttpError(e))));
    }
  }

  void _onCopySubmitted(
      AllImagesCopyImagesSubmitted event, Emitter<AllImagesState> emit) {
    emit(state.copyWith(
        copyStatus: AllImageCopyStatusUnit(status: AllImageCopyStatus.start)));

    _imageRepository.copyImagesTo(
        images: event.images,
        dir: event.path,
        onProgress: (fileName, current, total) {
          add(AllImagesCopyStatusChanged(AllImageCopyStatusUnit(
              status: AllImageCopyStatus.copying,
              fileName: fileName,
              current: current,
              total: total)));
        },
        onDone: (fileName) {
          add(AllImagesCopyStatusChanged(AllImageCopyStatusUnit(
              status: AllImageCopyStatus.success, fileName: fileName)));
        },
        onError: (String error) {
          add(AllImagesCopyStatusChanged(AllImageCopyStatusUnit(
              status: AllImageCopyStatus.failure, error: error)));
        });
  }

  void _onCancelCopySubmitted(
      AllImagesCancelCopySubmitted event, Emitter<AllImagesState> emit) {
    _imageRepository.cancelCopy();
  }

  void _onCopyStatusChanged(
      AllImagesCopyStatusChanged event, Emitter<AllImagesState> emit) {
    emit(state.copyWith(copyStatus: event.status));
  }

  void _onUploadPhotos(
      AllImagesUploadPhotos event, Emitter<AllImagesState> emit) {
    emit(state.copyWith(
        uploadStatus: state.uploadStatus.copyWith(
            status: AllImageUploadStatus.start, photos: event.photos)));

    _imageRepository.uploadPhotos(
        pos: event.pos,
        photos: event.photos,
        onError: (error) {
          add(AllImagesUploadStatusChanged(state.uploadStatus.copyWith(
              status: AllImageUploadStatus.failure, failureReason: error)));
        },
        onUploading: (sent, total) {
          add(AllImagesUploadStatusChanged(state.uploadStatus.copyWith(
              status: AllImageUploadStatus.uploading,
              current: sent,
              total: total)));
        },
        onSuccess: (images) {
          add(AllImagesUploadStatusChanged(state.uploadStatus
              .copyWith(status: AllImageUploadStatus.success, images: images)));
        });
  }

  void _onUploadStatusChanged(
      AllImagesUploadStatusChanged event, Emitter<AllImagesState> emit) {
    final images = [...state.images];
    if (event.status.status == AllImageUploadStatus.success) {
      final uploadedImages = event.status.images;
      if (uploadedImages != null && uploadedImages.isNotEmpty) {
        uploadedImages.forEach((element) {
          if (!images.contains(element)) {
            images.insert(0, element);
          }
        });
      }
    }
    emit(state.copyWith(uploadStatus: event.status, images: images));
  }
}
