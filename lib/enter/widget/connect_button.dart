import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ConnectButton extends StatelessWidget {
  final String? title;
  final Color titleColor;
  final Color pressedTitleColor;
  final Color borderColor;
  final double borderWidth;
  final Color backgroundColor;
  final Color pressedBackgroundColor;
  final Color shadowColor;
  BorderRadiusGeometry borderRadius;
  final GestureTapCallback? onTap;
  final EdgeInsets padding;

  bool _isConnectPressed = false;

  ConnectButton(
    this.title ,
  {
    Key? key,
    this.titleColor = const Color(0xff949494),
    this.pressedTitleColor = Colors.white,
    this.borderColor = const Color(0xffe5e5e5),
    this.borderWidth = 1.5,
    this.backgroundColor = const Color(0xfffefefe),
    this.pressedBackgroundColor = const Color(0xff6989e2),
    this.shadowColor = const Color(0xffe5e5e5),
    this.borderRadius = const BorderRadius.all(Radius.circular(5.0)),
    this.onTap,
    this.padding = const EdgeInsets.fromLTRB(14, 6, 10, 6)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return GestureDetector(
        child: Container(
          child: Wrap(
            children: [
              Text(
                title ?? "",
                style: TextStyle(
                    color: _isConnectPressed ? pressedTitleColor : titleColor,
                    fontSize: 14),
              ),
              Container(
                child: Image.asset("assets/icons/ic_right_arrow.png",
                    width: 15, height: 15),
                margin: EdgeInsets.only(left: 3),
              )
            ],
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
          ),
          decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(color: borderColor, width: borderWidth),
              color: _isConnectPressed ? pressedBackgroundColor : backgroundColor,
              boxShadow: [
                BoxShadow(
                    color: shadowColor,
                    offset: Offset(0, 0),
                    blurRadius: 1.0)
              ]),
          padding: padding,
        ),
        onTap: () {
         onTap?.call();
        },
        onTapDown: (event) {
          setState(() {
            _isConnectPressed = true;
          });
        },
        onTapCancel: () {
          setState(() {
            _isConnectPressed = false;
          });
        },
        onTapUp: (event) {
          setState(() {
            _isConnectPressed = false;
          });
        },
      );
    });
  }
}
