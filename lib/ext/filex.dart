import 'dart:io';

import 'package:air_controller/constant.dart';

extension FileX on File {
  bool get isImage {
    final fileExtension = this.extension;
    return Constant.allImageSuffix.contains(fileExtension.toLowerCase());
  }

  bool get isAudio {
    final fileExtension = this.extension;
    return Constant.allAudioSuffix.contains(fileExtension.toLowerCase());
  }

  String get extension {
    final fileName = this.path.split('/').last;
    final fileExtension = fileName.split('.').last;
    return fileExtension;
  }
}
