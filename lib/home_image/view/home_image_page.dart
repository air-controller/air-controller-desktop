import 'dart:developer';

import 'package:air_controller/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:material_segmented_control/material_segmented_control.dart';

import '../../all_albums/view/all_albums_page.dart';
import '../../all_images/view/all_images_page.dart';
import '../../constant.dart';
import '../../model/arrangement_mode.dart';
import '../../widget/unified_delete_button.dart';
import '../bloc/home_image_bloc.dart';
import '../widget/arrangement_segmented_control.dart';

class HomeImagePage extends StatelessWidget {
  final GlobalKey<NavigatorState> _navigatorKey;

  HomeImagePage({required GlobalKey<NavigatorState> navigatorKey})
      : _navigatorKey = navigatorKey;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeImageBloc(),
      child: HomeImageView(navigatorKey: _navigatorKey),
    );
  }
}

class HomeImageView extends StatelessWidget {
  final GlobalKey<NavigatorState> _navigatorKey;
  final _DIVIDER_LINE_COLOR = Color(0xffe0e0e0);
  bool _isBackBtnDown = false;

  HomeImageView({required GlobalKey<NavigatorState> navigatorKey})
      : _navigatorKey = navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<HomeImageBloc, HomeImageState>(
              listenWhen: (previous, current) =>
                  previous != current &&
                  current.deleteStatus == HomeImageDeleteStatus.failure,
              listener: (context, state) {
                SmartDialog.dismiss();

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(context.l10n.deleteFilesFailure)));
              }),
          BlocListener<HomeImageBloc, HomeImageState>(
              listenWhen: (previous, current) =>
                  previous != current &&
                  current.deleteStatus == HomeImageDeleteStatus.success,
              listener: (context, state) {
                SmartDialog.dismiss();
              }),
          BlocListener<HomeImageBloc, HomeImageState>(
              listenWhen: (previous, current) =>
                  previous != current &&
                  current.deleteStatus == HomeImageDeleteStatus.loading,
              listener: (context, state) {
                SmartDialog.showLoading();
              })
        ],
        child: BlocBuilder<HomeImageBloc, HomeImageState>(
          builder: (context, state) {
            return _createContentView(context);
          },
        ),
      ),
    );
  }

  Widget _createContentView(BuildContext context) {
    HomeImageTab currentTab =
        context.select((HomeImageBloc bloc) => bloc.state.tab);
    ArrangementMode currentArrangement =
        context.select((HomeImageBloc bloc) => bloc.state.arrangement);
    HomeImageCount imageCount =
        context.select((HomeImageBloc bloc) => bloc.state.imageCount);
    bool isArrangementVisible =
        context.select((HomeImageBloc bloc) => bloc.state.isArrangementVisible);
    bool isDeleteEnabled =
        context.select((HomeImageBloc bloc) => bloc.state.isDeleteEnabled);
    bool isBackVisible =
        context.select((HomeImageBloc bloc) => bloc.state.isBackBtnVisible);

    Color getSegmentBtnColor(HomeImageTab tab) {
      if (tab == currentTab) {
        return Color(0xffffffff);
      } else {
        return Color(0xff5b5c62);
      }
    }

    String itemNumStr = context.l10n.placeHolderItemCount01.replaceFirst("%d", "${imageCount.totalCount}");
    if (imageCount.checkedCount > 0) {
      itemNumStr = context.l10n.placeHolderItemCount02.replaceFirst("%d", "${imageCount.checkedCount}")
      .replaceFirst("%d", "${imageCount.totalCount}");
    }

    return Column(
      children: [
        Container(
          child: Stack(
            children: [
              StatefulBuilder(builder: (context, setState) {
                return GestureDetector(
                  child: Visibility(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child: Row(
                          children: [
                            Image.asset("assets/icons/icon_right_arrow.png",
                                width: 12, height: 12),
                            Container(
                              child: Text(context.l10n.back,
                                  style: TextStyle(
                                      color: Color(0xff5c5c62), fontSize: 13)),
                              margin: EdgeInsets.only(left: 3),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                            color: _isBackBtnDown
                                ? Color(0xffe8e8e8)
                                : Color(0xfff3f3f4),
                            borderRadius:
                                BorderRadius.all(Radius.circular(3.0)),
                            border: Border.all(
                                color: Color(0xffdedede), width: 1.0)),
                        height: 25,
                        width: 50,
                        margin: EdgeInsets.only(left: 15),
                      ),
                    ),
                    visible: isBackVisible,
                  ),
                  onTap: () {
                    context.read<HomeImageBloc>().add(HomeImageBackTapStatusChanged(HomeImageBackTapStatus.tap));
                  },
                  onTapDown: (detail) {
                    setState(() {
                      _isBackBtnDown = true;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      _isBackBtnDown = false;
                    });
                  },
                  onTapUp: (detail) {
                    setState(() {
                      _isBackBtnDown = false;
                    });
                  },
                );
              }),
              Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: MaterialSegmentedControl<int>(
                      children: {
                        HomeImageTab.allImages.index: Container(
                          child: Text(context.l10n.allPictures,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: getSegmentBtnColor(
                                      HomeImageTab.allImages))),
                          padding: EdgeInsets.only(left: 10, right: 10),
                        ),
                        HomeImageTab.cameraImages.index: Container(
                          child: Text(context.l10n.cameraRoll,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: getSegmentBtnColor(
                                      HomeImageTab.cameraImages))),
                        ),
                        HomeImageTab.allAlbums.index: Container(
                            child: Text(context.l10n.galleries,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: getSegmentBtnColor(
                                        HomeImageTab.allAlbums))))
                      },
                      selectionIndex: currentTab.index,
                      borderColor: Color(0xffdedede),
                      selectedColor: Color(0xffc3c3c3),
                      unselectedColor: Color(0xfff7f5f6),
                      borderRadius: 3.0,
                      verticalOffset: 0,
                      disabledChildren: [],
                      onSegmentChosen: (index) {
                        context.read<HomeImageBloc>().add(HomeImageTabChanged(tab: HomeImageTabX.convertToTab(index)));
                      },
                    ),
                    height: 30,
                  )),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  child: Row(
                    children: [
                      Visibility(
                        child: ArrangementSegmentedControl(
                          initMode: currentArrangement,
                          onChange: (previous, current) {
                            log("HomeImagePage, $previous : $current");
                            context.read<HomeImageBloc>().add(HomeImageArrangementChanged(arrangement: current));
                          },
                        ),
                        maintainSize: true,
                        maintainState: true,
                        maintainAnimation: true,
                        visible: isArrangementVisible,
                      ),
                      UnifiedDeleteButton(
                        isEnable: isDeleteEnabled,
                        contentDescription: context.l10n.delete,
                        onTap: () {
                          context.read<HomeImageBloc>().add(
                              HomeImageDeleteTrigger(
                                  currentTab: currentTab)
                          );
                        },
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      )
                    ],
                  ),
                  width: 180,
                ),
              )
            ],
          ),
          height: Constant.HOME_NAVI_BAR_HEIGHT,
          color: Color(0xfff6f6f6),
        ),
        Divider(color: _DIVIDER_LINE_COLOR, height: 1.0, thickness: 1.0),
        Expanded(
          child: IndexedStack(
            index: currentTab.index,
            children: [
              AllImagesPage(navigatorKey: _navigatorKey),
              AllImagesPage(navigatorKey: _navigatorKey, isFromCamera: true),
              AllAlbumsPage(navigatorKey: _navigatorKey)
            ],

          ),
        ),
        Divider(color: _DIVIDER_LINE_COLOR, height: 1.0, thickness: 1.0),
        Container(
          child: Align(
            alignment: Alignment.center,
            child: Text(itemNumStr,
                style: TextStyle(fontSize: 12, color: Color(0xff646464))),
          ),
          height: 20,
          color: Color(0xfffafafa),
        )
      ],
    );
  }
}
