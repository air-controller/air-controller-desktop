import 'dart:io';

import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/manage_apps/bloc/manage_apps_bloc.dart';
import 'package:air_controller/manage_apps/view/manage_system_apps_page.dart';
import 'package:air_controller/manage_apps/view/manage_user_apps_page.dart';
import 'package:air_controller/repository/common_repository.dart';
import 'package:air_controller/widget/unfied_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_segmented_control/material_segmented_control.dart';

import '../../constant.dart';

class ManageAppsPage extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const ManageAppsPage(this.navigatorKey);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ManageAppsBloc(context.read<CommonRepository>())
        ..add(ManageAppsSubscriptionRequested()),
      child: ManageAppsView(this.navigatorKey),
    );
  }
}

// ignore: must_be_immutable
class ManageAppsView extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  ManageAppsView(this.navigatorKey);

  void _sendCtrlAEvent(BuildContext context) {
    context
        .read<ManageAppsBloc>()
        .add(ManageAppsCtrlAStatusChanged(ManageAppsCtrlAStatus.tap));
  }

  @override
  Widget build(BuildContext context) {
    final dividerLine = Color(0xffe0e0e0);

    final currentTab = context.select((ManageAppsBloc bloc) => bloc.state.tab);

    final userApps =
        context.select((ManageAppsBloc bloc) => bloc.state.userApps);
    final checkedUserApps =
        context.select((ManageAppsBloc bloc) => bloc.state.checkedUserApps);

    final systemApps =
        context.select((ManageAppsBloc bloc) => bloc.state.systemApps);
    final checkedSystemApps =
        context.select((ManageAppsBloc bloc) => bloc.state.checkedSystemApps);

    final Stream<ManageAppsProgressIndicatorStatus> progressIndicatorStream =
        context.select((ManageAppsBloc bloc) => bloc.progressIndicatorStream);

    final Stream<ManageAppsItemCount> itemCountStream =
        context.select((ManageAppsBloc bloc) => bloc.itemCountStream);

    Color getSegmentBtnColor(ManageAppsTab tab) {
      if (tab == currentTab) {
        return Color(0xffffffff);
      } else {
        return Color(0xff5b5c62);
      }
    }

    FocusNode rootFocusNode = FocusNode();
    rootFocusNode.canRequestFocus = true;
    rootFocusNode.requestFocus();

    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<ManageAppsBloc, ManageAppsState>(
              listener: (context, state) {
                final currentTab = state.tab;

                if (currentTab == ManageAppsTab.mine) {
                  context.read<ManageAppsBloc>().add(ManageAppsItemCountChanged(
                      ManageAppsItemCount(
                          total: state.userApps.length,
                          checkedCount: state.checkedUserApps.length)));
                } else {
                    context.read<ManageAppsBloc>().add(ManageAppsItemCountChanged(
                      ManageAppsItemCount(
                          total: state.systemApps.length,
                          checkedCount: state.checkedSystemApps.length)));
                }
              },
              listenWhen: (previous, current) =>
                  previous.userApps.length != current.userApps.length ||
                  previous.checkedUserApps.length !=
                      current.checkedUserApps.length ||
                  previous.systemApps.length != current.systemApps.length ||
                  previous.checkedSystemApps.length !=
                      current.checkedSystemApps.length)
        ],
        child: Focus(
            autofocus: true,
            focusNode: rootFocusNode,
            canRequestFocus: true,
            onKey: (node, event) {
              bool isControlPressed = Platform.isMacOS
                  ? event.isMetaPressed
                  : event.isControlPressed;

              bool isShiftPressed = event.isShiftPressed;

              ManageAppsKeyStatus status = ManageAppsKeyStatus.none;

              if (isControlPressed) {
                status = ManageAppsKeyStatus.ctrlDown;
              } else if (isShiftPressed) {
                status = ManageAppsKeyStatus.shiftDown;
              }

              context
                  .read<ManageAppsBloc>()
                  .add(ManageAppsKeyStatusChanged(status));

              if (Platform.isMacOS) {
                if (event.isMetaPressed &&
                    event.isKeyPressed(LogicalKeyboardKey.keyA)) {
                  _sendCtrlAEvent(context);
                  return KeyEventResult.handled;
                }
              } else {
                if (event.isControlPressed &&
                    event.isKeyPressed(LogicalKeyboardKey.keyA)) {
                  _sendCtrlAEvent(context);
                  return KeyEventResult.handled;
                }
              }

              return KeyEventResult.ignored;
            },
            child: Column(
              children: [
                Container(
                  child: Stack(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: UnifiedBackButton(
                            title: context.l10n.back,
                            width: 60,
                            height: 25,
                            margin: EdgeInsets.only(left: 15),
                            onTap: () {
                              navigatorKey.currentState?.pop();
                            },
                          )),
                      Align(
                          alignment: Alignment.center,
                          child: Text(context.l10n.manageApps,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xff616161), fontSize: 16.0))),
                      Align(
                          alignment: Alignment.center,
                          child: Container(
                            child: MaterialSegmentedControl<int>(
                              children: {
                                ManageAppsTab.mine.index: Container(
                                  child: Text(context.l10n.myApps,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: getSegmentBtnColor(
                                              ManageAppsTab.mine))),
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                ),
                                ManageAppsTab.preInstalled.index: Container(
                                    child: Text(context.l10n.preInstalledApps,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: getSegmentBtnColor(
                                                ManageAppsTab.preInstalled))),
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10))
                              },
                              selectionIndex: 0,
                              borderColor: Color(0xffdedede),
                              selectedColor: Color(0xffc3c3c3),
                              unselectedColor: Color(0xfff7f5f6),
                              borderRadius: 3.0,
                              verticalOffset: 0,
                              disabledChildren: [],
                              onSegmentChosen: (index) {},
                            ),
                            height: 30,
                          )),
                    ],
                  ),
                  height: Constant.HOME_NAVI_BAR_HEIGHT,
                  color: Color(0xfff6f6f6),
                ),
                Divider(color: dividerLine, height: 1.0, thickness: 1.0),
                StreamBuilder(
                  builder: (context, snapshot) {
                    ManageAppsProgressIndicatorStatus? status = null;

                    if (snapshot.hasData) {
                      status =
                          snapshot.data as ManageAppsProgressIndicatorStatus;
                    }

                    return Visibility(
                      child: LinearProgressIndicator(
                        value: status == null || status.total == 0
                            ? 0
                            : status.current / status.total,
                        color: Color(0xff3174de),
                        backgroundColor: Color(0xfffe3e3e3),
                        minHeight: 2,
                      ),
                      visible: status?.visible == true,
                    );
                  },
                  stream: progressIndicatorStream,
                ),
                Expanded(
                    child: IndexedStack(
                  children: [ManageUserAppsPage(), ManageSystemAppsPage()],
                )),
                Divider(color: dividerLine, height: 1.0, thickness: 1.0),
                StreamBuilder<ManageAppsItemCount>(
                  builder: ((context, snapshot) {
                    ManageAppsItemCount itemCount = ManageAppsItemCount();

                    if (snapshot.hasData) {
                      itemCount = snapshot.data!;
                    }

                    String itemNumStr = context.l10n.placeHolderItemCount01
                        .replaceFirst("%d", "${itemCount.total}");
                    ;

                    if (itemCount.checkedCount > 0) {
                      itemNumStr = context.l10n.placeHolderItemCount02
                          .replaceFirst("%d", "${itemCount.checkedCount}")
                          .replaceFirst("%d", "${itemCount.total}");
                    }

                    return Container(
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(itemNumStr,
                                style: TextStyle(
                                    color: Color(0xff646464), fontSize: 12))),
                        height: 20,
                        color: Color(0xfffafafa));
                  }),
                  stream: itemCountStream,
                ),
              ],
            )),
      ),
    );
  }
}
