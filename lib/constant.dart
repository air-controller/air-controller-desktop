class Constant {
  Constant._();

  static const int PORT_SEARCH = 20000;

  static const int PORT_CMD = 20001;

  static const int PORT_HEARTBEAT = 20002;

  static const int PORT_HTTP = 9527;

  static const String CMD_SEARCH_PREFIX = "search#";

  static const String CMD_SEARCH_RES_PREFIX = "search_msg_received#";

  static const String RANDOM_STR_SEARCH = "a2w0nuNyiD6vYogF";

  static const String RADNOM_STR_RES_SEARCH = "RBIDoKFHLX9frYTh";

  static const double HOME_NAVI_BAR_HEIGHT = 50.0;

  static const double HOME_TAB_WIDTH = 210;

  /// 是否隐藏右上角DEBUG标记
  static const bool HIDE_DEBUG_MARK = true;

  static const int PLATFORM_MACOS = 1;

  static const int PLATFORM_UBUNTU = 2;

  /// 图片最大放大倍数（1表示原始大小）
  static const int IMAGE_MAX_SCALE = 4;

  static const String APP_NAME = "AirController";

  static const double MIN_WINDOW_WIDTH = 1036;

  static const double MIN_WINDOW_HEIGHT = 687;

  static const double DEFAULT_WINDOW_WIDTH = 1243.2;

  static const double DEFAULT_WINDOW_HEIGHT = 824.4;

  static const String DEFAULT_LANGUAGE_CODE = "en";

  static const String URL_UPDATE_CHECK =
      "https://api.github.com/repos/air-controller/air-controller-desktop/releases/latest";

  static const String CURRENT_VERSION_NAME = "0.3.0";

  static const String URL_VERSION_LIST =
      "https://github.com/air-controller/air-controller-desktop/releases";

  // The sharedPreferences key for the update download directory.
  static const String KEY_UPDATE_DOWNLOAD_DIR =
      "aircontroller_update_download_directory";

  static const bool ENABLE_HEARTBEAT_LOG = false;

  static const bool ENABLE_UDP_DISCOVER_LOG = false;

  static const bool ENABLE_BLOC_LOG = false;

  static const List<String> allImageSuffix = [
    "jpg",
    "jpeg",
    "png",
    "gif",
    "bmp",
    "webp",
    "ico",
    "svg",
    "tiff",
    "tif",
    "psd",
    "raw",
    "arw",
    "cr2",
    "crw",
    "orf",
    "raf",
    "dng",
    "nef",
    "rw2",
    "pef",
    "sr2",
    "srf",
    "arw",
    "jpg",
    "jpeg",
    "png",
    "gif",
    "bmp",
    "webp",
    "ico",
    "svg",
    "tiff",
    "tif",
    "psd",
    "raw",
    "arw",
    "cr2",
    "crw",
    "orf",
    "raf",
    "dng",
    "nef",
    "rw2",
    "pef",
    "sr2",
    "srf",
    "arw",
    "jpg",
    "jpeg",
    "png",
    "gif",
    "bmp",
    "webp",
    "ico",
    "svg",
    "tiff",
    "tif",
    "psd",
    "raw",
    "arw",
    "cr2",
    "crw",
    "orf",
    "raf",
    "dng",
    "nef",
    "rw2",
    "pef",
    "sr2",
    "srf",
    "arw",
    "jpg",
    "jpeg",
    "png",
    "gif",
    "bmp",
    "webp",
    "ico",
    "svg",
    "tiff",
    "tif",
    "psd",
    "raw",
    "arw",
    "cr2",
    "crw",
    "orf",
  ];

  static const allAudioSuffix = [
    "mp3",
    "wav",
    "wma",
    "flac",
    "ape",
    "aac",
    "ogg",
    "m4a",
    "m4r",
    "m4b",
    "m4p",
    "m4v",
    "mpa",
    "mp2",
    "mp4",
    "mov",
    "cda"
  ];

  static const posAllPictures = 1;
  static const posCameraPictures = 2;
  static const posAlbumPictures = 3;
}

class ImagePageRoute {
  static const String IMAGE_HOME = "/image";

  static const String IMAGE_DETAIL = "/image/detail";

  /**
   * Image list page in the someone album.
   */
  static const String IMAGE_ALBUM_IMAGES = "/image/album/images";
}

class ToolboxPageRoute {
  static const String HOME = "/toolbox";

  static const String MANAGE_APPS = "/toolbox/manageApps";

  static const String MANAGE_CONTACTS = "/toolbox/contacts";
}
