
import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../../model/image_item.dart';

class AllImageMenuArguments extends Equatable {
  final Offset position;
  final ImageItem targetImage;
  
  const AllImageMenuArguments({required this.position, required this.targetImage});

  @override
  List<Object?> get props => [position, targetImage];
}