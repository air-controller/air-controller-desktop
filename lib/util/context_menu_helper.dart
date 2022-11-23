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

          const dialogBorderRadius = BorderRadius.all(Radius.circular(5.0));

          final outerBorderColor = Colors.black.withOpacity(0.23);

          final innerBorderColor = Colors.white.withOpacity(0.45);

          return Container(
              width: 340,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: innerBorderColor,
                ),
                borderRadius: dialogBorderRadius,
                color: const Color.fromARGB(255, 242, 242, 242),
              ),
              foregroundDecoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: outerBorderColor,
                ),
                borderRadius: dialogBorderRadius,
              ),
              padding: const EdgeInsets.only(top: 5, bottom: 5),
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
              ));
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
