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
  static const int IMAGE_MAX_SCALE = 10;

  static const String APP_NAME = "AirController";

  static const double minWindowWidth = 1036;

  static const double minWindowHeight = 687;

  static const double defaultWindowWidth = 1243.2;

  static const double defaultWindowHeight = 824.4;

  static const String DEFAULT_LANGUAGE_CODE = "en";

  static const String URL_UPDATE_CHECK =
      "https://api.github.com/repos/air-controller/air-controller-desktop/releases/latest";

  static const String CURRENT_VERSION_NAME = "0.3.1";

  static const String URL_VERSION_LIST =
      "https://github.com/air-controller/air-controller-desktop/releases";

  // The sharedPreferences key for the update download directory.
  static const String KEY_UPDATE_DOWNLOAD_DIR =
      "aircontroller_update_download_directory";

  static const bool ENABLE_HEARTBEAT_LOG = true;

  static const bool ENABLE_UDP_DISCOVER_LOG = true;

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
    "mov",
    "cda"
  ];

  static const allVideoSuffix = [
    "mp4",
    "3gp",
    "avi",
    "mov",
    "wmv",
    "asf",
    "asx",
    "mpg",
    "mpeg",
    "mpe",
    "mpv",
    "m2v",
    "m4v",
    "mkv",
    "flv",
    "rmvb"
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

const urlGitHub = "https://github.com/air-controller/air-controller-desktop";
const urlDocs =
    "https://github.com/air-controller/air-controller-desktop/blob/master/README.md";
const urlIssuesGitHub =
    "https://github.com/air-controller/air-controller-desktop/issues";
const urlFeedback = "https://support.qq.com/product/468169";
const urlWeibo = "https://weibo.com/u/6140262139";
const urlWechatOfficial = "https://youngfeng.com/assets/images/mpwexin.jpg";
const urlQQGroup = "https://jq.qq.com/?_wv=1027&k=eHQ3Sv2J";
const urlUpdateDomain = "https://docs.ac.yhdm360.cn";

const routeEnter = "/enter";
const routeIndex = "/index";
const routeHome = "/home";
