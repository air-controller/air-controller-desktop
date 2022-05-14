import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:air_controller/event/update_mobile_info.dart';
import 'package:air_controller/ext/string-ext.dart';
import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/toolbox_home/view/toolbox_flow.dart';
import 'package:air_controller/toolbox_home/view/toolbox_home_page.dart';
import 'package:flowder/flowder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant.dart';
import '../../enter/view/enter_page.dart';
import '../../event/exit_cmd_service.dart';
import '../../event/exit_heartbeat_service.dart';
import '../../file_home/view/file_home_page.dart';
import '../../help_and_feedback/help_and_feedback_page.dart';
import '../../home_image/view/home_image_flow.dart';
import '../../model/mobile_info.dart';
import '../../music_home/view/music_home_page.dart';
import '../../network/device_connection_manager.dart';
import '../../repository/aircontroller_client.dart';
import '../../repository/audio_repository.dart';
import '../../repository/common_repository.dart';
import '../../repository/file_repository.dart';
import '../../repository/image_repository.dart';
import '../../repository/video_repository.dart';
import '../../util/common_util.dart';
import '../../util/event_bus.dart';
import '../../util/system_app_launcher.dart';
import '../../video_home/view/video_home_page.dart';
import '../../widget/update_check_dialog_ui.dart';
import '../bloc/home_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final client = AirControllerClient(
        domain:
            "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}");

    return MultiRepositoryProvider(providers: [
      RepositoryProvider<ImageRepository>(
          create: (context) => ImageRepository(client: client)),
      RepositoryProvider<CommonRepository>(
          create: (context) => CommonRepository(client: client)),
      RepositoryProvider<FileRepository>(
          create: (context) => FileRepository(client: client)),
      RepositoryProvider<AudioRepository>(
          create: (context) => AudioRepository(client: client)),
      RepositoryProvider<VideoRepository>(
          create: (context) => VideoRepository(client: client))
    ], child: HomeBlocProviderView());
  }
}

class HomeBlocProviderView extends StatelessWidget {
  const HomeBlocProviderView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HomeBloc(commonRepository: context.read<CommonRepository>())
            ..add(const HomeSubscriptionRequested())
            ..add(HomeCheckUpdateRequested()),
      child: HomeView(),
    );
  }
}

// ignore: must_be_immutable
class HomeView extends StatelessWidget {
  final _icons_size = 30.0;
  final _tab_height = 50.0;
  final _icon_margin_hor = 10.0;
  final _tab_font_size = 16.0;
  final _tab_width = Constant.HOME_TAB_WIDTH;

  bool _isPopupIconDown = false;
  bool _isPopupIconHover = false;

  DownloaderCore? _downloaderCore;
  String? _downloadUpdateDir;

  HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeTab tab = context.select((HomeBloc bloc) => bloc.state.tab);
    Stream<HomeLinearProgressIndicatorStatus> progressIndicatorStream =
        context.select((HomeBloc bloc) => bloc.progressIndicatorStream);
    Stream<UpdateDownloadStatusUnit> updateDownloadStatusStream =
        context.select((HomeBloc bloc) => bloc.updateDownloadStatusStream);
    Stream<MobileInfo> updateMobileInfoStream =
      context.select((HomeBloc bloc) => bloc.updateMobileInfoStream);

    eventBus.on<UpdateMobileInfo>().listen((event) {
      log("HomePage, eventBus#UpdateMobileInfo, batteryLevel: ${event.mobileInfo.batteryLevel}");
      context.read<HomeBloc>().add(HomeUpdateMobileInfo(event.mobileInfo));
    });

    Color getTabBgColor(int currentIndex) {
      if (currentIndex == tab.index) {
        return Color(0xffededed);
      } else {
        return Color(0xfffafafa);
      }
    }

    Color hoverIconBgColor = Color(0xfffafafa);

    final pageContext = context;

