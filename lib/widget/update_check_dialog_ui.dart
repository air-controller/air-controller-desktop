import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../constant.dart';

// ignore: must_be_immutable
class UpdateCheckDialogUI extends StatelessWidget {
  final String title;
  final String version;
  final String date;
  final String updateInfo;
  final String updateButtonText;
  final Function()? onUpdateClick;
  final Function()? onSeeMoreClick;
  final Function()? onCloseClick;

  bool _isSeeMoreHover = false;
  bool _isCloseTapDown = false;

  UpdateCheckDialogUI({
      Key? key,
      required this.title,
      required this.version,
      required this.date,
      required this.updateInfo,
      required this.updateButtonText,
      this.onUpdateClick,
      this.onSeeMoreClick,
      this.onCloseClick
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
        child: Stack(
          children: [
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/icons/ic_update.png",
                          width: 50, height: 50),
                      Container(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xff202020),
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        margin: EdgeInsets.only(left: 3),
                      )
                    ],
                  ),
                  Container(
                    child: Text(
                      "${Constant.APP_NAME} version ${version} - $date",
                      style: TextStyle(color: Color(0xff999999), fontSize: 15),
                    ),
                    margin: EdgeInsets.only(top: 0),
                  ),
                  Container(
                    child: Markdown(
                        data: this.updateInfo,
                        shrinkWrap: true,
                        padding: EdgeInsets.only(left: 3, top: 0),
                        styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
                        styleSheet:
                            MarkdownStyleSheet.fromTheme(Theme.of(context))
                                .copyWith(
                                    listIndent: 5,
                                    p: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        ?.copyWith(
                                            fontSize: 14.0,
                                            color: Color(0xff71777c),
                                            overflow: TextOverflow.ellipsis),
                                    listBullet: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        ?.copyWith(
                                            fontSize: 14.0,
                                            color: Color(0xff71777c)))),
                    width: 480,
                    height: 100,
                    margin: EdgeInsets.only(top: 5, bottom: 10),
                  ),
                  StatefulBuilder(builder: (context, setState) {
                    return InkWell(
                      child: Text("See more",
                          style: TextStyle(
                              decoration: _isSeeMoreHover
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                              color: Color(0xff2a6ad3),
                              fontSize: 15)),
                      onTap: () {
                        this.onSeeMoreClick?.call();
                      },
                      onHover: (isHover) {
                        setState(() {
                          _isSeeMoreHover = isHover;
                        });
                      },
                    );
                  })
                ],
              ),
              margin: EdgeInsets.only(top: 20, left: 20, right: 20),
            ),
            Positioned(
                right: 30,
                bottom: 30,
                child: OutlinedButton(
                  onPressed: () {
                    this.onUpdateClick?.call();
                  },
                  child: Text(
                    updateButtonText,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Color(0x993578f6);
                        }

                        return Color(0xff3578f6);
                      }),
                      minimumSize: MaterialStateProperty.all(Size(0, 0)),
                      padding: MaterialStateProperty.all(
                          EdgeInsets.fromLTRB(15, 15, 15, 15))),
                )),
            Positioned(
                right: 10,
                top: 10,
                child: StatefulBuilder(builder: (context, setState) {
                  return InkResponse(
                    child: Icon(Icons.close,
                        color: _isCloseTapDown
                            ? Color(0x995890f6)
                            : Color(0xff5890f6)),
                    onTapDown: (details) {
                      setState(() {
                        _isCloseTapDown = true;
                      });
                    },
                    onTap: () {
                      setState(() {
                        _isCloseTapDown = false;
                      });
                      
                      onCloseClick?.call();
                    },
                    onTapCancel: () {
                      setState(() {
                        _isCloseTapDown = false;
                      });
                    },
                    autofocus: true,
                  );
                })),
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Color(0xfff5f5f5),
        ),
        width: 550,
        height: 250,
      ),
    );
  }
}
