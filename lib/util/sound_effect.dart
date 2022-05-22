import 'dart:io';

import 'package:audioplayers/audioplayers.dart';

enum SoundType { done }

class SoundEffect {
  static void play(SoundType type) async {
    final player = AudioCache();

    switch (type) {
      case SoundType.done:
        {
          if (Platform.isMacOS) {
            await player.play("audios/done.mp3");
          }
          break;
        }
      default:
        throw UnimplementedError();
    }
  }
}
