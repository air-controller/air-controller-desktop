import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_assistant_client/ext/string-ext.dart';
import 'package:mobile_assistant_client/file_home/file_home.dart';
import 'package:mobile_assistant_client/home2/bloc/home_bloc.dart';
import 'package:mobile_assistant_client/music_home/view/music_home_page.dart';
import 'package:mobile_assistant_client/repository/aircontroller_client.dart';
import 'package:mobile_assistant_client/repository/audio_repository.dart';
import 'package:mobile_assistant_client/repository/common_repository.dart';
import 'package:mobile_assistant_client/repository/file_repository.dart';
import 'package:mobile_assistant_client/repository/video_repository.dart';
import 'package:mobile_assistant_client/video_home/video_home.dart';

import '../../constant.dart';
import '../../event/exit_cmd_service.dart';
import '../../event/exit_heartbeat_service.dart';
import '../../event/update_mobile_info.dart';
import '../../home/all_file_manager_page.dart';
import '../../home/download_manager_page.dart';
import '../../home/help_and_feedback_page.dart';
import '../../home_image/view/home_image_flow.dart';
import '../../model/mobile_info.dart';
import '../../network/device_connection_manager.dart';
import '../../repository/image_repository.dart';
import '../../util/event_bus.dart';


class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final client = AirControllerClient(domain: "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}");

    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ImageRepository>(
              create: (context) => ImageRepository(client: client)
          ),
          RepositoryProvider<CommonRepository>(
              create: (context) => CommonRepository(client: client)
          ),
          RepositoryProvider<FileRepository>(
              create: (context) => FileRepository(client: client)
          ),
          RepositoryProvider<AudioRepository>(
              create: (context) => AudioRepository(client: client)
          ),
          RepositoryProvider<VideoRepository>(
              create: (context) => VideoRepository(client: client)
          )
        ],
        child: HomeBlocProviderView());
  }
}

class HomeBlocProviderView extends StatelessWidget {
  const HomeBlocProviderView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(
          commonRepository: context.read<CommonRepository>()
      )..add(const HomeSubscriptionRequested()),
      child: HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  final _icons_size = 30.0;
  final _tab_height = 50.0;
  final _icon_margin_hor = 10.0;
  final _tab_font_size = 16.0;
  final _tab_width = Constant.HOME_TAB_WIDTH;

  bool _isPopupIconDown = false;
  bool _isPopupIconHover = false;

  StreamSubscription<UpdateMobileInfo>? _updateMobileInfoStream;

  HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeTab tab = context.select((HomeBloc bloc) => bloc.state.tab);
    MobileInfo? mobileInfo = context.select((HomeBloc bloc) => bloc.state.mobileInfo);

    Color getTabBgColor(int currentIndex) {
      if (currentIndex == tab.index) {
        return Color(0xffededed);
      } else {
        return Color(0xfffafafa);
      }
    }

    String batteryInfo = "";
    if (null != mobileInfo) {
      batteryInfo = "电量：${mobileInfo.batteryLevel}%";
    }

    String storageInfo = "";
    if (null != mobileInfo) {
      storageInfo =
          "手机存储：${(mobileInfo.storageSize.availableSize ~/ (1024 * 1024 * 1024)).toStringAsFixed(1)}/" +
              "${mobileInfo.storageSize.totalSize ~/ (1024 * 1024 * 1024)}GB";
    }

