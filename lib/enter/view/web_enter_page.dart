import 'package:air_controller/home/home.dart';
import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/model/device.dart';
import 'package:air_controller/network/device_connection_manager.dart';
import 'package:air_controller/repository/aircontroller_client.dart';
import 'package:air_controller/repository/common_repository.dart';
import 'package:air_controller/util/common_util.dart';
import 'package:air_controller/widget/unified_text_field.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import '../../bootstrap.dart';
import '../../constant.dart';

class WebEnterPage extends StatefulWidget {
  const WebEnterPage({Key? key}) : super(key: key);

  @override
  _WebEnterPageState createState() => _WebEnterPageState();
}

class _WebEnterPageState extends State<WebEnterPage> {
  String? _ip;
  String? _pwd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      children: [
        _buildConnectionView(),
        _buildIntroView(),
      ],
    ));
  }

  Widget _buildIntroView() {
    return Container(
      width: MediaQuery.of(context).size.width * 5 / 10,
      height: double.infinity,
      color: Color.fromARGB(255, 249, 252, 248),
      child: Image.asset("assets/images/connection.jpg", fit: BoxFit.fitHeight),
    );
  }

  Widget _buildConnectionView() {
    return Container(
      width: MediaQuery.of(context).size.width * 5 / 10,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("AirController", style: TextStyle(fontSize: 35)),
          SizedBox(height: 30),
          _buildInputView(
              text: context.l10n.ipAddress,
              hint: context.l10n.enterIpAddress,
              onChange: (value) {
                setState(() {
                  _ip = value;
                });
              },
              onFieldSubmitted: (value) {
                if (_ip != null && _ip!.trim().isNotEmpty) {
                  _connect();
                }
              }),
          SizedBox(height: 15),
          _buildInputView(
              text: context.l10n.password,
              hint: context.l10n.optional,
              onChange: (value) {
                setState(() {
                  _pwd = value;
                });
              },
              onFieldSubmitted: (value) {
                if (_ip != null && _ip!.trim().isNotEmpty) {
                  _connect();
                }
              }),
          SizedBox(height: 30),
          SizedBox(
              width: 250,
              height: 35,
              child: ElevatedButton(
                  onPressed: _ip != null && _ip!.trim().isNotEmpty
                      ? () {
                          _connect();
                        }
                      : null,
                  child: Text(context.l10n.connect)))
        ],
      ),
    );
  }

  Widget _buildInputView(
      {required String text,
      required String hint,
      Function(String)? onChange,
      Function(String)? onFieldSubmitted}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
        SizedBox(
          width: 250,
          height: 35,
          child: UnifiedTextField(
            hintText: hint,
            borderColor:
                MaterialStateProperty.all(Color.fromARGB(255, 185, 198, 191)),
            borderRadius: 3,
            maxLines: 1,
            maxLength: 16,
            onFieldSubmitted: onFieldSubmitted,
            onChange: (value) {
              onChange?.call(value);
            },
          ),
        )
      ],
    );
  }

  void _connect() async {
    if (!CommonUtil.isValidIP(_ip!)) {
      BotToast.showText(text: context.l10n.invalidIpAddress);
      return;
    }

    BotToast.showLoading();

    final client =
        AirControllerClient(domain: "http://$_ip:${Constant.PORT_HTTP}");
    final repository = CommonRepository(client: client);

    try {
      final response = await repository.connect(_pwd);
      BotToast.closeAllLoading();

      if (response.isSuccessful()) {
        final device = _buildDevice(_ip ?? "");
        DeviceConnectionManager.instance.currentDevice = device;

        if (mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return HomePage();
          }));
        }
      } else {
        BotToast.showText(text: response.msg ?? context.l10n.connectionFailed);
      }
    } catch (e) {
      BotToast.closeAllLoading();
      BotToast.showText(text: context.l10n.connectionFailed);
      logger.e("connect failure: $e");
    }
  }

  Device _buildDevice(String ip) {
    return Device(Device.PLATFORM_UNKNOWN, "", ip);
  }
}
