import 'package:air_controller/manage_apps/view/manage_apps_home_page.dart';
import 'package:air_controller/manage_contacts/view/manage_apps_page.dart';
import 'package:air_controller/toolbox_home/view/toolbox_home_page.dart';
import 'package:flutter/material.dart';
import '../../constant.dart';

class ToolboxFlow extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ToolboxFlowState();
  }
}

class ToolboxFlowState extends State<ToolboxFlow>
    with AutomaticKeepAliveClientMixin {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: _navigatorKey,
        onGenerateRoute: _onGenerateRoute,
        onGenerateInitialRoutes: _onGenerateInitialRoutes,
        initialRoute: ImagePageRoute.IMAGE_HOME);
  }

  List<Route<dynamic>> _onGenerateInitialRoutes(
      NavigatorState navigator, String initialRoute) {
    return [
      PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return ToolboxHomePage(_navigatorKey);
          },
          settings: RouteSettings(name: ImagePageRoute.IMAGE_HOME))
    ];
  }

  Route _onGenerateRoute(RouteSettings settings) {
    if (settings.name == ImagePageRoute.IMAGE_HOME) {
      return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return ToolboxHomePage(_navigatorKey);
          },
          settings: settings);
    }

    if (settings.name == ToolboxPageRoute.MANAGE_APPS) {
      return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return ManageAppsHomePage(_navigatorKey);
          },
          settings: settings);
    }

    if (settings.name == ToolboxPageRoute.MANAGE_CONTACTS) {
      return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return ManageContactsPage(_navigatorKey);
          },
          settings: settings);
    }

    throw Exception('Unknown route: ${settings.name}');
  }

  @override
  bool get wantKeepAlive => true;
}
