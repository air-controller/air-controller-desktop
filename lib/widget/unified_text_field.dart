import 'package:flutter/material.dart';

class UnifiedTextField extends StatefulWidget {
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
  final String? initialKeyword;
  final int maxLines;
  final int? maxLength;
  final Function(String)? onFieldSubmitted;

  const UnifiedTextField(
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
      this.onChange,
      this.initialKeyword,
      this.maxLines = 1,
      this.maxLength,
      this.onFieldSubmitted});

  @override
  State<StatefulWidget> createState() {
    return UnifiedTextFieldState();
  }
}

class UnifiedTextFieldState extends State<UnifiedTextField> {
  bool _needShowClearIcon = false;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      var realClearIcon = widget.clearIcon;

      _needShowClearIcon = widget.controller?.text.isNotEmpty == true;

      if (_needShowClearIcon) {
        if (null == realClearIcon) {
          realClearIcon = IconButton(
              onPressed: () {
                widget.controller?.clear();
                setState(() {
                  _needShowClearIcon = false;
                });
                widget.onChange?.call("");
              },
              icon: Icon(Icons.close, size: 15, color: Color(0xff666666)));
        }
      } else {
        realClearIcon = null;
      }

      var realBorderColor = MaterialStateProperty.resolveWith<Color>((states) {
        const Set<MaterialState> interactiveStates = <MaterialState>{
          MaterialState.pressed,
          MaterialState.hovered,
          MaterialState.focused,
        };
        if (states.any(interactiveStates.contains)) {
          return Color(0xff999999);
        }
        return Color(0xffe5e5e5);
      });

      if (null != widget.borderColor) realBorderColor = widget.borderColor!;

      return TextFormField(
          autofocus: true,
          cursorColor: widget.cursorColor,
          cursorHeight: widget.cursorHeight,
          maxLines: widget.maxLines,
          style: widget.style,
          textAlignVertical: TextAlignVertical.center,
          controller: widget.controller,
          initialValue: widget.initialKeyword,
          maxLength: widget.maxLength,
          onFieldSubmitted: widget.onFieldSubmitted,
          decoration: InputDecoration(
            suffixIcon: realClearIcon,
            hintText: widget.hintText,
            hintStyle: widget.hintStyle,
            counterText: "",
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: realBorderColor.resolve(<MaterialState>[].toSet())),
              borderRadius:
                  BorderRadius.all(Radius.circular(widget.borderRadius)),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: realBorderColor.resolve(
                      <MaterialState>[MaterialState.disabled].toSet())),
              borderRadius:
                  BorderRadius.all(Radius.circular(widget.borderRadius)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: realBorderColor
                      .resolve(<MaterialState>[MaterialState.focused].toSet())),
              borderRadius:
                  BorderRadius.all(Radius.circular(widget.borderRadius)),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: realBorderColor
                      .resolve(<MaterialState>[MaterialState.error].toSet())),
              borderRadius:
                  BorderRadius.all(Radius.circular(widget.borderRadius)),
            ),
            contentPadding: widget.contentPadding,
          ),
          onChanged: (value) {
            setState(() {
              _needShowClearIcon = value.isNotEmpty;
            });
            widget.onChange?.call(value);
          });
    });
  }
}
