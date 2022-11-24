part of 'all_images_bloc.dart';

enum AllImagesStatus { initial, loading, success, failure }

enum AllImagesBoardKeyStatus { none, ctrlDown, shiftDown }

class AllImagesState extends Equatable {
  final List<ImageItem> images;
  final List<ImageItem> checkedImages;
  final AllImagesStatus status;
  final AllImageDeleteImagesStatusUnit deleteStatus;
  final AllImagesBoardKeyStatus keyStatus;
  final AllImageMenuArguments? contextMenuArguments;
  final AllImageCopyStatusUnit? copyStatus;
  final AllImageUploadStatusUnit uploadStatus;
  final bool showLoading;
  final bool showError;
  final String? errorMessage;

  AllImagesState(
      {this.images = const [],
      this.checkedImages = const [],
      this.status = AllImagesStatus.initial,
      this.deleteStatus = const AllImageDeleteImagesStatusUnit(),
      this.keyStatus = AllImagesBoardKeyStatus.none,
      this.contextMenuArguments = null,
      this.copyStatus,
      this.uploadStatus = const AllImageUploadStatusUnit(),
      this.showLoading = false,
      this.showError = false,
      this.errorMessage = null});

  @override
  List<Object?> get props => [
        images,
        checkedImages,
        status,
        deleteStatus,
        keyStatus,
        contextMenuArguments,
        copyStatus,
        uploadStatus,
        showLoading,
        showError,
        errorMessage
      ];

  AllImagesState copyWith(
      {List<ImageItem>? images,
      List<ImageItem>? checkedImages,
      AllImagesStatus? status,
      AllImageDeleteImagesStatusUnit? deleteStatus,
      AllImagesBoardKeyStatus? keyStatus,
      AllImageMenuArguments? contextMenuArguments,
      AllImageCopyStatusUnit? copyStatus,
      AllImageUploadStatusUnit? uploadStatus,
      bool? showLoading,
      bool? showError,
      String? errorMessage}) {
    return AllImagesState(
        images: images ?? this.images,
        checkedImages: checkedImages ?? this.checkedImages,
        status: status ?? this.status,
        deleteStatus: deleteStatus ?? this.deleteStatus,
        keyStatus: keyStatus ?? this.keyStatus,
        contextMenuArguments: contextMenuArguments ?? this.contextMenuArguments,
        copyStatus: copyStatus ?? this.copyStatus,
        uploadStatus: uploadStatus ?? this.uploadStatus,
        showLoading: showLoading ?? this.showLoading,
        showError: showError ?? this.showError,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}