    Color hoverIconBgColor = Color(0xfffafafa);

    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
              child: Stack(
                children: [
                  Column(children: [
                    Container(
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                "${DeviceConnectionManager.instance.currentDevice?.name}",
                                style: TextStyle(color: "#656565".toColor()))),
                        height: 40.0,
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                    Divider(height: 1, color: "#e0e0e0".toColor()),
                    GestureDetector(
                      child: Container(
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  child: Image.asset(
                                      "assets/icons/icon_image.png",
                                      width: _icons_size,
                                      height: _icons_size),
                                  margin: EdgeInsets.fromLTRB(_icon_margin_hor,
                                      0, _icon_margin_hor, 0)),
                              Text("图片",
                                  style: TextStyle(
                                      color: Color(0xff636363),
                                      fontSize: _tab_font_size))
                            ]),
                        height: _tab_height,
                        color: getTabBgColor(HomeTab.image.index),
                      ),
                      onTap: () {
                        context.read<HomeBloc>().add(HomeTabChanged(HomeTab.image));
                      },
                    ),
                    Divider(height: 1, color: "#e0e0e0".toColor()),
                    GestureDetector(
                      child: Container(
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  child: Image.asset(
                                      "assets/icons/icon_music.png",
                                      width: _icons_size,
                                      height: _icons_size),
                                  margin: EdgeInsets.fromLTRB(_icon_margin_hor,
                                      0, _icon_margin_hor, 0)),
                              Text("音乐",
                                  style: TextStyle(
                                      color: "#636363".toColor(),
                                      fontSize: _tab_font_size))
                            ]),
                        height: _tab_height,
                        color: getTabBgColor(HomeTab.music.index),
                      ),
                      onTap: () {
                        context.read<HomeBloc>().add(HomeTabChanged(HomeTab.music));
                      },
                    ),
                    Divider(height: 1, color: "#e0e0e0".toColor()),
                    GestureDetector(
                      child: Container(
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  child: Image.asset(
                                      "assets/icons/icon_video.png",
                                      width: _icons_size,
                                      height: _icons_size),
                                  margin: EdgeInsets.fromLTRB(_icon_margin_hor,
                                      0, _icon_margin_hor, 0)),
                              Text("视频",
                                  style: TextStyle(
                                      color: "#636363".toColor(),
                                      fontSize: _tab_font_size))
                            ]),
                        height: _tab_height,
                        color: getTabBgColor(HomeTab.video.index),
                      ),
                      onTap: () {
                        context.read<HomeBloc>().add(HomeTabChanged(HomeTab.video));
                      },
                    ),
                    Divider(height: 1, color: "#e0e0e0".toColor()),
                    GestureDetector(
                      child: Container(
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  child: Image.asset(
                                      "assets/icons/icon_download.png",
                                      width: _icons_size - 3,
                                      height: _icons_size - 3),
                                  margin: EdgeInsets.fromLTRB(_icon_margin_hor,
                                      0, _icon_margin_hor, 0)),
                              Text("下载",
                                  style: TextStyle(
                                      color: "#636363".toColor(),
                                      fontSize: _tab_font_size))
                            ]),
                        height: _tab_height,
                        color: getTabBgColor(HomeTab.download.index),
                      ),
                      onTap: () {
                        context.read<HomeBloc>().add(HomeTabChanged(HomeTab.download));
                      },
                    ),
                    Divider(height: 1, color: "#e0e0e0".toColor()),
                    GestureDetector(
                      child: Container(
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  child: Image.asset(
                                      "assets/icons/icon_all_file.png",
                                      width: _icons_size - 5,
                                      height: _icons_size - 5),
                                  margin: EdgeInsets.fromLTRB(_icon_margin_hor,
                                      0, _icon_margin_hor, 0)),
                              Text("全部文件",
                                  style: TextStyle(
                                      color: "#636363".toColor(),
                                      fontSize: _tab_font_size))
                            ]),
                        height: _tab_height,
                        color: getTabBgColor(HomeTab.allFile.index),
                      ),
                      onTap: () {
                        context.read<HomeBloc>().add(HomeTabChanged(HomeTab.allFile));
                      },
                    ),
                    Divider(height: 1, color: "#e0e0e0".toColor()),
                    GestureDetector(
                      child: Container(
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  child: Image.asset("assets/icons/ic_help.png",
                                      width: _icons_size - 4,
                                      height: _icons_size - 4),
                                  margin: EdgeInsets.fromLTRB(_icon_margin_hor,
                                      0, _icon_margin_hor, 0)),
                              Text("帮助与反馈",
                                  style: TextStyle(
                                      color: "#636363".toColor(),
                                      fontSize: _tab_font_size))
                            ]),
                        height: _tab_height,
                        color: getTabBgColor(HomeTab.helpAndFeedback.index),
                      ),
                      onTap: () {
                        context.read<HomeBloc>().add(HomeTabChanged(HomeTab.helpAndFeedback));
                      },
                    ),
                    Divider(height: 1, color: "#e0e0e0".toColor()),
                  ]),
                  Positioned(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Text(
                                "${DeviceConnectionManager.instance.currentDevice?.name}",
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xff656568)),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                              ),
                              width: 100,
                              // color: Colors.blue,
                            ),
                            StatefulBuilder(builder: (context, setState) {
                              if (_isPopupIconDown) {
                                hoverIconBgColor = Color(0xffe4e4e4);
                              }

                              if (!_isPopupIconDown && _isPopupIconHover) {
                                hoverIconBgColor = Color(0xffededed);
                              }

                              if (!_isPopupIconDown && !_isPopupIconHover) {
                                hoverIconBgColor = Color(0xfffafafa);
                              }

                              return InkWell(
                                child: Container(
                                  child: Image.asset("assets/icons/ic_popup.png",
                                      width: 13, height: 13),
                                  // 注意：这里尚未找到方案，让该控件靠右排列，暂时使用margin
                                  // 方式进行处理
                                  margin: EdgeInsets.only(left: 30),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(2)),
                                      color: hoverIconBgColor),
                                  padding: EdgeInsets.all(3.0),
                                  // color: Colors.yellow,
                                ),
                                onTap: () {
                                  _exitFileManager(context);

                                  setState(() {
                                    _isPopupIconDown = false;
                                  });
                                },
                                onTapDown: (detail) {
                                  setState(() {
                                    _isPopupIconDown = true;
                                  });
                                },
                                onTapCancel: () {
                                  setState(() {
                                    _isPopupIconDown = false;
                                  });
                                },
                                onHover: (isHover) {
                                  setState(() {
                                    _isPopupIconHover = isHover;
                                  });
                                },
                                autofocus: true,
                              );
                            })
                          ],
                        ),
                        Container(
                          child: Text(
                            batteryInfo,
                            style: TextStyle(
                                color: Color(0xff8b8b8e), fontSize: 13),
                          ),
                          margin: EdgeInsets.only(top: 10),
                        ),
                        Container(
                          child: Text(
                            storageInfo,
                            style: TextStyle(
                                color: Color(0xff8b8b8e), fontSize: 13),
                          ),
                          margin: EdgeInsets.only(top: 10),
                        )
                      ],
                    ),
                    bottom: 20,
                    left: 20,
                  )
                ],
              ),
              width: _tab_width,
              height: double.infinity,
              color: "#fafafa".toColor()),
          VerticalDivider(
              width: 1.0, thickness: 1.0, color: "#e1e1d3".toColor()),
          Expanded(
              child: IndexedStack(
                index: tab.index,
                children: [
                  HomeImageFlow(),
                  MusicHomePage(),
                  VideoHomePage(),
                  FileHomePage(true),
                  FileHomePage(false),
                  HelpAndFeedbackPage()
                ],
              ))
        ]);

    // PageView(
    //     scrollDirection: Axis.vertical,
    //     physics: NeverScrollableScrollPhysics(),
    //     children: [
    //       HomeImageFlow(),
    //       MusicHomePage(),
    //       VideoHomePage(),
    //       DownloadManagerPage(),
    //       AllFileManagerPage(),
    //       HelpAndFeedbackPage()
    //     ],
    //     onPageChanged: (index) {
    //       HomeTab tab = HomeTabX.convertToHomeTab(index);
    //       context.read<HomeBloc>().add(HomeTabChanged(tab));
    //     },
    //     controller: pageController)
  }

  void _exitFileManager(BuildContext context) {
    DeviceConnectionManager.instance.currentDevice = null;

    eventBus.fire(ExitCmdService());
    eventBus.fire(ExitHeartbeatService());

    Navigator.pop(context);
  }
}
