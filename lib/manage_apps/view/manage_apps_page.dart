import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/manage_apps/bloc/manage_apps_bloc.dart';
import 'package:air_controller/manage_apps/view/manage_system_apps_page.dart';
import 'package:air_controller/manage_apps/view/manage_user_apps_page.dart';
import 'package:air_controller/model/app_info.dart';
import 'package:air_controller/repository/common_repository.dart';
import 'package:air_controller/util/common_util.dart';
import 'package:air_controller/widget/unfied_back_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_segmented_control/material_segmented_control.dart';

import '../../constant.dart';
import '../../network/device_connection_manager.dart';
import '../../widget/unified_delete_button.dart';

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

  @override
  Widget build(BuildContext context) {
    final dividerLine = Color(0xffe0e0e0);
    final TextStyle headerStyle = TextStyle(fontSize: 14, color: Colors.black);

    final apps = context.select((ManageAppsBloc bloc) => bloc.state.apps);
    final checkedApps =
        context.select((ManageAppsBloc bloc) => bloc.state.apps);
    final status = context.select((ManageAppsBloc bloc) => bloc.state.status);
    final currentTab = context.select((ManageAppsBloc bloc) => bloc.state.tab);

    String itemNumStr = context.l10n.placeHolderItemCount01
        .replaceFirst("%d", "${apps.length}");
    if (checkedApps.length > 0) {
      itemNumStr = context.l10n.placeHolderItemCount02
          .replaceFirst("%d", "${checkedApps.length}")
          .replaceFirst("%d", "${apps.length}");
    }

    Color getSegmentBtnColor(ManageAppsTab tab) {
      if (tab == currentTab) {
        return Color(0xffffffff);
      } else {
        return Color(0xff5b5c62);
      }
    }

    return Scaffold(
      body: Focus(
          autofocus: true,
          focusNode: null,
          canRequestFocus: true,
          onKey: (node, event) {
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
                                  padding: EdgeInsets.only(left: 10, right: 10))
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
              Expanded(
                  child: IndexedStack(
                children: [ManageUserAppsPage(), ManageSystemAppsPage()],
              )),
              Divider(color: dividerLine, height: 1.0, thickness: 1.0),
              Container(
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(itemNumStr,
                          style: TextStyle(
                              color: Color(0xff646464), fontSize: 12))),
                  height: 20,
                  color: Color(0xfffafafa)),
            ],
          )),
    );
  }
}
