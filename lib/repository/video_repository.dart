import '../model/ResponseEntity.dart';
import '../model/video_folder_item.dart';
import '../model/video_item.dart';
import 'aircontroller_client.dart';

class VideoRepository {
  final AirControllerClient client;

  VideoRepository({required AirControllerClient client}): this.client = client;

  Future<List<VideoItem>> getAllVideos() => this.client.getAllVideos();

  Future<List<VideoFolderItem>> getAllVideoFolders() => this.client.getAllVideoFolders();

  Future<List<VideoItem>> getVideosInFolder(String folderId) => this.client.getVideosInFolder(folderId);
}