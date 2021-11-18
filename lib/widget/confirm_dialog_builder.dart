import 'package:flutter/material.dart';

class ConfirmDialogBuilder {
  String? contentStr;
  String? descStr;
  String negativeBtnStr = "Cancel";
  String positiveBtnStr = "Sure";

  ConfirmDialogBuilder();

  ConfirmDialogBuilder content(String content) {
    this.contentStr = content;
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5)
      ),
      backgroundColor: Color(0xffc6c6c6),
      elevation: 0,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("icons/ic_android.jpg", width: 30, height: 30),
            Text(contentStr ?? "", style: TextStyle(
              color: Color(0xff11171d),
              fontSize: 14
            )),
            Text(descStr ?? "", style: TextStyle(
                color: Color(0xff060f19),
                fontSize: 14
            )),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    negativeBtnStr,
                    style: TextStyle(
                      color: Color(0xff383838),
                      fontSize: 14.0
                    )
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xffd0cecf),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(color: Color(0xffadacac), width: 3.0)
                  ),
                  width: 80,
                ),

                Container(
                  child: Text(
                      negativeBtnStr,
                      style: TextStyle(
                        color: Colors.white, fontSize: 14.0
                      )
                  ),
                  decoration: BoxDecoration(
                      color: Color(0xff2d373e),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      border: Border.all(color: Color(0xffadacac), width: 3.0)
                  ),
                  width: 80,
                ),
              ],
            )
          ]
        ),
        decoration: BoxDecoration(
            color: Color(0xffc6c6c6),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        width: 300,
        height: 200,
      ),
    );
  }
}