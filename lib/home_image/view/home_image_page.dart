import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:mobile_assistant_client/all_albums/view/all_albums_page.dart';
import 'package:mobile_assistant_client/all_images/all_images.dart';
import 'package:mobile_assistant_client/constant.dart';
import 'package:mobile_assistant_client/home_image/bloc/home_image_bloc.dart';
import 'package:mobile_assistant_client/l10n/l10n.dart';
import 'package:mobile_assistant_client/model/arrangement_mode.dart';
import 'package:mobile_assistant_client/widget/unified_delete_button.dart';

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

    String _getArrangeModeIcon(ArrangementMode mode) {
      if (mode == ArrangementMode.grid) {
        if (mode == currentArrangement) {
          return "assets/icons/icon_grid_selected.png";
        } else {
          return "assets/icons/icon_grid_normal.png";
        }
      }

      if (mode == ArrangementMode.groupByDay) {
        if (mode == currentArrangement) {
          return "assets/icons/icon_weekly_selected.png";
        } else {
          return "assets/icons/icon_weekly_normal.png";
        }
      }

      if (mode == currentArrangement) {
        return "assets/icons/icon_monthly_selected.png";
      } else {
        return "assets/icons/icon_monthly_normal.png";
      }
    }

    Color _getArrangeModeBgColor(ArrangementMode mode) {
      if (currentArrangement == mode) {
        return Color(0xffc2c2c2);
      } else {
        return Color(0xfff5f5f5);
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
                        child: Row(
                          children: [
                            Tooltip(
                              child: GestureDetector(
                                child: Container(
                                  child: Image.asset(
                                      _getArrangeModeIcon(
                                          ArrangementMode.grid),
                                      width: 20,
                                      height: 20),
                                  padding: EdgeInsets.fromLTRB(13, 3, 13, 3),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color(0xffdddedf), width: 1.0),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(4.0),
                                        bottomLeft: Radius.circular(4.0)),
                                    color: _getArrangeModeBgColor(
                                        ArrangementMode.grid),
                                  ),
                                ),
                                onTap: () {
                                  _setArrangementChecked(context, currentArrangement, ArrangementMode.grid);
                                },
                              ),
                              message: context.l10n.defaultType,
                            ),
                            Tooltip(
                              child: GestureDetector(
                                child: Container(
                                  child: Image.asset(
                                      _getArrangeModeIcon(
                                          ArrangementMode.groupByDay),
                                      width: 20,
                                      height: 20),
                                  padding: EdgeInsets.fromLTRB(13, 3, 13, 3),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color(0xffdddedf), width: 1.0),
                                    color: _getArrangeModeBgColor(
                                        ArrangementMode.groupByDay),
                                  ),
                                ),
                                onTap: () {
                                  _setArrangementChecked(context, currentArrangement, ArrangementMode.groupByDay);
                                },
                              ),
                              message: context.l10n.daily,
                            ),
                            Tooltip(
                              child: GestureDetector(
                                child: Container(
                                  child: Image.asset(
                                      _getArrangeModeIcon(
                                          ArrangementMode.groupByMonth),
                                      width: 20,
                                      height: 20),
                                  padding: EdgeInsets.fromLTRB(13, 3, 13, 3),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color(0xffdddedf), width: 1.0),
                                    color: _getArrangeModeBgColor(
                                        ArrangementMode.groupByMonth),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(4.0),
                                        bottomRight: Radius.circular(4.0)),
                                  ),
                                ),
                                onTap: () {
                                  _setArrangementChecked(context, currentArrangement, ArrangementMode.groupByMonth);
                                },
                              ),
                              message: context.l10n.monthly,
                            ),
                          ],
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
                  width: 210,
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

  void _setArrangementChecked(BuildContext context, ArrangementMode current, ArrangementMode arrangement) {
    if (current == arrangement) return;

    context.read<HomeImageBloc>().add(HomeImageArrangementChanged(arrangement: arrangement));
  }
}
