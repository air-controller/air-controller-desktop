import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/widget/unified_text_field.dart';
import 'package:flutter/material.dart';

class SingleInputView extends StatelessWidget {
  final String title;
  final Function(String)? onConfirm;

  SingleInputView({required this.title, this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Center(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 40,
              color: Color(0xfff4f4f4),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(title,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff616161)))),
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close, color: Color(0xff616161)))
                  ]),
            ),
            Divider(
              color: Color(0xffe0e0e0),
              height: 1.0,
              thickness: 1.0,
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
              child: SizedBox(
                child: UnifiedTextField(
                  controller: controller,
                ),
                height: 40,
              ),
            ),
            Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(context.l10n.cancel,
                          style: TextStyle(
                              color: Color(0xff2f3b42), fontSize: 14)),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Color(0xaaffffff);
                            } else if (states.contains(MaterialState.hovered)) {
                              return Color(0xeeffffff);
                            } else {
                              return Color(0xffffffff);
                            }
                          }),
                          fixedSize: MaterialStateProperty.all(Size(100, 30))),
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            final text = controller.text;

                            if (text.trim().isNotEmpty) {
                              onConfirm?.call(controller.text);
                              Navigator.pop(context);
                            }
                          },
                          child: Text(context.l10n.sure,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14)),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Color(0xaa097eff);
                                } else if (states
                                    .contains(MaterialState.hovered)) {
                                  return Color(0xee097eff);
                                } else {
                                  return Color(0xff097eff);
                                }
                              }),
                              fixedSize:
                                  MaterialStateProperty.all(Size(100, 30))),
                        ))
                  ],
                ))
          ],
        ),
        width: 500,
        height: 180,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(3))),
      ),
    );
  }
}

void showSingleInputDialog({
  required BuildContext context,
  required String title,
  Function(String)? onConfirm,
}) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SingleInputView(title: title, onConfirm: onConfirm);
      });
}
