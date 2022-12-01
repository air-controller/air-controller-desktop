import 'package:air_controller/constant.dart';
import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/model/update_info.dart';
import 'package:air_controller/util/common_util.dart';
import 'package:air_controller/util/system_app_launcher.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../bootstrap.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  bool _showMenuView = false;
  final _widthBreakPoint = 960;
  late Dio _dio;
  UpdateInfo? _updateInfo;

  @override
  void initState() {
    super.initState();

    _dio = Dio();
    _dio.options.baseUrl = urlUpdateDomain;
    _dio.options.connectTimeout = 60000;
    _dio.options.receiveTimeout = 60000;

    _obtainUpdateInfo();
  }

  void _obtainUpdateInfo() async {
    try {
      final updateInfo = await _getUpdateInfo();
      setState(() {
        _updateInfo = updateInfo;
      });
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          controller: ScrollController(),
          child: media.size.width <= _widthBreakPoint && _showMenuView
              ? _buildMenuView()
              : _buildMainView(),
        ));
  }

  Widget _buildMainView() {
    final media = MediaQuery.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        media.size.width > _widthBreakPoint
            ? _buildHeaderWideSize()
            : _buildHeaderSmallSize(),
        _buildIntroView(),
        Container(
          width: 300,
          height: 50,
          margin: EdgeInsets.only(left: 20, top: 15),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey
            ),
              onPressed: () {
                _downloadApp();
              },
              child:
                  Text(context.l10n.download, style: TextStyle(fontSize: 18))),
        ),
        _buildDownloadButtons(),
        _buildPreviewView(),
        _buildStartWebView(),
        _buildCommunityView(),
        SizedBox(height: 100)
      ],
    );
  }

  Widget _buildHeaderWideSize() {
    return SizedBox(
        height: 80,
        child: Column(
          children: [
            Expanded(
                child: Row(
              children: [
                _buildLogoView(),
                Spacer(),
                _buildTextButton(
                    text: context.l10n.web,
                    onPressed: () {
                      Navigator.pushNamed(context, routeEnter);
                    }),
                SizedBox(width: 10),
                _buildTextButton(
                    text: context.l10n.docs,
                    onPressed: () {
                      SystemAppLauncher.openUrl(urlDocs);
                    }),
                SizedBox(width: 10),
                _buildTextButton(
                    text: context.l10n.github,
                    onPressed: () {
                      SystemAppLauncher.openUrl(urlGitHub);
                    }),
                SizedBox(width: 20)
              ],
            )),
            Divider(height: 1, color: Colors.grey),
          ],
        ));
  }

  Widget _buildHeaderSmallSize() {
    return Container(
      child: Row(
        children: [
          _buildLogoView(),
          Spacer(),
          Padding(
              padding: EdgeInsets.all(10),
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      _showMenuView = true;
                    });
                  },
                  icon: Icon(Icons.menu, color: Colors.black, size: 25)))
        ],
      ),
    );
  }

  Widget _buildLogoView() {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Image.asset("assets/icons/ic_app_icon.png", width: 20, height: 20),
            SizedBox(width: 5),
            Text("AirController",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
          ],
        ));
  }

  Widget _buildTextButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return _MenuTextButton(
      color: Color(0xff333333),
      hoverColor: Colors.blue,
      onPressed: onPressed,
      text: text,
      fontSize: 18,
    );
  }

  Widget _buildIntroView() {
    return Padding(
      padding: EdgeInsets.only(left: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.slogan,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30)),
          SizedBox(height: 10),
          Text(context.l10n.appIntro, style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(
      {required String iconName, Function()? onPressed}) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
            color: Color(0xff424242),
            borderRadius: BorderRadius.all(Radius.circular(30))),
        padding: EdgeInsets.all(10),
        child: Image.asset("assets/icons/$iconName",
            fit: BoxFit.fitWidth, color: Colors.white),
      ),
    );
  }

  Widget _buildDownloadButtons() {
    return Padding(
        padding: EdgeInsets.only(left: 20, top: 25),
        child: Row(
          children: [
            _buildDownloadButton(
                iconName: "ic_windows.png",
                onPressed: () {
                  _downloadWindowsApp();
                }),
            SizedBox(width: 20),
            _buildDownloadButton(
                iconName: "ic_mac.png",
                onPressed: () {
                  _downloadMacApp();
                }),
            SizedBox(width: 20),
            _buildDownloadButton(
                iconName: "ic_linux.png",
                onPressed: () {
                  _downloadLinuxApp();
                }),
            SizedBox(width: 20),
            _buildDownloadButton(
                iconName: "ic_android.png",
                onPressed: () {
                  _downloadAndroidApp();
                }),
          ],
        ));
  }

  void _downloadWindowsApp() async {
    if (_updateInfo != null) {
      final url = CommonUtil.isInland(context)
          ? _updateInfo!.inland.urlWindows
          : _updateInfo!.overseas.urlWindows;
      SystemAppLauncher.openUrl(url);
    } else {
      BotToast.showLoading();

      try {
        final updateInfo = await _getUpdateInfo();
        BotToast.closeAllLoading();

        _updateInfo = updateInfo;

        final url = CommonUtil.isInland(context)
            ? _updateInfo!.inland.urlWindows
            : _updateInfo!.overseas.urlWindows;
        SystemAppLauncher.openUrl(url);
      } catch (e) {
        BotToast.closeAllLoading();
        BotToast.showText(text: "Get update info failure, reason: $e");
      }
    }
  }

  void _downloadMacApp() async {
    if (_updateInfo != null) {
      final url = CommonUtil.isInland(context)
          ? _updateInfo!.inland.urlMac
          : _updateInfo!.overseas.urlMac;
      SystemAppLauncher.openUrl(url);
    } else {
      BotToast.showLoading();

      try {
        final updateInfo = await _getUpdateInfo();
        BotToast.closeAllLoading();

        _updateInfo = updateInfo;

        final url = CommonUtil.isInland(context)
            ? _updateInfo!.inland.urlMac
            : _updateInfo!.overseas.urlMac;
        SystemAppLauncher.openUrl(url);
      } catch (e) {
        BotToast.closeAllLoading();
        BotToast.showText(text: "Get update info failure, reason: $e");
      }
    }
  }

  void _downloadLinuxApp() async {
    if (_updateInfo != null) {
      final url = CommonUtil.isInland(context)
          ? _updateInfo!.inland.urlLinux
          : _updateInfo!.overseas.urlLinux;
      SystemAppLauncher.openUrl(url);
    } else {
      BotToast.showLoading();

      try {
        final updateInfo = await _getUpdateInfo();
        BotToast.closeAllLoading();

        _updateInfo = updateInfo;

        final url = CommonUtil.isInland(context)
            ? _updateInfo!.inland.urlLinux
            : _updateInfo!.overseas.urlLinux;
        SystemAppLauncher.openUrl(url);
      } catch (e) {
        BotToast.closeAllLoading();
        BotToast.showText(text: "Get update info failure, reason: $e");
      }
    }
  }

  void _downloadAndroidApp() async {
    if (_updateInfo != null) {
      final url = CommonUtil.isInland(context)
          ? _updateInfo!.inland.urlAndroid
          : _updateInfo!.overseas.urlAndroid;
      SystemAppLauncher.openUrl(url);
    } else {
      BotToast.showLoading();

      try {
        final updateInfo = await _getUpdateInfo();
        BotToast.closeAllLoading();

        _updateInfo = updateInfo;

        final url = CommonUtil.isInland(context)
            ? _updateInfo!.inland.urlAndroid
            : _updateInfo!.overseas.urlAndroid;
        SystemAppLauncher.openUrl(url);
      } catch (e) {
        BotToast.closeAllLoading();
        BotToast.showText(text: "Get update info failure, reason: $e");
      }
    }
  }

  void _downloadApp() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        _downloadWindowsApp();
        break;
      case TargetPlatform.macOS:
        _downloadMacApp();
        break;
      default:
        _downloadLinuxApp();
        break;
    }
  }

  Widget _buildPreviewView() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: screenWidth * 0.8,
        margin: EdgeInsets.only(top: 100),
        child: Stack(
          children: [
            Container(
              width: screenWidth * 0.8 - 150,
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black38, width: 0.1),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Image.asset(
                "assets/images/air_controller_desktop.png",
                fit: BoxFit.fitWidth,
              ),
            ),
            Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: screenWidth * 0.13,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black38,
                            offset: Offset(0, 0),
                            blurRadius: 5,
                            spreadRadius: 0)
                      ]),
                  child: Image.asset("assets/images/air_controller_mobile.png"),
                ))
          ],
        ),
      ),
    );
  }

  Widget _buildStartWebView() {
    return Container(
      width: double.infinity,
      height: 300,
      color: Color(0xffec5169),
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 150),
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(context.l10n.operationGuide,
              style: TextStyle(fontSize: 40, color: Colors.white)),
          SizedBox(height: 15),
          Text(context.l10n.openSourceDeclaration,
              style: TextStyle(fontSize: 20, color: Colors.white)),
          SizedBox(height: 30),
          _StartWebButton(
              text: context.l10n.tryWebVersion,
              onPressed: () {
                Navigator.pushNamed(context, routeEnter);
              })
        ],
      ),
    );
  }

  Widget _buildMenuView() {
    final media = MediaQuery.of(context);

    return Container(
      color: Colors.blueAccent,
      width: media.size.width,
      height: media.size.height,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset("assets/icons/ic_app_icon.png",
                  width: 20, height: 20),
              Spacer(),
              IconButton(
                  onPressed: () {
                    setState(() {
                      _showMenuView = false;
                    });
                  },
                  icon: Icon(Icons.close, color: Colors.white, size: 25))
            ],
          ),
          _MenuTextButton(
              text: context.l10n.web,
              onPressed: () {
                Navigator.pushNamed(context, routeEnter);
              }),
          SizedBox(height: 10),
          _MenuTextButton(
              text: context.l10n.docs,
              onPressed: () {
                SystemAppLauncher.openUrl(urlDocs);
              }),
          SizedBox(height: 10),
          _MenuTextButton(
              text: context.l10n.github,
              onPressed: () {
                SystemAppLauncher.openUrl(urlGitHub);
              }),
        ],
      ),
    );
  }

  Widget _buildCommunityView() {
    final media = MediaQuery.of(context);
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        margin: EdgeInsets.only(top: 30, bottom: 30),
        constraints: BoxConstraints(maxWidth: 1440),
        alignment: Alignment.center,
        child: media.size.width > _widthBreakPoint
            ? Row(
                children: [
                  Text(context.l10n.joinOurCommunity,
                      style:
                          TextStyle(fontSize: 35, fontWeight: FontWeight.w500)),
                  SizedBox(width: 30),
                  ..._buildCommunityItems()
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(context.l10n.joinOurCommunity,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                  SizedBox(height: 10),
                  ..._buildCommunityItems()
                ],
              ),
      ),
    );
  }

  List<Widget> _buildCommunityItems() {
    final media = MediaQuery.of(context);

    return [
      _buildCommunityItem(
          iconName: "ic_github.png",
          text: context.l10n.github,
          onPressed: () {
            SystemAppLauncher.openUrl(urlGitHub);
          }),
      media.size.width > _widthBreakPoint
          ? SizedBox(width: 30)
          : SizedBox(height: 10),
      _buildCommunityItem(
          iconName: "qq.png",
          text: context.l10n.qqGroup,
          onPressed: () {
            SystemAppLauncher.openUrl(urlQQGroup);
          }),
      media.size.width > _widthBreakPoint
          ? SizedBox(width: 30)
          : SizedBox(height: 10),
      _buildCommunityItem(
          iconName: "weixin.png",
          text: context.l10n.wechatOfficial,
          onPressed: () {
            SystemAppLauncher.openUrl(urlWechatOfficial);
          }),
      media.size.width > _widthBreakPoint
          ? SizedBox(width: 30)
          : SizedBox(height: 10),
      _buildCommunityItem(
          iconName: "weibo.jpg",
          text: context.l10n.sinaWeibo,
          onPressed: () {
            SystemAppLauncher.openUrl(urlWeibo);
          }),
    ];
  }

  Widget _buildCommunityItem(
      {required String iconName,
      required String text,
      required Function() onPressed}) {
    return InkWell(
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: onPressed,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Image.asset("assets/icons/$iconName", width: 40, height: 40),
          SizedBox(width: 10),
          Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Text(text, style: TextStyle(fontSize: 16)))
        ],
      ),
    );
  }

  Future<UpdateInfo> _getUpdateInfo() async {
    final response = await _dio.get("/update/update.json");
    if (response.statusCode == 200) {
      return UpdateInfo.fromJson(response.data);
    } else {
      throw Exception(response.statusMessage ?? "Failed to get update info");
    }
  }
}

