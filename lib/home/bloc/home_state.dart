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

class HomeState extends Equatable {
  final HomeTab tab;
  final MobileInfo? mobileInfo;

  const HomeState({
    this.tab = HomeTab.image,
    this.mobileInfo = null
  });

  @override
  List<Object?> get props => [tab, mobileInfo];

  HomeState copyWith({
    HomeTab? tab,
    MobileInfo? mobileInfo
  }) {
    return HomeState(
      tab: tab ?? this.tab,
      mobileInfo: mobileInfo ?? this.mobileInfo
    );
  }
}