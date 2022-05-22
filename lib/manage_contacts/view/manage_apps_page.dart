import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/manage_apps/bloc/manage_apps_bloc.dart';
import 'package:air_controller/repository/common_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constant.dart';

class ManageContactsPage extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const ManageContactsPage(this.navigatorKey);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ManageAppsHomeBloc(context.read<CommonRepository>())
        ..add(ManageAppsSubscriptionRequested()),
      child: _ManageContactsView(this.navigatorKey),
    );
  }
}

class _ManageContactsView extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  bool _isBackBtnDown = false;

  _ManageContactsView(this.navigatorKey);

  @override
  Widget build(BuildContext context) {
    final dividerLine = Color(0xffe0e0e0);

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
                        child: Row(
                          children: [
                            // 返回按钮
                            StatefulBuilder(
                                builder: (context, setState) => GestureDetector(
                                      child: Container(
                                        child: Row(
                                          children: [
                                            Image.asset(
                                                "assets/icons/icon_right_arrow.png",
                                                width: 12,
                                                height: 12),
                                            Container(
                                              child: Text(context.l10n.back,
                                                  style: TextStyle(
                                                      color: Color(0xff5c5c62),
                                                      fontSize: 13)),
                                              margin: EdgeInsets.only(left: 3),
                                            ),
                                          ],
                                        ),
                                        decoration: BoxDecoration(
                                            color: _isBackBtnDown
                                                ? Color(0xffe8e8e8)
                                                : Color(0xfff3f3f4),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(3.0)),
                                            border: Border.all(
                                                color: Color(0xffdedede),
                                                width: 1.0)),
                                        height: 25,
                                        padding:
                                            EdgeInsets.only(right: 6, left: 2),
                                        margin: EdgeInsets.only(left: 15),
                                      ),
                                      onTap: () {
                                        navigatorKey.currentState?.pop();
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
                                    )),
                          ],
                        )),
                  ],
                ),
                height: Constant.HOME_NAVI_BAR_HEIGHT,
                color: Color(0xfff6f6f6),
              ),
              Divider(color: dividerLine, height: 1.0, thickness: 1.0),
            ],
          )),
    );
  }
}
