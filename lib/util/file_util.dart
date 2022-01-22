
import 'package:mobile_assistant_client/model/FileItem.dart';

class FileUtil {

  static bool isImage(FileItem item) {
    String extension = _getFileExtension(item);
    return _isImageFile(extension);
  }

  static bool isVideo(FileItem item) {
    String extension = _getFileExtension(item);
    return _isVideo(extension);
  }

  static bool isAudio(FileItem item) {
    String extension = _getFileExtension(item);
    return _isAudio(extension);
  }

  static bool isDoc(FileItem item) {
    String extension = _getFileExtension(item);
    return _isDoc(extension);
  }

  static String _getFileExtension(FileItem item) {
    String name = item.name;
    String extension = "";
    int pointIndex = name.lastIndexOf(".");
    if (pointIndex != -1) {
      extension = name.substring(pointIndex + 1);
    }
    return extension;
  }

  static bool _isAudio(String extension) {
    if (extension.toLowerCase() == "mp3") return true;
    if (extension.toLowerCase() == "wav") return true;

    return false;
  }

  static bool _isImageFile(String extension) {
    if (extension.toLowerCase() == "jpg") return true;
    if (extension.toLowerCase() == "jpeg") return true;
    if (extension.toLowerCase() == "png") return true;

    return false;
  }

  static bool _isVideo(String extension) {
    if (extension.toLowerCase() == "mp4") return true;
    if (extension.toLowerCase() == "mov") return true;
    if (extension.toLowerCase() == "avi") return true;

    return false;
  }

  static bool _isDoc(String extension) {
    if (extension.toLowerCase() == "doc") return true;
    if (extension.toLowerCase() == "docx") return true;
    if (extension.toLowerCase() == "pdf") return true;
    if (extension.toLowerCase() == "ppt") return true;
    if (extension.toLowerCase() == "key") return true;

    return false;
  }
}