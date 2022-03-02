
import 'package:equatable/equatable.dart';
import 'package:mobile_assistant_client/model/ImageItem.dart';

enum Source { allImages, cameraImages, albums }

class ImageDetailArguments extends Equatable {
  final int index;
  final List<ImageItem> images;
  final Source? source;
  final dynamic extra;

  const ImageDetailArguments({
    required this.index,
    required this.images,
    this.source,
    this.extra
  });

  @override
  List<Object?> get props => [index, images, source, extra];

}