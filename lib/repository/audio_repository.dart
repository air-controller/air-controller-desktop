
import 'package:mobile_assistant_client/repository/aircontroller_client.dart';
import '../model/AudioItem.dart';

class AudioRepository {
  final AirControllerClient client;

  AudioRepository({required AirControllerClient client}): this.client = client;

  Future<List<AudioItem>> getAllAudios() => client.getAllAudios();
}