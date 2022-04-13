part of 'home_bloc.dart';

enum HomeTab { image, music, video, download, allFile, helpAndFeedback }

extension HomeTabX  on HomeTab {
  static HomeTab convertToHomeTab(int index) {
    List<HomeTab> tabs = HomeTab.values;
    if (index >= 0 && index <= tabs.length - 1) {
      return tabs[index];
    }

    return HomeTab.image;
  }
}

class UpdateCheckResult extends Equatable {
  final bool hasUpdateAvailable;
  final String? version;
  final int? publishTime;
  final String? updateInfo;
  final String? url;
  final String? name;

  const UpdateCheckResult({
    this.hasUpdateAvailable = false,
    this.version = null,
    this.publishTime = null,
    this.updateInfo = null,
    this.url = null,
    this.name = null
  });

  @override
  List<Object?> get props => [hasUpdateAvailable, version, publishTime, updateInfo, url, name];
}

class HomeState extends Equatable {
  final HomeTab tab;
  final MobileInfo? mobileInfo;
  final String? appVersion;
  final UpdateCheckResult updateCheckResult;

  const HomeState({
    this.tab = HomeTab.image,
    this.mobileInfo = null,
    this.appVersion,
    this.updateCheckResult = const UpdateCheckResult()
  });

  @override
  List<Object?> get props => [tab, mobileInfo, appVersion, updateCheckResult];

  HomeState copyWith({
    HomeTab? tab,
    MobileInfo? mobileInfo,
    String? version,
    UpdateCheckResult? updateCheckStatus,
    UpdateDownloadStatusUnit? updateDownloadStatus
  }) {
    return HomeState(
      tab: tab ?? this.tab,
      mobileInfo: mobileInfo ?? this.mobileInfo,
      appVersion: version ?? this.appVersion,
      updateCheckResult: updateCheckStatus ?? this.updateCheckResult,
    );
  }
}