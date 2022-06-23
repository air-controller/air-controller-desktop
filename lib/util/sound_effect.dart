import 'dart:io';

import 'package:audioplayers/audioplayers.dart';

enum SoundType { done, bubble }

class SoundEffect {
  static void play(SoundType type) async {
    final player = AudioCache();

    if (!Platform.isMacOS) return;

    switch (type) {
      case SoundType.done:
        {
          await player.play("audios/done.mp3");
          break;
        }
      case SoundType.bubble:
        {
          await player.play("audios/bubble.mp3");
          break;
        }
      default:
        throw UnimplementedError();
    }
  }
}
