part of 'video_home_bloc.dart';

enum VideoHomeTab { allVideos, videoFolders }

extension VideoHomeTabX on VideoHomeTab {
  static VideoHomeTab convertToTab(int index) {
    try {
      return VideoHomeTab.values.firstWhere((tab) => tab.index == index);
    } catch (e) {
      return VideoHomeTab.allVideos;
    }
  }
}

class VideoHomeItemCount extends Equatable {
  final int totalCount;
  final int checkedCount;

  const VideoHomeItemCount(this.totalCount, this.checkedCount);

  @override
  List<Object?> get props => [totalCount, checkedCount];
}

enum VideoHomeBackTapStatus { none, tap }

enum VideoHomeDeleteTapStatus { none, tap }

class VideoHomeState extends Equatable {
  final VideoHomeTab tab;
  final VideoOrderType orderType;
  final bool isDeleteEnabled;
  final VideoHomeItemCount itemCount;
  final bool isBackVisible;
  final bool isOrderTypeVisible;
  final VideoHomeBackTapStatus backTapStatus;
  final VideoHomeDeleteTapStatus deleteTapStatus;

  const VideoHomeState(
      {this.tab = VideoHomeTab.allVideos,
      this.orderType = VideoOrderType.createTime,
      this.isDeleteEnabled = false,
      this.itemCount = const VideoHomeItemCount(0, 0),
      this.isBackVisible = false,
      this.isOrderTypeVisible = true,
      this.backTapStatus = VideoHomeBackTapStatus.none,
      this.deleteTapStatus = VideoHomeDeleteTapStatus.none});

  @override
  List<Object?> get props => [
        tab,
        orderType,
        isDeleteEnabled,
        itemCount,
        isBackVisible,
        isOrderTypeVisible,
        backTapStatus,
        deleteTapStatus
      ];

  VideoHomeState copyWith(
      {VideoHomeTab? tab,
      VideoOrderType? orderType,
      bool? isDeleteEnabled,
      VideoHomeItemCount? itemCount,
      bool? isBackVisible,
      bool? isOrderTypeVisible,
      VideoHomeBackTapStatus? backTapStatus,
      VideoHomeDeleteTapStatus? deleteTapStatus}) {
    return VideoHomeState(
        tab: tab ?? this.tab,
        orderType: orderType ?? this.orderType,
        isDeleteEnabled: isDeleteEnabled ?? this.isDeleteEnabled,
        itemCount: itemCount ?? this.itemCount,
        isBackVisible: isBackVisible ?? this.isBackVisible,
        isOrderTypeVisible: isOrderTypeVisible ?? this.isOrderTypeVisible,
        backTapStatus: backTapStatus ?? this.backTapStatus,
        deleteTapStatus: deleteTapStatus ?? this.deleteTapStatus);
  }
}
