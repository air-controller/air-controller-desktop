
import 'package:mobile_assistant_client/model/ImageItem.dart';
import 'package:mobile_assistant_client/repository/aircontroller_client.dart';

class ImageRepository {
  final AirControllerClient client;

  ImageRepository({required AirControllerClient client}): this.client = client;

  Future<List<ImageItem>> getAllImages() => this.client.getAllImages();
}