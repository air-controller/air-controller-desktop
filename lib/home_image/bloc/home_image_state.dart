part of 'home_image_bloc.dart';

enum HomeImageTab { allImages, cameraImages, allAlbums }

enum HomeImageDeleteStatus { initial, loading, success, failure }

extension HomeImageTabX on HomeImageTab {
  static HomeImageTab convertToTab(int value) {
    try {
      return HomeImageTab.values.firstWhere((tab) => tab.index == value);
    } catch (e) {
      return HomeImageTab.allImages;
    }
  }
}

class HomeImageCount extends Equatable {
  final int checkedCount;
  final int totalCount;

  const HomeImageCount({required this.checkedCount, required this.totalCount});

  @override
  List<Object?> get props => [checkedCount, totalCount];
}

enum HomeImageDeleteTapStatus { initial, tap }

class HomeImageDeleteTapStatusUnit extends Equatable {
  final HomeImageTab tab;
  final HomeImageDeleteTapStatus status;

  const HomeImageDeleteTapStatusUnit(
      {this.tab = HomeImageTab.allImages,
      this.status = HomeImageDeleteTapStatus.initial});

  @override
  List<Object?> get props => [tab, status];
}

class HomeImageState extends Equatable {
  final HomeImageTab tab;
  final ArrangementMode arrangement;
  final bool isDeleteEnabled;
  final HomeImageDeleteStatus deleteStatus;
  final HomeImageCount imageCount;
  final bool isArrangementVisible;
  final bool isBackBtnVisible;
  final HomeImageDeleteTapStatusUnit deleteTapStatus;

  const HomeImageState(
      {this.tab = HomeImageTab.allImages,
      this.arrangement = ArrangementMode.grid,
      this.isDeleteEnabled = false,
      this.deleteStatus = HomeImageDeleteStatus.initial,
      this.imageCount = const HomeImageCount(checkedCount: 0, totalCount: 0),
      this.isArrangementVisible = true,
      this.isBackBtnVisible = false,
      this.deleteTapStatus = const HomeImageDeleteTapStatusUnit()});

  @override
  List<Object?> get props => [
        tab,
        arrangement,
        isDeleteEnabled,
        deleteStatus,
        imageCount,
        isArrangementVisible,
        isBackBtnVisible,
    deleteTapStatus
      ];

  HomeImageState copyWith(
      {HomeImageTab? tab,
      ArrangementMode? arrangement,
      bool? isDeleteEnabled,
      HomeImageDeleteStatus? deleteStatus,
      HomeImageCount? imageCount,
      bool? isArrangementVisible,
      bool? isBackBtnVisible,
      HomeImageDeleteTapStatusUnit? deleteTapStatus}) {
    return HomeImageState(
        tab: tab ?? this.tab,
        arrangement: arrangement ?? this.arrangement,
        isDeleteEnabled: isDeleteEnabled ?? this.isDeleteEnabled,
        deleteStatus: deleteStatus ?? this.deleteStatus,
        imageCount: imageCount ?? this.imageCount,
        isArrangementVisible: isArrangementVisible ?? this.isArrangementVisible,
        isBackBtnVisible: isBackBtnVisible ?? this.isBackBtnVisible,
        deleteTapStatus: deleteTapStatus ?? this.deleteTapStatus);
  }
}
