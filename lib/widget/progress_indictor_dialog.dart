import 'dart:developer';

import 'package:flutter/material.dart';

class ProgressIndicatorDialog {
  double _progress = 0;
  String _title = "";
  String _subtitle = "";
  String _cancelBtnText = "Cancel";
  late BuildContext context;
  Function()? _onCancelClick;
  bool isShowing = false;
  StateSetter? _stateSetter;
  BuildContext? _dialogContext;

  ProgressIndicatorDialog({required BuildContext context, String title = "", String subtitle = ""}) {
    this.context = context;
    _title = title;
    _subtitle = subtitle;
  }

  void show() {

    showGeneralDialog(
        context: context,
        barrierLabel: "ProgressIndicatorDialog",
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          _dialogContext = context;

          return StatefulBuilder(builder: (context, stateSetter) {
            _stateSetter = stateSetter;

            return Align(
              alignment: Alignment.center,
              child: Container(
                child: Wrap(
                  children: [
                    Text(
                      _title,
                      style: TextStyle(
                          color: Color(0xff272727),
                          fontSize: 16,
                          fontWeight: FontWeight.normal
                      ),
                    ),
                    Container(
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Color(0xfff2f2f2),
                        valueColor: AlwaysStoppedAnimation(Color(0xff969696)),
                        minHeight: 10,
                      ),
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                    ),
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _subtitle,
                                style: TextStyle(
                                    color: Color(0xffc0c0c0),
                                    fontSize: 14
                                ),
                              ),
                              Container(
                                child: OutlinedButton(
                                    onPressed: () {
                                      if (null != _onCancelClick) {
                                        _onCancelClick!.call();
                                      } else {
                                        dismiss();
                                      }
                                    },
                                    child: Text(
                                        "${_cancelBtnText}"
                                    )),
                                margin: EdgeInsets.only(left: 10),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: Colors.white,
                ),
                width: 500,
                padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
              ),
            );
          });
        }
    ).then((value) {
      debugPrint("ProgressIndicatorDialog dismiss...");

      isShowing = false;
      _stateSetter = null;
    }).catchError((error) {
      debugPrint("ProgressIndicatorDialog catchError: $error");

      isShowing = false;
      _stateSetter = null;
    });

    isShowing = true;
  }

  void set title(String title) {
    debugPrint("ProgressIndicatorDialog, _stateSetter == null : ${_stateSetter == null}");
    if (null != _stateSetter && isShowing) {
      _stateSetter?.call(() {
        _title = title;
        debugPrint("ProgressIndicatorDialog set title: $title");
      });
    } else {
      _title = title;
    }
  }

  void set subtitle(String subtitle) {
    _stateSetter?.call(() {
      _subtitle = subtitle;
    });
  }

  void updateProgress(double progress) {
    _stateSetter?.call(() {
      _progress = progress;
    });
  }

  void onCancelClick(void callback()) {
    _onCancelClick = callback;
  }

  void dismiss() {
    if (null == _dialogContext) return;

    Navigator.of(_dialogContext!).pop();
    _stateSetter = null;
  }
}