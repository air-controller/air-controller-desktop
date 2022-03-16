import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:mobile_assistant_client/enter/bloc/enter_bloc.dart';
import 'package:mobile_assistant_client/enter/view/enter_page.dart';
import 'package:mobile_assistant_client/l10n/l10n.dart';

import 'constant.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          Locale("zh", "CH")
        ],
        locale: Locale("en"),
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            textSelectionTheme: TextSelectionThemeData(
                selectionColor: Color(0xffe0e0e0)
            ),
            fontFamily: 'NotoSansSC'
        ),
        home: EnterPage(),
        navigatorObservers: [FlutterSmartDialog.observer],
        builder: FlutterSmartDialog.init(),
      ),
    );
  }
}