import 'package:flutter/material.dart';

class ConfirmDialogBuilder {
  String? contentStr;
  String? descStr;
  String negativeBtnStr = "Cancel";
  String positiveBtnStr = "Sure";
  final _OPERATE_BTN_HEIGHT = 35.0;
  final _OPERATE_BTN_WIDTH = 115.0;
  bool _isNegativeBtnDown = false;
  bool _isPositiveBtnDown = false;
  Function(BuildContext context)? _onPositiveClick;
  Function(BuildContext context)? _onNegativeClick;

  ConfirmDialogBuilder();

  ConfirmDialogBuilder content(String content) {
    this.contentStr = content;
    return this;
  }

  ConfirmDialogBuilder onPositiveClick(
      Function(BuildContext context)? onPositiveClick) {
    _onPositiveClick = onPositiveClick;
    return this;
  }

  ConfirmDialogBuilder onNegativeClick(
      Function(BuildContext context)? onNegativeClick) {
    _onNegativeClick = onNegativeClick;
    return this;
  }

  ConfirmDialogBuilder desc(String desc) {
    this.descStr = desc;
    return this;
  }

  ConfirmDialogBuilder negativeBtnText(String str) {
    this.negativeBtnStr = str;
    return this;
  }

  ConfirmDialogBuilder positiveBtnText(String str) {
    this.positiveBtnStr = str;
    return this;
  }

  Dialog build() {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Color(0xfff5f5f5),
        elevation: 0,
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/icons/ic_tips.png",
                              width: 60, height: 60),
                          Container(
                            child: Text(contentStr ?? "",
                                style: TextStyle(
                                    color: Color(0xff3d3d3d),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                            margin: EdgeInsets.only(top: 5),
                          ),
                          Container(
                            child: Text(
                              descStr ?? "",
                              style: TextStyle(
                                  color: Color(0xff262626), fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                            margin: EdgeInsets.only(top: 5),
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  child: Container(
                                    child: Text(
                                      negativeBtnStr,
                                      style: TextStyle(
                                          color: Color(0xff383838),
                                          fontSize: 14.0),
                                      textAlign: TextAlign.center,
                                    ),
                                    decoration: BoxDecoration(
                                        color: _isNegativeBtnDown
                                            ? Color(0xffadaba7)
                                            : Color(0xffd0cecf), //adaba7
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)),
                                        border: Border.all(
                                            color: Color(0xffadacac),
                                            width: 3.0)),
                                    width: _OPERATE_BTN_WIDTH,
                                    height: _OPERATE_BTN_HEIGHT,
                                    alignment: Alignment.center,
                                  ),
                                  onTapDown: (detail) {
                                    setState(() => _isNegativeBtnDown = true);
                                  },
                                  onTapUp: (detail) {
                                    setState(() => _isNegativeBtnDown = false);
                                  },
                                  onTapCancel: () {
                                    setState(() => _isNegativeBtnDown = false);
                                  },
                                  onTap: () {
                                    _onNegativeClick?.call(context);
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    child: Text(
                                      positiveBtnStr,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _isPositiveBtnDown
                                          ? Color(0xff373a3d)
                                          : Color(0xff2d373e),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                    ),
                                    width: _OPERATE_BTN_WIDTH,
                                    height: _OPERATE_BTN_HEIGHT,
                                    margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                    alignment: Alignment.center,
                                  ),
                                  onTap: () {
                                    _onPositiveClick?.call(context);
                                  },
                                  onTapDown: (detail) {
                                    setState(() => _isPositiveBtnDown = true);
                                  },
                                  onTapCancel: () {
                                    setState(() => _isPositiveBtnDown = false);
                                  },
                                  onTapUp: (detail) {
                                    setState(() => _isPositiveBtnDown = false);
                                  },
                                )
                              ],
                            ),
                            margin: EdgeInsets.only(top: 30),
                          )
                        ]),
                    decoration: BoxDecoration(
                      color: Color(0xfff5f5f5),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      border: Border.all(color: Color(0xffb8b8b8), width: 1)
                    ),
                    width: 320,
                    height: 220,
                  );
          },
        ));
  }
}
