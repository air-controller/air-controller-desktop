import 'package:flutter/material.dart';

class UnifiedLinearIndicator {
  double progress;
  String title;
  String description;
  final String cancelBtnText;
  final bool runInBackgroundVisible;
  final String runInBackgroundText;
  Function()? onCancelClick;
  Function()? onRunInBackgroundClick;

  late BuildContext context;

  bool isShowing = false;
  StateSetter? _stateSetter;
  BuildContext? _dialogContext;

  final _globalKey = GlobalKey();

  UnifiedLinearIndicator(
      {required this.context,
      this.progress = 0,
      this.title = '',
      this.description = '',
      this.cancelBtnText = 'Cancel',
      this.runInBackgroundVisible = false,
      this.runInBackgroundText = "Run in background",
      this.onCancelClick,
      this.onRunInBackgroundClick});

  void show() {
    showGeneralDialog(
        context: context,
        barrierLabel: "ProgressIndicatorDialog",
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          _dialogContext = context;

          return StatefulBuilder(
              builder: (context, stateSetter) {
                _stateSetter = stateSetter;

                return Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Wrap(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                              color: Color(0xff272727),
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                        Container(
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Color(0xfff2f2f2),
                            valueColor:
                                AlwaysStoppedAnimation(Color(0xff969696)),
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
                                    description,
                                    style: TextStyle(
                                        color: Color(0xffc0c0c0), fontSize: 14),
                                  ),
                                  Container(
                                    child: OutlinedButton(
                                        onPressed: () {
                                          onCancelClick == null
                                              ? dismiss()
                                              : onCancelClick!.call();
                                        },
                                        child: Text(cancelBtnText)),
                                    margin: EdgeInsets.only(left: 10),
                                  ),
                                  Visibility(
                                    child: Container(
                                      child: OutlinedButton(
                                          onPressed: () {
                                            onRunInBackgroundClick == null
                                                ? dismiss()
                                                : onRunInBackgroundClick!
                                                    .call();
                                          },
                                          child: Text(runInBackgroundText)),
                                      margin: EdgeInsets.only(left: 10),
                                    ),
                                    visible: runInBackgroundVisible,
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
              },
              key: _globalKey);
        }).then((value) {
      isShowing = false;
      _stateSetter = null;
    }).catchError((error) {
      isShowing = false;
      _stateSetter = null;
    });

    isShowing = true;
  }

  void updateTitle(String title) {
    if (_isUIMounted()) {
      _stateSetter?.call(() {
        this.title = title;
      });
    }
  }

  bool _isUIMounted() {
    return _globalKey.currentState?.mounted == true;
  }

  void updateDescription(String description) {
    if (_isUIMounted()) {
      _stateSetter?.call(() {
        this.description = description;
      });
    }
  }

  void updateProgress(double progress) {
    if (_isUIMounted()) {
      _stateSetter?.call(() {
        this.progress = progress;
      });
    }
  }

  void dismiss() {
    if (!_isUIMounted()) return;
    
    if (!isShowing || null == _dialogContext) return;

    Navigator.of(_dialogContext!).pop();
    _stateSetter = null;
    _dialogContext = null;
    isShowing = false;
  }
}
