import '../model/audio_item.dart';
import 'aircontroller_client.dart';

class AudioRepository {
  final AirControllerClient client;

  AudioRepository({required AirControllerClient client}): this.client = client;

  Future<List<AudioItem>> getAllAudios() => client.getAllAudios();
}