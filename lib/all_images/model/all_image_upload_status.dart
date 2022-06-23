import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../model/image_item.dart';

enum AllImageUploadStatus { initial, start, uploading, failure, success }

class AllImageUploadStatusUnit extends Equatable {
  final AllImageUploadStatus status;
  final int total;
  final int current;
  final List<File> photos;
  final String? failureReason;
  final List<ImageItem>? images;

  const AllImageUploadStatusUnit(
      {this.status = AllImageUploadStatus.initial,
      this.total = 1,
      this.current = 0,
      this.photos = const [],
      this.failureReason,
      this.images});

  @override
  List<Object?> get props => [status, total, current, photos, failureReason, images];

  AllImageUploadStatusUnit copyWith(
      {AllImageUploadStatus? status,
      int? total,
      int? current,
      List<File>? photos,
      String? failureReason,
      List<ImageItem>? images}) {
    return AllImageUploadStatusUnit(
      status: status ?? this.status,
      current: current ?? this.current,
      total: total ?? this.total,
      photos: photos ?? this.photos,
      failureReason: failureReason ?? this.failureReason,
      images: images ?? this.images,
    );
  }
}
