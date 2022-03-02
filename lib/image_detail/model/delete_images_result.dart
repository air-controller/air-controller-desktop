
import 'package:equatable/equatable.dart';

import '../../model/ImageItem.dart';

enum DeleteImagesStatus { initial, loading, success, failure }

class DeleteImagesStatusUnit extends Equatable {
  final DeleteImagesStatus status;
  final List<ImageItem> images;
  final String? failureReason;

  const DeleteImagesStatusUnit({
    this.status = DeleteImagesStatus.initial,
    this.images = const [],
    this.failureReason = null
  });

  @override
  List<Object?> get props => [status, failureReason, images];
}