part of 'all_images_bloc.dart';

class AllImagesEvent extends Equatable {
  const AllImagesEvent();

  @override
  List<Object?> get props => [];
}

class AllImageSubscriptionRequested extends AllImagesEvent {
  const AllImageSubscriptionRequested();
}

class AllImagesCheckedImagesChanged extends AllImagesEvent {
  final ImageItem image;

  const AllImagesCheckedImagesChanged(this.image);

  @override
  List<Object?> get props => [image];
}

class AllImagesCopyImagesSubmitted extends AllImagesEvent {
  final List<ImageItem> images;
  final String path;

  const AllImagesCopyImagesSubmitted(this.images, this.path);

  @override
  List<Object?> get props => [images, path];
}

enum ShortcutKey { ctrlAndA }

class AllImagesShortcutKeyTriggered extends AllImagesEvent {
  final ShortcutKey shortcutKey;

  const AllImagesShortcutKeyTriggered(this.shortcutKey);

  @override
  List<Object?> get props => [this.shortcutKey];
}

class AllImagesClearChecked extends AllImagesEvent {
  const AllImagesClearChecked();
}

class AllImageKeyStatusChanged extends AllImagesEvent {
  final AllImagesBoardKeyStatus keyStatus;

  const AllImageKeyStatusChanged(this.keyStatus);

  @override
  List<Object?> get props => [this.keyStatus];
}

class AllImagesOpenMenu extends AllImagesEvent {
  final AllImageMenuArguments arguments;

  const AllImagesOpenMenu(this.arguments);

  List<Object?> get props => [this.arguments];
}

class AllImagesClearDeleted extends AllImagesEvent {
  final List<ImageItem> images;

  const AllImagesClearDeleted(this.images);

  List<Object?> get props => [this.images];
}

class AllImagesDeleteSubmitted extends AllImagesEvent {
  final List<ImageItem> images;

  const AllImagesDeleteSubmitted(this.images);

  List<Object?> get props => [this.images];
}

class AllImagesCopySubmitted extends AllImagesEvent {
  final List<ImageItem> images;

  const AllImagesCopySubmitted(this.images);

  List<Object?> get props => [this.images];
}

class AllImagesCancelCopySubmitted extends AllImagesEvent {
  const AllImagesCancelCopySubmitted();
}

class AllImagesCopyStatusChanged extends AllImagesEvent {
  final AllImageCopyStatusUnit status;

  const AllImagesCopyStatusChanged(this.status);
}

class AllImagesUploadPhotos extends AllImagesEvent {
  final int pos;
  final List<File> photos;
  final String? path;

  const AllImagesUploadPhotos(
      {required this.pos, required this.photos, this.path});

  @override
  List<Object?> get props => [pos, photos, path];
}

class AllImagesUploadStatusChanged extends AllImagesEvent {
  final AllImageUploadStatusUnit status;

  const AllImagesUploadStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}
