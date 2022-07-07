import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import '../widget/overlay_menu_item.dart';

class ContextMenuHelper {
  static ContextMenuHelper _instance = ContextMenuHelper._internal();
  CancelFunc? _cancelFunc;
  bool _isShow = false;

  factory ContextMenuHelper() => _instance;

  ContextMenuHelper._internal();

  void showContextMenu(
      {required BuildContext context,
      required Offset? globalOffset,
      required List<ContextMenuItem> items}) {
    BotToast.showAttachedWidget(
        attachedBuilder: (cancelFunc) {
          _cancelFunc = cancelFunc;

          return ClipRect(child: BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(items.length * 2 - 1, (index) {
                    Divider divider = Divider(
                        height: 1,
                        thickness: 1,
                        indent: 6,
                        endIndent: 6,
                        color: Color(0xffbabebf));

                    if (index.isEven) {
                      return items[index ~/ 2];
                    } else {
                      return divider;
                    }
                  }),
                ),
                decoration: BoxDecoration(
                    color: Color(0xffdddddd).withOpacity(0.85),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    border: Border.all(color: Color(0xffb8b8b8), width: 1)),
                padding: EdgeInsets.all(5),
                width: 320,
              )),);
        },
        allowClick: false,
        target: globalOffset,
        preferDirection: PreferDirection.bottomLeft);
    _isShow = true;
  }

  void hideContextMenu() {
    if (_isShow) {
      _cancelFunc?.call();
      _isShow = false;
    }
  }
}

class ContextMenuItem extends StatelessWidget {
  final double width;
  final double height;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final String title;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const ContextMenuItem(
      {Key? key,
      this.width = 320,
      this.height = 25,
      this.padding = const EdgeInsets.symmetric(horizontal: 8),
      this.margin = const EdgeInsets.symmetric(vertical: 6),
      required this.title,
      this.backgroundColor = Colors.transparent,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayMenuItem(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: BorderRadius.all(Radius.circular(3)),
      defaultBackgroundColor: backgroundColor,
      title: title,
      onTap: () {
        onTap?.call();
      },
    );
  }
}
