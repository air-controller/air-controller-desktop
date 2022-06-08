import 'package:air_controller/l10n/l10n.dart';
import 'package:flutter/material.dart';

class BottomCountView extends StatelessWidget {
  final int checkedCount;
  final int totalCount;

  const BottomCountView({required this.checkedCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    String itemNumStr =
        context.l10n.placeHolderItemCount01.replaceFirst("%d", "$totalCount");
    if (checkedCount > 0) {
      itemNumStr = context.l10n.placeHolderItemCount02
          .replaceFirst("%d", "${checkedCount}")
          .replaceFirst("%d", "${totalCount}");
    }

    return Column(
      children: [
        Divider(color: Color(0xffe0e0e0), height: 1.0, thickness: 1.0),
        Container(
          child: Align(
            alignment: Alignment.center,
            child: Text(itemNumStr,
                style: TextStyle(fontSize: 12, color: Color(0xff646464))),
          ),
          height: 20,
          color: Color(0xfffafafa),
        )
      ],
    );
  }
}
