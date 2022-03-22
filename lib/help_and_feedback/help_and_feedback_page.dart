import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mobile_assistant_client/enter/enter.dart';
import 'package:mobile_assistant_client/l10n/l10n.dart';
import 'package:mobile_assistant_client/util/system_app_launcher.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../constant.dart';

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

  @override
  void initState() {
    super.initState();
    _loadHelpMdText();
  }

  void _loadHelpMdText() {
    final enterContext = EnterPage.enterKey.currentContext;
    String languageCode = "en";

    if (null != enterContext) {
      languageCode = Localizations.localeOf(enterContext).languageCode;
    }

    log("languageCode: $languageCode");

    DefaultAssetBundle.of(context)
        .loadString('assets/docs/help.${languageCode}.md')
        .then((value) {
      debugPrint("_loadHelpMdText: $value");
      setState(() {
        _mdContent = value;
      });
    }).catchError((error) {
      debugPrint("_loadHelpMdText, error: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
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
        )
      ],
    );
  }
}
