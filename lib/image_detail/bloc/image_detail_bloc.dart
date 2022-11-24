import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/image_item.dart';
import '../../repository/image_repository.dart';
import '../../util/common_util.dart';
import '../model/delete_images_result.dart';
import '../model/image_detail_copy_status.dart';

part 'image_detail_event.dart';
part 'image_detail_state.dart';

class ImageDetailBloc extends Bloc<ImageDetailEvent, ImageDetailState> {
  final ImageRepository _imageRepository;

  ImageDetailBloc(List<ImageItem> images, int index,
      {required ImageRepository imageRepository})
      : _imageRepository = imageRepository,
        super(ImageDetailState(currentIndex: index, images: images)) {
    on<ImageDetailScaleChanged>(_onImageScaleChanged);
    on<ImageDetailIndexChanged>(_onImageIndexChanged);
    on<ImageDetailDeleteSubmitted>(_onDeleteImagesSubmitted);
    on<ImageDetailCopySubmitted>(_onCopyImageSubmitted);
    on<ImageDetailCopyStatusChanged>(_onCopyImageStatusChanged);
    on<ImageDetailDownloadToLocal>(_onDownloadToLocal);
  }

  void _onImageScaleChanged(
      ImageDetailScaleChanged event, Emitter<ImageDetailState> emit) {
    emit(state.copyWith(imageScale: event.imageScale));
  }

  void _onImageIndexChanged(
      ImageDetailIndexChanged event, Emitter<ImageDetailState> emit) {
    emit(state.copyWith(currentIndex: event.index));
  }

  void _onDeleteImagesSubmitted(
      ImageDetailDeleteSubmitted event, Emitter<ImageDetailState> emit) async {
    emit(state.copyWith(
        deleteStatus:
            DeleteImagesStatusUnit(status: DeleteImagesStatus.loading)));

    try {
      await _imageRepository.deleteImages([event.image]);

      List<ImageItem> images = [...state.images];
      int currentIndex = images.indexOf(event.image);

      images.remove(event.image);

      if (currentIndex > images.length - 1) {
        currentIndex = images.length - 1;

        if (currentIndex < 0) currentIndex = 0;
      }

      emit(state.copyWith(
          deleteStatus: DeleteImagesStatusUnit(
              status: DeleteImagesStatus.success, images: [event.image]),
          images: images,
          currentIndex: currentIndex));
    } on Exception catch (e) {
      emit(state.copyWith(
          deleteStatus: DeleteImagesStatusUnit(
              status: DeleteImagesStatus.failure,
              failureReason: CommonUtil.convertHttpError(e))));
    }
  }

  void _onCopyImageSubmitted(
      ImageDetailCopySubmitted event, Emitter<ImageDetailState> emit) {
    emit(state.copyWith(
        copyStatus:
            ImageDetailCopyStatusUnit(status: ImageDetailCopyStatus.start)));

    _imageRepository.copyImagesTo(
        images: [event.image],
        dir: event.dir,
        onProgress: (fileName, current, total) {
          add(ImageDetailCopyStatusChanged(ImageDetailCopyStatusUnit(
              status: ImageDetailCopyStatus.copying,
              fileName: fileName,
              current: current,
              total: total)));
        },
        onDone: (fileName) {
          add(ImageDetailCopyStatusChanged(ImageDetailCopyStatusUnit(
            status: ImageDetailCopyStatus.success,
          )));
        },
        onError: (String error) {
          add(ImageDetailCopyStatusChanged(ImageDetailCopyStatusUnit(
              status: ImageDetailCopyStatus.failure, error: error)));
        });
  }

  void _onCopyImageStatusChanged(
      ImageDetailCopyStatusChanged event, Emitter<ImageDetailState> emit) {
    emit(state.copyWith(copyStatus: event.status));
  }

  FutureOr<void> _onDownloadToLocal(
      ImageDetailDownloadToLocal event, Emitter<ImageDetailState> emit) async {
    emit(state.copyWith(showLoading: true));
    try {
      final bytes = await _imageRepository.readImagesAsBytes([event.image]);
      String fileName = event.image.path.split("/").last;
      CommonUtil.downloadAsWebFile(bytes: bytes, fileName: fileName);
      emit(state.copyWith(showLoading: false));
    } catch (e) {
      emit(state.copyWith(showLoading: false));
      emit(state.copyWith(showError: true, errorMessage: e.toString()));
    }
  }
}
