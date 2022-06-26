import 'package:audioplayers/audioplayers.dart';

enum SoundType { done, bubble }

class SoundEffect {
  SoundEffect._();

  static void play(SoundType type) async {
    final player = AudioPlayer();

    switch (type) {
      case SoundType.done:
        {
          await player.play(AssetSource('assets/done.mp3'));
          break;
        }
      case SoundType.bubble:
        {
          await player.play(AssetSource("audios/bubble.mp3"));
          break;
        }
      default:
        throw UnimplementedError();
    }
  }
}
