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

enum UpdateCheckStatus { initial, start, failure, success }

class UpdateCheckStatusUnit extends Equatable {
  final UpdateCheckStatus status;
  final bool isAutoCheck;
  final String? failureReason;
  final bool hasUpdateAvailable;
  final String? version;
  final int? publishTime;
  final String? updateInfo;
  final String? url;
  final String? name;

  const UpdateCheckStatusUnit({
     this.status = UpdateCheckStatus.initial,
    this.isAutoCheck = true,
    this.failureReason,
    this.hasUpdateAvailable = false,
    this.version = null,
    this.publishTime = null,
    this.updateInfo = null,
    this.url = null,
    this.name = null,
  });

  @override
  List<Object?> get props => [status, isAutoCheck, failureReason, hasUpdateAvailable,
    version, publishTime, updateInfo, url, name];
}

class HomeState extends Equatable {
  final HomeTab tab;
  final MobileInfo? mobileInfo;
  final UpdateCheckStatusUnit updateCheckStatus;

  const HomeState({
    this.tab = HomeTab.image,
    this.mobileInfo = null,
    this.updateCheckStatus = const UpdateCheckStatusUnit()
  });

  @override
  List<Object?> get props => [tab, mobileInfo, updateCheckStatus];

  HomeState copyWith({
    HomeTab? tab,
    MobileInfo? mobileInfo,
    UpdateDownloadStatusUnit? updateDownloadStatus,
    UpdateCheckStatusUnit? updateCheckStatus
  }) {
    return HomeState(
      tab: tab ?? this.tab,
      mobileInfo: mobileInfo ?? this.mobileInfo,
      updateCheckStatus: updateCheckStatus ?? this.updateCheckStatus
    );
  }
}