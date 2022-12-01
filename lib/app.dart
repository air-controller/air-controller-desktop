import 'package:air_controller/enter/view/web_enter_page.dart';
import 'package:air_controller/index/index_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constant.dart';
import 'enter/bloc/enter_bloc.dart';
import 'enter/view/enter_page.dart';
import 'home/home.dart';
import 'l10n/l10n.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (context) => EnterBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: !Constant.HIDE_DEBUG_MARK,
        title: 'AirController',
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale("en", "US"),
          Locale("zh", "CN"),
          Locale("es", "ES")
        ],
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            textSelectionTheme:
                TextSelectionThemeData(selectionColor: Color(0xffe0e0e0)),
            textTheme: GoogleFonts.robotoSerifTextTheme(textTheme)),
        home: kIsWeb ? IndexPage() : EnterPage(key: EnterPage.enterKey),
        navigatorObservers: [
          FlutterSmartDialog.observer,
          BotToastNavigatorObserver()
        ],
        builder: (context, child) {
          final smartDialogBuilder = FlutterSmartDialog.init();
          child = smartDialogBuilder(context, child);

          final botToastBuilder = BotToastInit();
          child = botToastBuilder(context, child);
          return child;
        },
        onGenerateRoute: (settings) {
          final route = settings.name;
          final index = route?.indexOf('?');

          final routeName = route != null && index != null && index != -1
              ? route.substring(0, index)
              : route;

          if (routeName == routeIndex) {
            return MaterialPageRoute(
                builder: (context) => IndexPage(), settings: settings);
          }

          if (routeName == routeHome) {
            return MaterialPageRoute(
                builder: (context) => HomePage(), settings: settings);
          }

          if (kIsWeb) {
            return MaterialPageRoute(
                builder: (context) => WebEnterPage(), settings: settings);
          } else {
            return MaterialPageRoute(
                builder: (context) => EnterPage(), settings: settings);
          }
        },
      ),
    );
  }
}
