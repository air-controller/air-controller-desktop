import 'package:equatable/equatable.dart';

enum AllImageCopyStatus { initial, start, copying, success, failure }

class AllImageCopyStatusUnit extends Equatable {
  final AllImageCopyStatus status;
  final int current;
  final int total;
  final String fileName;
  final String? error;

  const AllImageCopyStatusUnit({
    this.status = AllImageCopyStatus.initial,
    this.current = 0,
    this.total = 0,
    this.fileName = '',
    this.error
  });

  @override
  List<Object?> get props => [status, current, total, fileName, error];
}
