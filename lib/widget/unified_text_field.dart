import 'package:flutter/material.dart';

class UnifiedTextField extends StatelessWidget {
  final TextEditingController? controller;

  /// Mark whether the clear icon is visible when the input box has content.
  final bool clearVisible;
  final Widget? clearIcon;
  final MaterialStateProperty<Color>? borderColor;
  final double borderRadius;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final EdgeInsetsGeometry contentPadding;
  final Color? cursorColor;
  final double? cursorHeight;
  final ValueChanged<String>? onChange;

  bool _needShowClearIcon = false;

  UnifiedTextField(
      {this.controller,
      this.clearVisible = true,
      this.clearIcon,
      this.borderColor,
      this.borderRadius = 0,
      this.hintText,
      this.hintStyle,
      this.style,
      this.contentPadding = const EdgeInsets.fromLTRB(15, 5, 15, 5),
      this.cursorColor,
      this.cursorHeight,
      this.onChange});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      var realClearIcon = clearIcon;

      if (_needShowClearIcon) {
        if (null == realClearIcon) {
          realClearIcon = IconButton(
              onPressed: () {
                this.controller?.clear();
                setState(() {
                  _needShowClearIcon = false;
                });
              },
              icon: Icon(Icons.close, size: 15, color: Color(0xff666666)));
        }
      } else {
        realClearIcon = null;
      }

      var realBorderColor = MaterialStateProperty.resolveWith<Color>((states) {
        const Set<MaterialState> interactiveStates = <MaterialState> {
          MaterialState.pressed,
          MaterialState.hovered,
          MaterialState.focused,
        };
        if (states.any(interactiveStates.contains)) {
          return Color(0xff999999);
        }
        return Color(0xffe5e5e5);
      });

      if (null != borderColor) realBorderColor = borderColor!;

      return TextField(
          cursorColor: cursorColor,
          cursorHeight: cursorHeight,
          style: style,
          textAlignVertical: TextAlignVertical.center,
          controller: controller,
          decoration: InputDecoration(
            suffixIcon: realClearIcon,
            hintText: hintText,
            hintStyle: hintStyle,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: realBorderColor.resolve(<MaterialState>[].toSet())),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: realBorderColor.resolve(<MaterialState>[MaterialState.disabled].toSet())),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: realBorderColor.resolve(<MaterialState>[MaterialState.focused].toSet())),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: realBorderColor.resolve(<MaterialState>[MaterialState.error].toSet())),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            ),
            contentPadding: contentPadding,
          ),
          onChanged: (value) {
            setState(() {
              _needShowClearIcon = value.isNotEmpty;
            });
            onChange?.call(value);
          });
    });
  }
}
