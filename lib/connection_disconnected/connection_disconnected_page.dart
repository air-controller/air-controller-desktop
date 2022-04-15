import 'package:air_controller/l10n/l10n.dart';
import 'package:flutter/material.dart';

import '../constant.dart';

class ConnectionDisconnectedPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _ConnectionDisconnectionState();
  }

}

class _ConnectionDisconnectionState extends State<ConnectionDisconnectedPage> {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Wrap(
          direction: Axis.horizontal,
          children: [
            Image.asset("assets/icons/error_wrong.png", width: 540 * 0.6, height: 960 * 0.6),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween ,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Wrap(
                    direction: Axis.vertical,
                    children: [
                      Container(
                        child: Text(
                          context.l10n.wirelessConDisconnected,
                          style: TextStyle(
                              color: Color(0xff57595d),
                              fontSize: 23,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        margin: EdgeInsets.only(top: 150),
                      ),

                      Container(
                        child: Text(
                          context.l10n.placeholderDisconnectionDesc.replaceFirst("%s", Constant.APP_NAME),
                          style: TextStyle(
                              color: Color(0xffdc0c0c0),
                              fontSize: 14
                          ),
                        ),
                        margin: EdgeInsets.only(top: 20),
                        width: 350,
                      )

                    ],
                  ),
                  Container(
                    child: OutlinedButton(
                      child: Text(context.l10n.backToHome, style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff5b5c61)
                      )),
                      style: OutlinedButton.styleFrom(
                        fixedSize: Size(125, 40),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1.0, style: BorderStyle.solid),
                          borderRadius: BorderRadius.all(Radius.circular(5))
                        )
                      ),
                      onPressed: () {
                        _popToHomePage();
                      },
                    ),
                    // color: Colors.yellow,
                  )

                ],
              ),
              height: 960 * 0.6 - 50,
            )
          ],
        ),
      ),
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
    );
  }

  void _popToHomePage() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}