    return MultiBlocListener(
        listeners: [
          BlocListener<HomeBloc, HomeState>(
            listener: (context, state) {
              UpdateCheckStatusUnit updateCheckStatus = state.updateCheckStatus;

              if (updateCheckStatus.status == UpdateCheckStatus.success) {
                if (!updateCheckStatus.isAutoCheck) {
                  SmartDialog.dismiss();
                }

                if (updateCheckStatus.hasUpdateAvailable) {
                  showDialog(
                      context: context,
                      builder: (context) {

                        int publishTime = state.updateCheckStatus.publishTime ?? 0;

                        final enterContext = EnterPage.enterKey.currentContext;
                        String languageCode = "en";

                        if (null != enterContext) {
                          languageCode = Localizations.localeOf(enterContext).languageCode;
                        }

                        String publishTimeStr = "";

                        if (languageCode == "en") {
                          publishTimeStr = CommonUtil.convertToUSTime(publishTime);
                        } else {
                          publishTimeStr = CommonUtil.formatTime(publishTime, "YYYY MM dd");
                        }

                        return UpdateCheckDialogUI(
                          title: context.l10n.updateDialogTitle,
                          version: state.updateCheckStatus.version ?? "",
                          date: publishTimeStr,
                          updateInfo: state.updateCheckStatus.updateInfo ?? "",
                          updateButtonText: "Download update",
                          onCloseClick: () {
                            Navigator.of(context).pop();
                          },
                          onSeeMoreClick: () {
                            SystemAppLauncher.openUrl(Constant.URL_VERSION_LIST);
                          },
                          onUpdateClick: () {
                            String? name = state.updateCheckStatus.name;
                            String? url = state.updateCheckStatus.url;

                            if (null != name && null != url) {
                              _tryToDownloadUpdate(pageContext, name, url);
                            } else {
                              log("HomePage, onUpdateClick, $name, $url");
                            }
                          },
                        );
                      },
                      barrierDismissible: false
                  );
                } else {
                  if (!updateCheckStatus.isAutoCheck) {
                    SmartDialog.showToast(context.l10n.noUpdatesAvailable);
                  }
                }
              }

              if (updateCheckStatus.status == UpdateCheckStatus.start
                  && !updateCheckStatus.isAutoCheck) {
                SmartDialog.showLoading();
              }

              if (updateCheckStatus.status == UpdateCheckStatus.failure
                  && !updateCheckStatus.isAutoCheck) {
                SmartDialog.dismiss();

                SmartDialog.showToast(updateCheckStatus.failureReason ?? context.l10n.failedToCheckForUpdates);
              }
            },
            listenWhen: (previous, current) {
              return previous.updateCheckStatus != current.updateCheckStatus;
            },
          ),
        ],
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                  child: Stack(
                    children: [
                      Column(children: [
                        Container(
                            child: Align(
                                alignment: Alignment.center,
                                child: Text("",
                                    style:
                                    TextStyle(color: "#656565".toColor()))),
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
                                      margin: EdgeInsets.fromLTRB(
                                          _icon_margin_hor,
                                          0,
                                          _icon_margin_hor,
                                          0)),
                                  Text(context.l10n.pictures,
                                      style: TextStyle(
                                          color: Color(0xff636363),
                                          fontSize: _tab_font_size))
                                ]),
                            height: _tab_height,
                            color: getTabBgColor(HomeTab.image.index),
                          ),
                          onTap: () {
                            context
                                .read<HomeBloc>()
                                .add(HomeTabChanged(HomeTab.image));
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
                                      margin: EdgeInsets.fromLTRB(
                                          _icon_margin_hor,
                                          0,
                                          _icon_margin_hor,
                                          0)),
                                  Text(context.l10n.musics,
                                      style: TextStyle(
                                          color: "#636363".toColor(),
                                          fontSize: _tab_font_size))
                                ]),
                            height: _tab_height,
                            color: getTabBgColor(HomeTab.music.index),
                          ),
                          onTap: () {
                            context
                                .read<HomeBloc>()
                                .add(HomeTabChanged(HomeTab.music));
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
                                      margin: EdgeInsets.fromLTRB(
                                          _icon_margin_hor,
                                          0,
                                          _icon_margin_hor,
                                          0)),
                                  Text(context.l10n.videos,
                                      style: TextStyle(
                                          color: "#636363".toColor(),
                                          fontSize: _tab_font_size))
                                ]),
                            height: _tab_height,
                            color: getTabBgColor(HomeTab.video.index),
                          ),
                          onTap: () {
                            context
                                .read<HomeBloc>()
                                .add(HomeTabChanged(HomeTab.video));
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
                                      margin: EdgeInsets.fromLTRB(
                                          _icon_margin_hor,
                                          0,
                                          _icon_margin_hor,
                                          0)),
                                  Text(context.l10n.downloads,
                                      style: TextStyle(
                                          color: "#636363".toColor(),
                                          fontSize: _tab_font_size))
                                ]),
                            height: _tab_height,
                            color: getTabBgColor(HomeTab.download.index),
                          ),
                          onTap: () {
                            context
                                .read<HomeBloc>()
                                .add(HomeTabChanged(HomeTab.download));
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
                                      margin: EdgeInsets.fromLTRB(
                                          _icon_margin_hor,
                                          0,
                                          _icon_margin_hor,
                                          0)),
                                  Text(context.l10n.files,
                                      style: TextStyle(
                                          color: "#636363".toColor(),
                                          fontSize: _tab_font_size))
                                ]),
                            height: _tab_height,
                            color: getTabBgColor(HomeTab.allFile.index),
                          ),
                          onTap: () {
                            context
                                .read<HomeBloc>()
                                .add(HomeTabChanged(HomeTab.allFile));
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
                                          "assets/icons/ic_toolbox.png",
                                          width: _icons_size - 5,
                                          height: _icons_size - 5),
                                      margin: EdgeInsets.fromLTRB(
                                          _icon_margin_hor,
                                          0,
                                          _icon_margin_hor,
                                          0)),
                                  Text(context.l10n.toolbox,
                                      style: TextStyle(
                                          color: "#636363".toColor(),
                                          fontSize: _tab_font_size))
                                ]),
                            height: _tab_height,
                            color: getTabBgColor(HomeTab.toolbox.index),
                          ),
                          onTap: () {
                            context
                                .read<HomeBloc>()
                                .add(HomeTabChanged(HomeTab.toolbox));
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
                                          "assets/icons/ic_help.png",
                                          width: _icons_size - 4,
                                          height: _icons_size - 4),
                                      margin: EdgeInsets.fromLTRB(
                                          _icon_margin_hor,
                                          0,
                                          _icon_margin_hor,
                                          0)),
                                  Text(context.l10n.helpAndFeedback,
                                      style: TextStyle(
                                          color: "#636363".toColor(),
                                          fontSize: _tab_font_size))
                                ]),
                            height: _tab_height,
                            color: getTabBgColor(HomeTab.helpAndFeedback.index),
                          ),
                          onTap: () {
                            context
                                .read<HomeBloc>()
                                .add(HomeTabChanged(HomeTab.helpAndFeedback));
                          },
                        ),
                        Divider(height: 1, color: "#e0e0e0".toColor()),
                      ]),
                      Positioned(
                        child: StreamBuilder(
                          stream: updateMobileInfoStream,
                          builder: (context, snapshot) {
                            MobileInfo? mobileInfo;

                            if (snapshot.hasData) {
                              mobileInfo = snapshot.data as MobileInfo;
                            }

                            String batteryInfo = "";
                            if (null != mobileInfo) {
                              batteryInfo = "${context.l10n.batteryLabel}${mobileInfo.batteryLevel}%";
                            }

                            String storageInfo = "";
                            if (null != mobileInfo) {
                              storageInfo =
                                  "${context.l10n.storageLabel}${(mobileInfo.storageSize.availableSize ~/ (1024 * 1024 * 1024)).toStringAsFixed(1)}/" +
                                      "${mobileInfo.storageSize.totalSize ~/ (1024 * 1024 * 1024)}GB";
                            }

                            return Column(
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
                                          child: Image.asset(
                                              "assets/icons/ic_popup.png",
                                              width: 13,
                                              height: 13),
                                          // 注意：这里尚未找到方案，让该控件靠右排列，暂时使用margin
                                          // 方式进行处理
                                          margin: EdgeInsets.only(left: 30),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(2)),
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
                            );
                          },
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
                  child: Stack(
                    children: [
                      IndexedStack(
                        index: tab.index,
                        children: [
                          HomeImageFlow(),
                          MusicHomePage(),
                          VideoHomePage(),
                          FileHomePage(true),
                          FileHomePage(false),
                          ToolboxFlow(),
                          HelpAndFeedbackPage()
                        ],
                      ),

                      StreamBuilder(
                          builder: (context, snapshot) {
                            HomeLinearProgressIndicatorStatus? status = null;

                            if (snapshot.hasData) {
                              status = snapshot.data as HomeLinearProgressIndicatorStatus;
                            }

                            return Visibility(child: Positioned(
                              top: Constant.HOME_NAVI_BAR_HEIGHT,
                              left: 0,
                              right: 0,
                              child: LinearProgressIndicator(
                                value: status == null || status.total == 0 ? 0 : status.current / status.total,
                                color: Color(0xff3174de),
                                backgroundColor: Color(0xfffe3e3e3),
                                minHeight: 2,
                              ),
                            ),
                              visible: status?.visible == true,
                            );
                          },
                          stream: progressIndicatorStream,
                      ),

                      StreamBuilder(
                        stream: updateDownloadStatusStream,
                          builder: (context, snapshot) {
                              UpdateDownloadStatusUnit? updateDownloadStatus = null;

                              if (snapshot.hasData) {
                                updateDownloadStatus = snapshot.data as UpdateDownloadStatusUnit;
                              }

                              return Visibility(
                                  child: Positioned(
                                      top: Constant.HOME_NAVI_BAR_HEIGHT,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  context.l10n.packageHasReady,
                                                  style: TextStyle(
                                                      color: Colors.white
                                                  ),
                                                ),

                                                Container(
                                                  child: Text(
                                                    "$_downloadUpdateDir",
                                                    style: TextStyle(
                                                        color: Colors.white
                                                    ),
                                                  ),
                                                  margin: EdgeInsets.only(left: 10),
                                                )
                                              ],
                                            ),

                                            Row(
                                              children: [
                                                Container(
                                                  child: OutlinedButton(
                                                    onPressed: () {
                                                      context.read<HomeBloc>().add(HomeUpdateDownloadStatusChanged(
                                                          UpdateDownloadStatusUnit(status: UpdateDownloadStatus.initial)
                                                      ));
                                                    },
                                                    child: Text(
                                                      context.l10n.iKnow,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14
                                                      ),
                                                    ),
                                                    style: ButtonStyle(
                                                        backgroundColor: MaterialStateColor.resolveWith((states) {
                                                          if (states.contains(MaterialState.pressed)) {
                                                            return Color(0xbbd5362c);
                                                          }

                                                          return Color(0xffd5362c);
                                                        }),
                                                        fixedSize: MaterialStateProperty.all(Size(80, 26)),
                                                        minimumSize: MaterialStateProperty.all(Size(0, 0))
                                                    ),
                                                  ),
                                                  margin: EdgeInsets.only(left: 15),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                        height: 40,
                                        color: Color(0xff3174de),
                                        padding: EdgeInsets.only(left: 15, right: 15),
                                      )
                                  ),
                                  visible: updateDownloadStatus?.status == UpdateDownloadStatus.success,
                              );
                          }
                      )
                    ],
                  )),

            ])
    );
  }

  void _tryToDownloadUpdate(BuildContext context, String name, String url) {
    CommonUtil.openFilePicker(context.l10n.chooseDownloadDir, (dir) async {
      Navigator.pop(context);
      _downloadUpdateToDir(context, name, url, dir);

      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString(Constant.KEY_UPDATE_DOWNLOAD_DIR, dir);

      _downloadUpdateDir = dir;
    }, (error) {
      log("Home page, _tryToDownloadUpdate, error: $error");
    });
  }

  void _downloadUpdateToDir(BuildContext context, String name, String url, String dir) async {
    context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
      HomeLinearProgressIndicatorStatus(
        visible: true
      )
    ));

    context.read<HomeBloc>().add(HomeUpdateDownloadStatusChanged(
        UpdateDownloadStatusUnit(
          status: UpdateDownloadStatus.start
        )
    ));

    var options = DownloaderUtils(
          progress: ProgressImplementation(),
          file: File("$dir/$name"),
          onDone: () {
            context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
                HomeLinearProgressIndicatorStatus(
                    visible: false,
                    current: 0,
                    total: 0
                )
            ));

            context.read<HomeBloc>().add(HomeUpdateDownloadStatusChanged(
                UpdateDownloadStatusUnit(
                    status: UpdateDownloadStatus.success,
                  name: name,
                  path: "$dir/$name"
                )
            ));
          },
          progressCallback: (current, total) {
            log("_downloadUpdateToDir, name: $name, current: $current, total: $total");
            context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
                HomeLinearProgressIndicatorStatus(
                    visible: true,
                  current: current,
                  total: total
                )
            ));

            context.read<HomeBloc>().add(HomeUpdateDownloadStatusChanged(
                UpdateDownloadStatusUnit(
                    status: UpdateDownloadStatus.downloading,
                )
            ));
          }
    );

    try {
      if (null == _downloaderCore) {
        _downloaderCore = await Flowder.download(url, options);
      } else {
        _downloaderCore?.download(url, options);
      }
    } catch (e) {
      context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
          HomeLinearProgressIndicatorStatus(
              visible: false,
              current: 0,
              total: 0
          )
      ));

      context.read<HomeBloc>().add(HomeUpdateDownloadStatusChanged(
          UpdateDownloadStatusUnit(
            status: UpdateDownloadStatus.failure,
            failureReason: "${e.toString()}"
          )
      ));

      SmartDialog.showToast(context.l10n.downloadUpdateFailure);
    }
  }

  void _exitFileManager(BuildContext context) {
    DeviceConnectionManager.instance.currentDevice = null;

    eventBus.fire(ExitCmdService());
    eventBus.fire(ExitHeartbeatService());

    Navigator.pop(context);
  }
}
