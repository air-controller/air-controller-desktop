import 'dart:developer';

import 'package:air_controller/ext/build_context_x.dart';
import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../constant.dart';
import '../enter/view/enter_page.dart';
import '../home/bloc/home_bloc.dart';
import '../util/system_app_launcher.dart';

class HelpAndFeedbackPage extends StatefulWidget {
  Future<String> loadMdText(String path) async {
    return await rootBundle.loadString(path);
  }

  @override
  State<StatefulWidget> createState() {
    return _HelpAndFeedbackState();
  }
}

class _HelpAndFeedbackState extends State<HelpAndFeedbackPage> {
  String? _mdContent;
  String? _currentVersion;
  bool _isCheckUpdateHover = false;

  @override
  void initState() {
    super.initState();

    _updateVersionInfo();
  }

  void _updateVersionInfo() {
    CommonUtil.currentVersion().then((value) {
      setState(() {
        _currentVersion = value;
      });
    });
  }

  void _loadHelpMdText() {
    final currentAppLocale = context.currentAppLocale;

    String helpFileName = "help.zh.md";
    if (currentAppLocale.languageCode != "zh") {
      helpFileName = "help.en.md";
    }

    DefaultAssetBundle.of(context)
        .loadString('assets/docs/$helpFileName')
        .then((value) {
      setState(() {
        _mdContent = value;
      });
    }).catchError((error) {
      debugPrint("_loadHelpMdText, error: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadHelpMdText();

    return Column(
      children: [
        Container(
          child: Center(
            child: Text(context.l10n.helpAndFeedback,
                style: TextStyle(color: Color(0xff616161), fontSize: 16.0)),
          ),
          height: Constant.HOME_NAVI_BAR_HEIGHT,
          color: Color(0xfff6f6f6),
        ),
        Divider(color: Color(0xffe0e0e0), height: 1.0, thickness: 1.0),
        Expanded(
          child: Container(
            color: Colors.white,
            child: Markdown(
              data: _mdContent ?? "",
              styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
              selectable: false,
              onTapLink: (String text, String? href, String title) {
                SystemAppLauncher.openUrl(
                    href ?? "https://github.com/yuanhoujun");
              },
            ),
          ),
        ),
        Container(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.l10n.placeholderCurrentVersion
                      .replaceFirst("%s", _currentVersion ?? ""),
                  style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                Container(
                  child: InkWell(
                    child: Text(
                      context.l10n.checkUpdate,
                      style: TextStyle(
                          decoration: _isCheckUpdateHover
                              ? TextDecoration.underline
                              : TextDecoration.none,
                          color: Color(0xff2a6ad3),
                          fontSize: 14),
                    ),
                    onHover: (isHover) {
                      setState(() {
                        _isCheckUpdateHover = isHover;
                      });
                    },
                    onTap: () {
                      // eventBus.fire(CheckForUpdatesEvent(false));
                      context
                          .read<HomeBloc>()
                          .add(HomeCheckUpdateRequested(isAutoCheck: false));
                    },
                  ),
                  margin: EdgeInsets.only(left: 10),
                )
              ],
            ),
          ),
          padding: EdgeInsets.only(bottom: 20, top: 10),
          color: Colors.white,
        )
      ],
    );
  }
}
