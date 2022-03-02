part of 'image_detail_bloc.dart';

class ImageDetailEvent extends Equatable {
  const ImageDetailEvent();

  @override
  List<Object?> get props => [];
}

class ImageDetailIndexChanged extends ImageDetailEvent {
  final int index;

  const ImageDetailIndexChanged(this.index);

  @override
  List<Object?> get props => [index];
}

class ImageDetailScaleChanged extends ImageDetailEvent {
  final double imageScale;

  const ImageDetailScaleChanged(this.imageScale);

  @override
  List<Object?> get props => [imageScale];
}

class ImageDetailDeleteSubmitted extends ImageDetailEvent {
  final ImageItem image;

  const ImageDetailDeleteSubmitted(this.image);

  @override
  List<Object?> get props => [image];
}

class ImageDetailCopySubmitted extends ImageDetailEvent {
  final ImageItem image;
  final String dir;

  const ImageDetailCopySubmitted(this.image, this.dir);
}

class ImageDetailCopyStatusChanged extends ImageDetailEvent {
  final ImageDetailCopyStatusUnit status;

  const ImageDetailCopyStatusChanged(this.status);
}