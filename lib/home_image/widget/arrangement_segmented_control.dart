import 'package:flutter/material.dart';
import 'package:mobile_assistant_client/l10n/l10n.dart';
import 'package:mobile_assistant_client/model/arrangement_mode.dart';

// ignore: must_be_immutable
class ArrangementSegmentedControl extends StatelessWidget {
  ArrangementMode _arrangementMode = ArrangementMode.grid;
  final Function(ArrangementMode previous, ArrangementMode current)? onChange;

  ArrangementSegmentedControl(
      {Key? key, required ArrangementMode initMode,
        this.onChange})
      : super(key: key) {
    _arrangementMode = initMode;
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = 17.0;
    final padding = EdgeInsets.fromLTRB(10, 4, 10, 4);

    return StatefulBuilder(builder: (context, setState) {
      return Container(
        child: Row(
          children: [
            Tooltip(
              child: GestureDetector(
                child: Container(
                  child: Container(
                    child: Image.asset(
                      _isChecked(ArrangementMode.grid)
                          ? "assets/icons/ic_picture_default_selected.png"
                          : "assets/icons/ic_picture_default_normal.png",
                      width: iconSize,
                      height: iconSize,
                      // opacity: AlwaysStoppedAnimation(0.6),
                      isAntiAlias: true,
                    ),
                    padding: padding,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5.0),
                          bottomLeft: Radius.circular(5.0)),
                      color: _isChecked(ArrangementMode.grid)
                          ? Color(0xffc3c3c3)
                          : Color(0xfff4f4f4),
                    ),
                    margin: EdgeInsets.only(left: 1, top: 1, bottom: 1),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5.0),
                        bottomLeft: Radius.circular(5.0)),
                    color: _isChecked(ArrangementMode.grid)
                        ? Color(0xffababab)
                        : Color(0xffdedede),
                  ),
                ),
                onTap: () {
                  setState(() {
                    if (_arrangementMode != ArrangementMode.grid) {
                      onChange?.call(_arrangementMode, ArrangementMode.grid);
                      _arrangementMode = ArrangementMode.grid;
                    }
                  });
                },
              ),
              message: context.l10n.defaultType,
            ),

            Container(
              color: _isChecked(ArrangementMode.grid) || _isChecked(ArrangementMode.groupByDay)
                  ? Color(0xffababab)
                  : Color(0xffdedede),
              width: 1,
              margin: EdgeInsets.only(top: 0.5, bottom: 0.5),
            ),

            Tooltip(
              child: GestureDetector(
                child: Container(
                  child: Image.asset(
                      _isChecked(ArrangementMode.groupByDay)
                          ? "assets/icons/ic_picture_daily_selected.png"
                          : "assets/icons/ic_picture_daily_normal.png",
                      width: iconSize,
                      height: iconSize),
                  padding: padding,
                  decoration: BoxDecoration(
                    border: Border(
                      top:  BorderSide(color: _isChecked(ArrangementMode.groupByDay)
                          ? Color(0xffababab) : Color(0xffdedede), width: 1.0),
                      bottom:  BorderSide(color: _isChecked(ArrangementMode.groupByDay)
                          ? Color(0xffababab) : Color(0xffdedede), width: 1.0),
                    ),
                    color: _isChecked(ArrangementMode.groupByDay)
                        ? Color(0xffc3c3c3)
                        : Color(0xfff4f4f4),
                  ),
                ),
                onTap: () {
                  setState(() {
                    if (_arrangementMode != ArrangementMode.groupByDay) {
                      onChange?.call(_arrangementMode, ArrangementMode.groupByDay);
                      _arrangementMode = ArrangementMode.groupByDay;
                    }
                  });
                },
              ),
              message: context.l10n.daily,
            ),

            Container(
              color: _isChecked(ArrangementMode.groupByMonth) || _isChecked(ArrangementMode.groupByDay)
                  ? Color(0xffababab)
                  : Color(0xffdedede),
              width: 1,
              margin: EdgeInsets.only(top: 0.5, bottom: 0.5),
            ),

            Tooltip(
              child: GestureDetector(
                child: Container(
                  child: Container(
                    child: Image.asset(
                        _isChecked(ArrangementMode.groupByMonth)
                            ? "assets/icons/ic_picture_monthly_selected.png"
                            : "assets/icons/ic_picture_monthly_normal.png",
                        width: iconSize,
                        height: iconSize),
                    padding: padding,
                    decoration: BoxDecoration(
                      color: _isChecked(ArrangementMode.groupByMonth)
                          ? Color(0xffc3c3c3)
                          : Color(0xfff4f4f4),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(5.0),
                          bottomRight: Radius.circular(5.0)),
                    ),
                    margin: EdgeInsets.only(right: 1, top: 1, bottom: 1),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5.0),
                        bottomRight: Radius.circular(5.0)),
                    color: _isChecked(ArrangementMode.groupByMonth)
                        ? Color(0xffababab)
                        : Color(0xffdedede),
                  ),
                ),
                onTap: () {
                  setState(() {
                    if (_arrangementMode != ArrangementMode.groupByMonth) {
                      onChange?.call(
                          _arrangementMode, ArrangementMode.groupByMonth);
                      _arrangementMode = ArrangementMode.groupByMonth;
                    }
                  });
                },
              ),
              message: context.l10n.monthly,
            ),
          ],
        ),
        height: 28,
      );
    });
  }

  bool _isChecked(ArrangementMode current) {
    return _arrangementMode == current;
  }
}
