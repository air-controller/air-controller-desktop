import 'package:equatable/equatable.dart';

enum ImageDetailCopyStatus { initial, start, copying, success, failure }

class ImageDetailCopyStatusUnit extends Equatable {
  final ImageDetailCopyStatus status;
  final int current;
  final int total;
  final String fileName;
  final String? error;

  const ImageDetailCopyStatusUnit({
    this.status = ImageDetailCopyStatus.initial,
    this.current = 0,
    this.total = 0,
    this.fileName = '',
    this.error = null
  });

  @override
  List<Object?> get props => [status, current, total, fileName, error];
}
