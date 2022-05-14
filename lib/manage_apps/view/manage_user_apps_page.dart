import 'dart:io';

import 'package:air_controller/ext/scaffoldx.dart';
import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/manage_apps/widget/app_sort_item.dart';
import 'package:air_controller/repository/common_repository.dart';
import 'package:air_controller/widget/unified_linear_indicator.dart';
import 'package:air_controller/widget/unified_icon_button_with_text.dart';
import 'package:air_controller/widget/unified_text_field.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../../bootstrap.dart';
import '../../constant.dart';
import '../../model/app_info.dart';
import '../../network/device_connection_manager.dart';
import '../../util/common_util.dart';
import '../bloc/manage_apps_bloc.dart';

class ManageUserAppsPage extends StatelessWidget {
  final _rootURL =
      "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}";

  UnifiedLinearIndicator? _progressIndicator;
  CancelToken? _uploadAndInstallCancelToken;
  CancelToken? _directlyInstallCancelToken;
  CancelToken? _exportCancelToken;

  void _selectInstallationPackage(
      BuildContext context, Function(String path) onSelected) async {
    SmartDialog.showLoading();
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        dialogTitle: context.l10n.pleaseSelectInstallationPackage,
        allowedExtensions: ["apk"]);

    SmartDialog.dismiss();

