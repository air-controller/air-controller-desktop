import 'package:flutter/material.dart';

import '../../all_images/model/image_detail_arguments.dart';
import '../../constant.dart';
import '../../image_detail/view/image_detail_page.dart';
import 'home_image_page.dart';

class HomeImageFlow extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return HomeImageFlowState();
  }
}

class HomeImageFlowState extends State<HomeImageFlow> with AutomaticKeepAliveClientMixin {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: _navigatorKey,
        onGenerateRoute: _onGenerateRoute,
        onGenerateInitialRoutes: _onGenerateInitialRoutes,
        initialRoute: ImagePageRoute.IMAGE_HOME
    );
  }

  List<Route<dynamic>> _onGenerateInitialRoutes(NavigatorState navigator, String initialRoute) {
    return [
      PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return HomeImagePage(navigatorKey: _navigatorKey);
          },
          settings: RouteSettings(name: ImagePageRoute.IMAGE_HOME)
      )
    ];
  }


  Route _onGenerateRoute(RouteSettings settings) {
    if (settings.name == ImagePageRoute.IMAGE_HOME) {
      return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return HomeImagePage(navigatorKey: _navigatorKey);
          },
          settings: settings
      );
    }

    if (settings.name == ImagePageRoute.IMAGE_DETAIL) {
      return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            ImageDetailArguments arguments = settings.arguments as ImageDetailArguments;
            return ImageDetailPage(
                navigatorKey: _navigatorKey,
              images: arguments.images,
              index: arguments.index,
              source: arguments.source,
              extra: arguments.extra,
            );
          },
          settings: settings);
    }

    throw Exception('Unknown route: ${settings.name}');
  }

  @override
  bool get wantKeepAlive => true;
}

