import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/toolbox_home/bloc/toolbox_home_bloc.dart';
import 'package:air_controller/toolbox_home/model/toolbox_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constant.dart';

/// Toolbox enter page.
class ToolboxHomePage extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const ToolboxHomePage(this.navigatorKey);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ToolboxHomeBloc(),
      child: _ToolboxHomeView(this.navigatorKey),
    );
  }
}

class _ToolboxHomeView extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const _ToolboxHomeView(this.navigatorKey);

  @override
  Widget build(BuildContext context) {
    final items = [
      ToolboxItem(ToolboxModule.manageApps, context.l10n.manageApps,
          "assets/icons/ic_manage_apps.png"),
      ToolboxItem(ToolboxModule.manageContacts, context.l10n.manageContacts,
          "assets/icons/ic_manage_contacts.png"),
    ];

    final dividerLineColor = Color(0xffe0e0e0);
    final _IMAGE_SPACE = 15.0;

    return Scaffold(
        body: Focus(
      autofocus: false,
      focusNode: null,
      child: GestureDetector(
        child: Column(children: [
          Container(
              child: Stack(children: [
                Align(
                    alignment: Alignment.center,
                    child: Text(context.l10n.toolbox,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xff616161), fontSize: 16.0))),
              ]),
              color: Color(0xfff4f4f4),
              height: Constant.HOME_NAVI_BAR_HEIGHT),
          Divider(
            color: dividerLineColor,
            height: 1.0,
            thickness: 1.0,
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 160,
                  crossAxisSpacing: _IMAGE_SPACE,
                  childAspectRatio: 1.0,
                  mainAxisSpacing: _IMAGE_SPACE),
              itemBuilder: (context, index) {
                final item = items[index];

                return GestureDetector(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          item.icon,
                          width: 60,
                          height: 60,
                        ),
                        Container(
                          child: Text(
                            item.name,
                            style: TextStyle(color: Color(0xff333333)),
                          ),
                          margin: EdgeInsets.only(top: 10),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    switch (item.module) {
                      case ToolboxModule.manageApps:
                        navigatorKey.currentState
                            ?.pushNamed(ToolboxPageRoute.MANAGE_APPS);
                        break;

                      case ToolboxModule.manageContacts:
                        navigatorKey.currentState
                            ?.pushNamed(ToolboxPageRoute.MANAGE_CONTACTS);
                        break;
                    }
                  },
                );
              },
              itemCount: items.length,
            ),
          ),
          Divider(color: dividerLineColor, height: 1.0, thickness: 1.0),
          Container(
              child: Align(
                  alignment: Alignment.center,
                  child: Text("",
                      style:
                          TextStyle(color: Color(0xff646464), fontSize: 12))),
              height: 20,
              color: Color(0xfffafafa)),
          Divider(color: dividerLineColor, height: 1.0, thickness: 1.0),
        ], mainAxisSize: MainAxisSize.max),
        onTap: () {},
      ),
      onFocusChange: (value) {},
      onKey: (node, event) {
        return KeyEventResult.ignored;
      },
    ));
  }
}