    final path = result?.paths.single;
    if (null != path) {
      onSelected.call(path);
    }
  }

  void _showProgressIndicator(
      {required BuildContext context,
      required String title,
      bool runInBackgroundVisible = true,
      VoidCallback? onCancelClick,
      VoidCallback? onRunInBackgroundClick}) {
    if (null == _progressIndicator) {
      _progressIndicator = UnifiedLinearIndicator(
          context: context,
          title: title,
          runInBackgroundVisible: runInBackgroundVisible,
          onCancelClick: onCancelClick,
          onRunInBackgroundClick: onRunInBackgroundClick);
      _progressIndicator?.show();
    } else {
      _progressIndicator!.onCancelClick = onCancelClick;
      _progressIndicator!.onRunInBackgroundClick = onRunInBackgroundClick;
      _progressIndicator!.updateTitle(title);
      _progressIndicator!.updateProgress(0);
      _progressIndicator!.updateDescription("");

      if (!_progressIndicator!.isShowing) {
        _progressIndicator!.show();
      }
    }
  }

  void _dismissProgressIndicator() {
    if (null != _progressIndicator && _progressIndicator!.isShowing) {
      _progressIndicator!.dismiss();
    }
  }

  void _updateProgressIndicator(
      {String? title, String? description, double? progress}) {
    if (null != _progressIndicator && _progressIndicator!.isShowing) {
      if (null != title) {
        _progressIndicator!.updateTitle(title);
      }

      if (null != description) {
        _progressIndicator!.updateDescription(description);
      }

      if (null != progress) {
        _progressIndicator!.updateProgress(progress);
      }
    }
  }

  void _cancelUploadAndInstall(BuildContext context) {
    _uploadAndInstallCancelToken?.cancel();
    _directlyInstallCancelToken?.cancel();
    context.read<ManageAppsBloc>().add(ManageAppsCancelInstallation());
  }

  void _install(BuildContext context, String apkPath) async {
    final repo = context.read<CommonRepository>();

    SmartDialog.showLoading();

    _directlyInstallCancelToken = await repo.tryToInstallFromCache(
        bundle: File(apkPath),
        onSuccess: () {
          SmartDialog.dismiss();
          final currentInstallStatus =
              context.read<ManageAppsBloc>().state.installStatus;
          context.read<ManageAppsBloc>().add(ManageAppsInstallStatusChanged(
              currentInstallStatus.copyWith(
                  status: ManageAppsInstallStatus.uploadSuccess)));
        },
        onError: (error) {
          SmartDialog.dismiss();
          _uploadAndInstall(context, apkPath);
        });
  }

  void _uploadAndInstall(BuildContext context, String apkPath) async {
    final repo = context.read<CommonRepository>();

    context.read<ManageAppsBloc>().add(ManageAppsInstallStatusChanged(
        ManageAppsInstallStatusUnit(
            status: ManageAppsInstallStatus.startUpload)));

    _uploadAndInstallCancelToken = await repo.uploadAndInstall(
        bundle: File(apkPath),
        onUploadProgress: (current, total) {
          final currentInstallStatus =
              context.read<ManageAppsBloc>().state.installStatus;
          context.read<ManageAppsBloc>().add(ManageAppsInstallStatusChanged(
              currentInstallStatus.copyWith(
                  status: ManageAppsInstallStatus.uploading,
                  current: current,
                  total: total)));
        },
        onSuccess: () {
          final currentInstallStatus =
              context.read<ManageAppsBloc>().state.installStatus;
          context.read<ManageAppsBloc>().add(ManageAppsInstallStatusChanged(
              currentInstallStatus.copyWith(
                  status: ManageAppsInstallStatus.uploadSuccess)));
        },
        onError: (error) {
          final currentInstallStatus =
              context.read<ManageAppsBloc>().state.installStatus;
          context.read<ManageAppsBloc>().add(ManageAppsInstallStatusChanged(
              currentInstallStatus.copyWith(
                  status: ManageAppsInstallStatus.uploadFailure,
                  failureReason: error)));
        });
  }

  void _exportApks(BuildContext context) {
    List<AppInfo> checkedUserApps =
        context.read<ManageAppsBloc>().state.checkedUserApps;
    if (checkedUserApps.isEmpty) return;

    CommonUtil.openFilePicker(context.l10n.chooseDir, (dir) async {
      final repo = context.read<CommonRepository>();

      List<String> packages =
          checkedUserApps.map((app) => app.packageName).toList();

      String fileName = "";

      if (checkedUserApps.length == 1) {
        fileName = "${checkedUserApps.single.name}.apk";
      } else {
        int currentTimeInMills = DateTime.now().millisecondsSinceEpoch;
        String currentTime =
            CommonUtil.formatTime(currentTimeInMills, "yyyyMMddHHmmss");
        fileName = "Apps_$currentTime.zip";
      }

      context.read<ManageAppsBloc>().add(ManageAppsExportStatusChanged(
          ManageAppsExportApksStatusUnit(
              status: ManageAppsExportApksStatus.start)));

      _exportCancelToken = await repo.exportApks(
          packages: packages,
          dir: dir,
          fileName: fileName,
          onExportProgress: (current, total) {
            final exportApksStatus =
                context.read<ManageAppsBloc>().state.exportApksStatus;
            context.read<ManageAppsBloc>().add(ManageAppsExportStatusChanged(
                exportApksStatus.copyWith(
                    status: ManageAppsExportApksStatus.exporting,
                    current: current,
                    total: total)));
          },
          onSuccess: (dir, fileName) {
            final exportApksStatus =
                context.read<ManageAppsBloc>().state.exportApksStatus;
            context.read<ManageAppsBloc>().add(ManageAppsExportStatusChanged(
                exportApksStatus.copyWith(
                    status: ManageAppsExportApksStatus.exportSuccess)));
          },
          onError: (error) {
            final exportApksStatus =
                context.read<ManageAppsBloc>().state.exportApksStatus;
            context.read<ManageAppsBloc>().add(ManageAppsExportStatusChanged(
                exportApksStatus.copyWith(
                    status: ManageAppsExportApksStatus.exportFailure,
                    failureReason: error)));
          });
    }, (error) {
      logger.e("Open directory failure.");
    });
  }

  void _batchUninstall(BuildContext context, List<AppInfo> checkedUserApps) {
    SmartDialog.showLoading();

    final repo = context.read<CommonRepository>();
    repo.batchUninstall(
        packages: checkedUserApps.map((app) => app.packageName).toList(),
        onSuccess: () {
          logger.d("Uninstall apps success, size: ${checkedUserApps.length}");
          SmartDialog.dismiss();
          ScaffoldMessenger.of(context)
              .showSnackBarText(context.l10n.uninstallConfirmTip);
        },
        onError: (error) {
          logger.e("Uninstall apps failure, error: $error");
          SmartDialog.dismiss();
        });
  }

  void _cancelExport(BuildContext context) {
    _exportCancelToken?.cancel();
    context.read<ManageAppsBloc>().add(ManageAppsCancelExport());
  }

  @override
  Widget build(BuildContext context) {
    final dividerLine = Color(0xffe0e0e0);
    final TextStyle headerStyle = TextStyle(fontSize: 14, color: Colors.black);

    final userApps =
        context.select((ManageAppsBloc bloc) => bloc.state.userApps);
    final checkedUserApps =
        context.select((ManageAppsBloc bloc) => bloc.state.checkedUserApps);
    final status = context.select((ManageAppsBloc bloc) => bloc.state.status);
    final sortColumn =
        context.select((ManageAppsBloc bloc) => bloc.state.sortColumn);
    final sortDirection =
        context.select((ManageAppsBloc bloc) => bloc.state.sortDirection);
    final userAppsKeyword =
        context.select((ManageAppsBloc bloc) => bloc.state.userAppsKeyword);
    final searchEditingController = TextEditingController();
    searchEditingController.text = userAppsKeyword;
    searchEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: searchEditingController.text.length));

    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          // Listen install status changed.
          BlocListener<ManageAppsBloc, ManageAppsState>(
            listener: (context, state) {
              if (state.installStatus.status ==
                  ManageAppsInstallStatus.startUpload) {
                _showProgressIndicator(
                    context: context,
                    title: context.l10n.uploadingWait,
                    onCancelClick: () {
                      _dismissProgressIndicator();
                      _cancelUploadAndInstall(context);
                    },
                    onRunInBackgroundClick: () {
                      _dismissProgressIndicator();

                      final currentInstallStatus =
                          context.read<ManageAppsBloc>().state.installStatus;
                      context.read<ManageAppsBloc>().add(
                          ManageAppsInstallStatusChanged(currentInstallStatus
                              .copyWith(isRunInBackground: true)));
                      context.read<ManageAppsBloc>().add(
                          ManageAppsIndicatorStatusChanged(
                              ManageAppsProgressIndicatorStatus(
                                  visible: true)));
                    });
              }

              if (state.installStatus.status ==
                  ManageAppsInstallStatus.uploading) {
                bool isRunInBackground = context
                    .read<ManageAppsBloc>()
                    .state
                    .installStatus
                    .isRunInBackground;

                int current = state.installStatus.current;
                int total = state.installStatus.total;

                logger.d(
                    "Install status uploading, isRunInBackground: $isRunInBackground, current: $current, total: $total");

                if (isRunInBackground) {
                  context.read<ManageAppsBloc>().add(
                      ManageAppsIndicatorStatusChanged(
                          ManageAppsProgressIndicatorStatus(
                              visible: true, current: current, total: total)));
                } else {
                  String description =
                      "${CommonUtil.convertToReadableSize(current)}/${CommonUtil.convertToReadableSize(total)}";
                  double progress = current / total;
                  _updateProgressIndicator(
                      description: description, progress: progress);
                }
              }

              if (state.installStatus.status ==
                  ManageAppsInstallStatus.uploadFailure) {
                bool isRunInBackground = context
                    .read<ManageAppsBloc>()
                    .state
                    .installStatus
                    .isRunInBackground;

                if (isRunInBackground) {
                  context.read<ManageAppsBloc>().add(
                      ManageAppsIndicatorStatusChanged(
                          ManageAppsProgressIndicatorStatus(visible: false)));
                } else {
                  _dismissProgressIndicator();
                }
                ScaffoldMessenger.of(context).showSnackBarText(
                    state.installStatus.failureReason ??
                        context.l10n.unknownError);
              }

              if (state.installStatus.status ==
                  ManageAppsInstallStatus.uploadSuccess) {
                bool isRunInBackground = context
                    .read<ManageAppsBloc>()
                    .state
                    .installStatus
                    .isRunInBackground;

                if (isRunInBackground) {
                  context.read<ManageAppsBloc>().add(
                      ManageAppsIndicatorStatusChanged(
                          ManageAppsProgressIndicatorStatus(visible: false)));
                } else {
                  _dismissProgressIndicator();
                }
                SmartDialog.showToast(
                    context.l10n.installationPackageUploadSuccess);
              }
            },
            listenWhen: (previous, current) =>
                previous.installStatus != current.installStatus &&
                current.installStatus.status != ManageAppsInstallStatus.initial,
          ),

          // Listen export status changed.
          BlocListener<ManageAppsBloc, ManageAppsState>(
            listener: (context, state) {
              if (state.exportApksStatus.status ==
                  ManageAppsExportApksStatus.start) {
                _showProgressIndicator(
                    context: context,
                    title: context.l10n.exporting,
                    onCancelClick: () {
                      _dismissProgressIndicator();
                      _cancelExport(context);
                    },
                    onRunInBackgroundClick: () {
                      _dismissProgressIndicator();

                      final currentExportStatus =
                          context.read<ManageAppsBloc>().state.exportApksStatus;
                      context.read<ManageAppsBloc>().add(
                          ManageAppsExportStatusChanged(currentExportStatus
                              .copyWith(isRunInBackground: true)));
                      context.read<ManageAppsBloc>().add(
                          ManageAppsIndicatorStatusChanged(
                              ManageAppsProgressIndicatorStatus(
                                  visible: true)));
                    });
              }

              if (state.exportApksStatus.status ==
                  ManageAppsExportApksStatus.exporting) {
                bool isRunInBackground = context
                    .read<ManageAppsBloc>()
                    .state
                    .exportApksStatus
                    .isRunInBackground;

                int current = state.exportApksStatus.current;
                int total = state.exportApksStatus.total;

                logger.d(
                    "Export status uploading, isRunInBackground: $isRunInBackground, current: $current, total: $total");

                if (isRunInBackground) {
                  context.read<ManageAppsBloc>().add(
                      ManageAppsIndicatorStatusChanged(
                          ManageAppsProgressIndicatorStatus(
                              visible: true, current: current, total: total)));
                } else {
                  if (total > 0) {
                    String description =
                        "${CommonUtil.convertToReadableSize(current)}/${CommonUtil.convertToReadableSize(total)}";
                    double progress = current / total;
                    _updateProgressIndicator(
                        description: description, progress: progress);
                  }
                }
              }

              if (state.exportApksStatus.status ==
                  ManageAppsExportApksStatus.exportFailure) {
                bool isRunInBackground = context
                    .read<ManageAppsBloc>()
                    .state
                    .exportApksStatus
                    .isRunInBackground;

                if (isRunInBackground) {
                  context.read<ManageAppsBloc>().add(
                      ManageAppsIndicatorStatusChanged(
                          ManageAppsProgressIndicatorStatus(visible: false)));
                } else {
                  _dismissProgressIndicator();
                }
                ScaffoldMessenger.of(context).showSnackBarText(
                    state.exportApksStatus.failureReason ??
                        context.l10n.unknownError);
              }

              if (state.exportApksStatus.status ==
                  ManageAppsExportApksStatus.exportSuccess) {
                bool isRunInBackground = context
                    .read<ManageAppsBloc>()
                    .state
                    .exportApksStatus
                    .isRunInBackground;

                if (isRunInBackground) {
                  context.read<ManageAppsBloc>().add(
                      ManageAppsIndicatorStatusChanged(
                          ManageAppsProgressIndicatorStatus(visible: false)));
                } else {
                  _dismissProgressIndicator();
                }
                SystemSound.play(SystemSoundType.click);
              }
            },
            listenWhen: (previous, current) =>
                previous.exportApksStatus != current.exportApksStatus &&
                current.exportApksStatus.status !=
                    ManageAppsExportApksStatus.initial,
          )
        ],
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  Row(
                    children: [
                      UnifiedIconButtonWithText(
                        iconData: FontAwesomeIcons.plus,
                        text: context.l10n.installApp,
                        space: 3,
                        margin: EdgeInsets.only(left: 20),
                        onTap: () {
                          _selectInstallationPackage(context, (path) async {
                            _install(context, path);
                          });
                        },
                      ),
                      UnifiedIconButtonWithText(
                        iconData: FontAwesomeIcons.download,
                        text: context.l10n.export,
                        space: 3,
                        margin: EdgeInsets.only(left: 10),
                        onTap: () {
                          _exportApks(context);
                        },
                      ),
                      UnifiedIconButtonWithText(
                        iconData: FontAwesomeIcons.trashArrowUp,
                        text: context.l10n.uninstall,
                        space: 3,
                        margin: EdgeInsets.only(left: 10),
                        onTap: () {
                          List<AppInfo> apps = context
                              .read<ManageAppsBloc>()
                              .state
                              .checkedUserApps;
                          _batchUninstall(context, checkedUserApps);
                        },
                      ),
                      UnifiedIconButtonWithText(
                        iconData: Icons.refresh,
                        text: context.l10n.refresh,
                        space: 3,
                        margin: EdgeInsets.only(left: 10),
                        onTap: () {
                          final dialog = UnifiedLinearIndicator(
                              context: context, runInBackgroundVisible: true);
                          dialog.show();
                        },
                      ),
                    ],
                  ),
                  Spacer(),
                  Container(
                    child: Row(
                      children: [
                        Builder(builder: (context) {
                          return InkResponse(
                            autofocus: true,
                            child: Container(
                              child: Wrap(
                                direction: Axis.horizontal,
                                children: [
                                  Text(context.l10n.sortBy),
                                  Container(
                                    child: Image.asset(
                                      "assets/icons/ic_arrow_downward.png",
                                      width: 23,
                                      height: 23,
                                    ),
                                    margin: EdgeInsets.only(left: 5),
                                  )
                                ],
                              ),
                            ),
                            onTap: () {
                              BotToast.showAttachedWidget(
                                  targetContext: context,
                                  verticalOffset: 5,
                                  attachedBuilder: (cancelFunc) {
                                    final rowHeight = 40.0;
                                    final width = 150.0;
                                    final height = 82.0;

                                    return Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        child: Column(
                                          children: [
                                            AppSortItem(
                                              title: context.l10n.name,
                                              width: double.infinity,
                                              height: rowHeight,
                                              isChecked: sortColumn ==
                                                  ManageAppsSortColumn.appName,
                                              isAscending: sortDirection ==
                                                  ManageAppsSortDirection
                                                      .ascending,
                                              onTap: () {
                                                cancelFunc.call();

                                                final sortColumn = context
                                                    .read<ManageAppsBloc>()
                                                    .state
                                                    .sortColumn;
                                                final sortDirection = context
                                                    .read<ManageAppsBloc>()
                                                    .state
                                                    .sortDirection;

                                                if (sortColumn ==
                                                    ManageAppsSortColumn
                                                        .appName) {
                                                  final nextSortDirection =
                                                      sortDirection ==
                                                              ManageAppsSortDirection
                                                                  .ascending
                                                          ? ManageAppsSortDirection
                                                              .descending
                                                          : ManageAppsSortDirection
                                                              .ascending;
                                                  context
                                                      .read<ManageAppsBloc>()
                                                      .add(ManageAppsSortChanged(
                                                          isUserApps: true,
                                                          sortColumn:
                                                              ManageAppsSortColumn
                                                                  .appName,
                                                          sortDirection:
                                                              nextSortDirection));
                                                } else {
                                                  context
                                                      .read<ManageAppsBloc>()
                                                      .add(ManageAppsSortChanged(
                                                          isUserApps: true,
                                                          sortColumn:
                                                              ManageAppsSortColumn
                                                                  .appName,
                                                          sortDirection:
                                                              ManageAppsSortDirection
                                                                  .ascending));
                                                }
                                              },
                                            ),
                                            AppSortItem(
                                              title: context.l10n.size,
                                              width: double.infinity,
                                              height: rowHeight,
                                              isChecked: sortColumn ==
                                                  ManageAppsSortColumn.size,
                                              isAscending: sortDirection ==
                                                  ManageAppsSortDirection
                                                      .ascending,
                                              onTap: () {
                                                cancelFunc.call();
                                                final sortColumn = context
                                                    .read<ManageAppsBloc>()
                                                    .state
                                                    .sortColumn;
                                                final sortDirection = context
                                                    .read<ManageAppsBloc>()
                                                    .state
                                                    .sortDirection;

                                                if (sortColumn ==
                                                    ManageAppsSortColumn.size) {
                                                  final nextSortDirection =
                                                      sortDirection ==
                                                              ManageAppsSortDirection
                                                                  .ascending
                                                          ? ManageAppsSortDirection
                                                              .descending
                                                          : ManageAppsSortDirection
                                                              .ascending;
                                                  context
                                                      .read<ManageAppsBloc>()
                                                      .add(ManageAppsSortChanged(
                                                          isUserApps: true,
                                                          sortColumn:
                                                              ManageAppsSortColumn
                                                                  .size,
                                                          sortDirection:
                                                              nextSortDirection));
                                                } else {
                                                  context
                                                      .read<ManageAppsBloc>()
                                                      .add(ManageAppsSortChanged(
                                                          isUserApps: true,
                                                          sortColumn:
                                                              ManageAppsSortColumn
                                                                  .size,
                                                          sortDirection:
                                                              ManageAppsSortDirection
                                                                  .ascending));
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                        width: width,
                                        height: height,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(3)),
                                            border: Border.all(
                                                color: Color(0xffcccccc))),
                                      ),
                                    );
                                  },
                                  preferDirection:
                                      PreferDirection.bottomCenter);
                            },
                          );
                        }),
                        Container(
                          child: StreamBuilder(
                            builder: ((context, snapshot) {
                              return UnifiedTextField(
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xff333333)),
                                hintText: context.l10n.search,
                                controller: searchEditingController,
                                borderRadius: 3,
                                cursorColor: Color(0xff999999),
                                cursorHeight: 15,
                                onChange: (value) {
                                  context.read<ManageAppsBloc>().add(
                                      ManageAppsUserAppsKeyWordChanged(value));
                                },
                              );
                            }),
                          ),
                          width: 200,
                          height: 30,
                          margin: EdgeInsets.only(left: 10, right: 10),
                        ),
                        IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              context.read<ManageAppsBloc>().add(
                                  ManageAppsUserAppsKeyWordChanged(
                                      searchEditingController.text));
                            })
                      ],
                    ),
                    width: 350,
                  )
                ],
              ),
              height: 50,
              color: Colors.white,
            ),
            Expanded(
                child: Stack(
              children: [
                Visibility(
                  child: Container(
                    color: Colors.white,
                    child: DataTable2(
                      dividerThickness: 1,
                      bottomMargin: 10,
                      columnSpacing: 0,
                      sortColumnIndex: 0,
                      sortAscending: true,
                      showCheckboxColumn: false,
                      showBottomBorder: false,
                      dataRowHeight: 60,
                      headingRowHeight: 0,
                      columns: [
                        DataColumn2(
                            label: Container(
                              child: Text(
                                context.l10n.app,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    inherit: true, fontFamily: 'NotoSansSC'),
                              ),
                            ),
                            onSort: (sortColumnIndex, isSortAscending) {},
                            size: ColumnSize.L),
                        DataColumn2(
                            label: Container(
                                child: Text(
                                  context.l10n.size,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      inherit: true, fontFamily: 'NotoSansSC'),
                                ),
                                padding: EdgeInsets.only(left: 15)),
                            onSort: (sortColumnIndex, isSortAscending) {}),
                        DataColumn2(
                            label: Container(
                          child: Text(
                            context.l10n.versionName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                inherit: true, fontFamily: 'NotoSansSC'),
                          ),
                          padding: EdgeInsets.only(left: 15),
                        )),
                        DataColumn2(
                            label: Container(
                              child: Text(
                                context.l10n.operate,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    inherit: true, fontFamily: 'NotoSansSC'),
                              ),
                              padding: EdgeInsets.only(left: 15),
                            ),
                            onSort: (sortColumnIndex, isSortAscending) {})
                      ],
                      rows: List<DataRow>.generate(userApps.length, (index) {
                        AppInfo app = userApps[index];
                        bool isChecked = checkedUserApps.contains(app);

                        Color textColor =
                            isChecked ? Colors.white : Color(0xff313237);
                        TextStyle textStyle =
                            TextStyle(fontSize: 14, color: textColor);

                        return DataRow2(
                            cells: [
                              DataCell(Listener(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.fromLTRB(0, 6, 0, 6),
                                  child: Row(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl:
                                            "$_rootURL/stream/drawable?package=${app.packageName}",
                                        width: 60,
                                        height: 60,
                                      ),
                                      Container(
                                        child: Text(app.name,
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                            style: textStyle),
                                        margin: EdgeInsets.only(left: 10),
                                      )
                                    ],
                                  ),
                                  color: Colors.transparent,
                                ),
                                onPointerDown: (event) {},
                              )),
                              DataCell(Listener(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                                  child: Text(
                                      CommonUtil.convertToReadableSize(
                                          app.size),
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      style: textStyle),
                                  color: Colors.transparent,
                                ),
                                onPointerDown: (event) {},
                              )),
                              DataCell(Listener(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                                  child: Text(
                                      "${context.l10n.placeHolderVersionName.replaceAll("%s", app.versionName)}",
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: textStyle),
                                  color: Colors.transparent,
                                ),
                                onPointerDown: (event) {},
                              )),
                              DataCell(Listener(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                                  child: OutlinedButton(
                                    child: Text(context.l10n.uninstall,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: textStyle),
                                    onPressed: () {
                                      _batchUninstall(context, [app]);
                                    },
                                  ),
                                  color: Colors.transparent,
                                ),
                                onPointerDown: (event) {},
                              )),
                            ],
                            selected: isChecked,
                            onSelectChanged: (isSelected) {
                              debugPrint("onSelectChanged: $isSelected");
                            },
                            onTap: () {
                              context
                                  .read<ManageAppsBloc>()
                                  .add(ManageAppsUserAppCheckChanged(app));
                            },
                            color: MaterialStateColor.resolveWith((states) {
                              if (states.contains(MaterialState.hovered)) {
                                return Colors.red;
                              }

                              if (states.contains(MaterialState.pressed)) {
                                return Colors.blue;
                              }

                              if (states.contains(MaterialState.selected)) {
                                return Color(0xff5e86ec);
                              }

                              return Colors.white;
                            }));
                      }),
                      headingTextStyle: headerStyle,
                      onSelectAll: (val) {},
                      empty: Center(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          color: Colors.green[200],
                          child: Text(context.l10n.phoneNotInstallAnyApp),
                        ),
                      ),
                    ),
                    padding: EdgeInsets.only(bottom: 10),
                  ),
                  visible: status == ManageAppsStatus.success,
                ),
                Visibility(
                    child: Container(
                        child:
                            SpinKitCircle(color: Color(0xff85a8d0), size: 60.0),
                        color: Colors.white),
                    maintainSize: false,
                    visible: status == ManageAppsStatus.loading)
              ],
            ))
          ],
        ),
      ),
    );
  }
}