class _StartWebButton extends StatefulWidget {
  final String text;
  final Function()? onPressed;

  const _StartWebButton({
    required this.text,
    this.onPressed,
  });

  @override
  State<_StartWebButton> createState() {
    return _StartWebButtonState();
  }
}

class _StartWebButtonState extends State<_StartWebButton> {
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onPressed?.call();
      },
      onHover: (isHover) {
        setState(() {
          _isHover = isHover;
        });
      },
      child: Container(
          width: 250,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: _isHover ? Color(0xfffdedf0) : Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: Text(widget.text, style: TextStyle(color: Color(0xffec546b)))),
    );
  }
}

class _MenuTextButton extends StatefulWidget {
  final Color color;
  final Color hoverColor;
  final String text;
  final double fontSize;
  final Function()? onPressed;

  const _MenuTextButton({
    this.color = Colors.white,
    this.hoverColor = Colors.black,
    this.fontSize = 20,
    required this.text,
    this.onPressed,
  });

  @override
  State<_MenuTextButton> createState() {
    return _MenuTextButtonState();
  }
}

class _MenuTextButtonState extends State<_MenuTextButton> {
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () {
        widget.onPressed?.call();
      },
      onHover: (isHover) {
        setState(() {
          _isHover = isHover;
        });
      },
      child: Text(widget.text,
          style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w500,
              color: _isHover ? widget.hoverColor : widget.color)),
    );
  }
}
