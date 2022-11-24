part of 'image_detail_bloc.dart';

class ImageDetailState extends Equatable {
  final int currentIndex;
  final List<ImageItem> images;
  final double imageScale;
  final DeleteImagesStatusUnit deleteStatus;
  final ImageDetailCopyStatusUnit copyStatus;
  final bool showLoading;
  final bool showError;
  final String? errorMessage;

  const ImageDetailState(
      {required this.currentIndex,
      required this.images,
      this.imageScale = 1.0,
      this.deleteStatus = const DeleteImagesStatusUnit(),
      this.copyStatus = const ImageDetailCopyStatusUnit(),
      this.showLoading = false,
      this.showError = false,
      this.errorMessage});

  @override
  List<Object?> get props => [
        currentIndex,
        images,
        imageScale,
        deleteStatus,
        copyStatus,
        showLoading,
        showError,
        errorMessage
      ];

  ImageDetailState copyWith(
      {int? currentIndex,
      List<ImageItem>? images,
      double? imageScale,
      DeleteImagesStatusUnit? deleteStatus,
      ImageDetailCopyStatusUnit? copyStatus,
      bool? showLoading,
      bool? showError,
      String? errorMessage}) {
    return ImageDetailState(
        currentIndex: currentIndex ?? this.currentIndex,
        images: images ?? this.images,
        imageScale: imageScale ?? this.imageScale,
        deleteStatus: deleteStatus ?? this.deleteStatus,
        copyStatus: copyStatus ?? this.copyStatus,
        showLoading: showLoading ?? this.showLoading,
        showError: showError ?? this.showError,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}
