
import 'package:equatable/equatable.dart';

import '../../model/image_item.dart';

enum AllImageDeleteImagesStatus { initial, loading, success, failure }

class AllImageDeleteImagesStatusUnit extends Equatable {
  final AllImageDeleteImagesStatus status;
  final List<ImageItem> images;
  final String? failureReason;

  const AllImageDeleteImagesStatusUnit({
    this.status = AllImageDeleteImagesStatus.initial,
    this.images = const [],
    this.failureReason = null
  });

  @override
  List<Object?> get props => [status, failureReason, images];
}