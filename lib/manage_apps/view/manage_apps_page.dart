import 'dart:io';

import 'package:air_controller/ext/scaffoldx.dart';
import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/manage_apps/view/data_grid_holder.dart';
import 'package:air_controller/manage_apps/widget/app_sort_item.dart';
import 'package:air_controller/repository/common_repository.dart';
import 'package:air_controller/util/sound_effect.dart';
import 'package:air_controller/widget/unified_icon_button.dart';
import 'package:air_controller/widget/unified_linear_indicator.dart';
import 'package:air_controller/widget/unified_icon_button_with_text.dart';
import 'package:air_controller/widget/unified_text_field.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dio/dio.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

import '../../bootstrap.dart';
import '../../constant.dart';
import '../../model/app_info.dart';
import '../../network/device_connection_manager.dart';
import '../../util/common_util.dart';
import '../bloc/manage_apps_bloc.dart';

class ManageAppsPage extends StatelessWidget {
  final _rootURL =
      "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}";

  UnifiedLinearIndicator? _progressIndicator;
  CancelToken? _uploadAndInstallCancelToken;
  CancelToken? _directlyInstallCancelToken;
  CancelToken? _exportCancelToken;

  final bool isUserApps;

  ManageAppsPage(this.isUserApps);

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
    context.read<ManageAppsHomeBloc>().add(ManageAppsCancelInstallation());
  }

  void _install(BuildContext context, String apkPath) async {
    final repo = context.read<CommonRepository>();

    SmartDialog.showLoading();

    _directlyInstallCancelToken = await repo.tryToInstallFromCache(
        bundle: File(apkPath),
        onSuccess: () {
          SmartDialog.dismiss();
          final currentInstallStatus =
              context.read<ManageAppsHomeBloc>().state.installStatus;
          context.read<ManageAppsHomeBloc>().add(ManageAppsInstallStatusChanged(
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

    context.read<ManageAppsHomeBloc>().add(ManageAppsInstallStatusChanged(
        ManageAppsInstallStatusUnit(
            status: ManageAppsInstallStatus.startUpload)));

    _uploadAndInstallCancelToken = await repo.uploadAndInstall(
        bundle: File(apkPath),
        onUploadProgress: (current, total) {
          final currentInstallStatus =
              context.read<ManageAppsHomeBloc>().state.installStatus;
          context.read<ManageAppsHomeBloc>().add(ManageAppsInstallStatusChanged(
              currentInstallStatus.copyWith(
                  status: ManageAppsInstallStatus.uploading,
                  current: current,
                  total: total)));
        },
        onSuccess: () {
          final currentInstallStatus =
              context.read<ManageAppsHomeBloc>().state.installStatus;
          context.read<ManageAppsHomeBloc>().add(ManageAppsInstallStatusChanged(
              currentInstallStatus.copyWith(
                  status: ManageAppsInstallStatus.uploadSuccess)));
        },
        onError: (error) {
          final currentInstallStatus =
              context.read<ManageAppsHomeBloc>().state.installStatus;
          context.read<ManageAppsHomeBloc>().add(ManageAppsInstallStatusChanged(
              currentInstallStatus.copyWith(
                  status: ManageAppsInstallStatus.uploadFailure,
                  failureReason: error)));
        });
  }

  void _exportApks(BuildContext context) {
    List<AppInfo> checkedUserApps =
        context.read<ManageAppsHomeBloc>().state.checkedUserApps;
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

      context.read<ManageAppsHomeBloc>().add(ManageAppsExportStatusChanged(
          ManageAppsExportApksStatusUnit(
              status: ManageAppsExportApksStatus.start)));

      _exportCancelToken = await repo.exportApks(
          packages: packages,
          dir: dir,
          fileName: fileName,
          onExportProgress: (current, total) {
            final exportApksStatus =
                context.read<ManageAppsHomeBloc>().state.exportApksStatus;
            context.read<ManageAppsHomeBloc>().add(
                ManageAppsExportStatusChanged(exportApksStatus.copyWith(
                    status: ManageAppsExportApksStatus.exporting,
                    current: current,
                    total: total)));
          },
          onSuccess: (dir, fileName) {
            final exportApksStatus =
                context.read<ManageAppsHomeBloc>().state.exportApksStatus;
            context.read<ManageAppsHomeBloc>().add(
                ManageAppsExportStatusChanged(exportApksStatus.copyWith(
                    status: ManageAppsExportApksStatus.exportSuccess)));
          },
          onError: (error) {
            final exportApksStatus =
                context.read<ManageAppsHomeBloc>().state.exportApksStatus;
            context.read<ManageAppsHomeBloc>().add(
                ManageAppsExportStatusChanged(exportApksStatus.copyWith(
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
          SoundEffect.play(SoundType.done);
        },
        onError: (error) {
          logger.e("Uninstall apps failure, error: $error");
          SmartDialog.dismiss();
        });
  }

  void _cancelExport(BuildContext context) {
    _exportCancelToken?.cancel();
    context.read<ManageAppsHomeBloc>().add(ManageAppsCancelExport());
  }

  @override
  Widget build(BuildContext context) {
    final dividerLineColor = Color(0xffe0e0e0);
    final TextStyle headerStyle = TextStyle(fontSize: 14, color: Colors.black);

    final currentTab =
        context.select((ManageAppsHomeBloc bloc) => bloc.state.tab);
    List<AppInfo> apps = [];
    List<AppInfo> checkedApps = [];

    AppInfoDataSource dataSource;
    DataGridController controller;
    Map<AppInfoColumn, double> columnWidths;

    if (isUserApps) {
      apps = context.select((ManageAppsHomeBloc bloc) => bloc.state.userApps);
      checkedApps = context
          .select((ManageAppsHomeBloc bloc) => bloc.state.checkedUserApps);

      final userAppsDataSource = DataGridHolder.userAppsDataSource;
      if (null == userAppsDataSource) {
        dataSource = AppInfoDataSource(
            isUserApps: isUserApps,
            apps: apps,
            checkedApps: checkedApps,
            context: context);
        DataGridHolder.userAppsDataSource = dataSource;
      } else {
        userAppsDataSource.updataDataSource(apps);
        dataSource = userAppsDataSource;
      }

      final userDataGridController = DataGridHolder.userDataGridController;
      if (null == userDataGridController) {
        controller = DataGridController();
        DataGridHolder.userDataGridController = controller;
      } else {
        controller = userDataGridController;
      }

      columnWidths = DataGridHolder.userTableColumnWidths;
    } else {
      apps = context.select((ManageAppsHomeBloc bloc) => bloc.state.systemApps);
      checkedApps = context
          .select((ManageAppsHomeBloc bloc) => bloc.state.checkedSystemApps);

      final systemAppsDataSource = DataGridHolder.systemAppsDataSource;
      if (null == systemAppsDataSource) {
        dataSource = AppInfoDataSource(
            isUserApps: isUserApps,
            apps: apps,
            checkedApps: checkedApps,
            context: context);
        DataGridHolder.systemAppsDataSource = dataSource;
      } else {
        systemAppsDataSource.updataDataSource(apps);
        dataSource = systemAppsDataSource;
      }

      final systemDataGridController = DataGridHolder.systemDataGridController;
      if (null == systemDataGridController) {
        controller = DataGridController();
        DataGridHolder.systemDataGridController = controller;
      } else {
        controller = systemDataGridController;
      }

      columnWidths = DataGridHolder.systemTableColumnWidths;
    }

    _initAppsSelected(controller, dataSource, checkedApps);

    final status =
        context.select((ManageAppsHomeBloc bloc) => bloc.state.status);
    var sortColumn = context
        .select((ManageAppsHomeBloc bloc) => bloc.state.userAppsSortColumn);
    var sortDirection = context
        .select((ManageAppsHomeBloc bloc) => bloc.state.userAppsSortDirection);

    if (!isUserApps) {
      sortColumn = context
          .select((ManageAppsHomeBloc bloc) => bloc.state.systemAppsSortColumn);
      sortDirection = context.select(
          (ManageAppsHomeBloc bloc) => bloc.state.systemAppsSortDirection);
    }

    final userAppsKeyword =
        context.select((ManageAppsHomeBloc bloc) => bloc.state.keyWord);
    final searchEditingController = TextEditingController();
    searchEditingController.text = userAppsKeyword;
    searchEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: searchEditingController.text.length));

    final headerTextStyle = TextStyle(
        color: Color(0xff333333), fontSize: 14, fontWeight: FontWeight.normal);

    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          // Listen install status changed.
          BlocListener<ManageAppsHomeBloc, ManageAppsState>(
            listener: (context, state) {
              if ((isUserApps && state.tab == ManageAppsTab.preInstalled) ||
                  (!isUserApps && state.tab == ManageAppsTab.mine)) return;

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

                      final currentInstallStatus = context
                          .read<ManageAppsHomeBloc>()
                          .state
                          .installStatus;
                      context.read<ManageAppsHomeBloc>().add(
                          ManageAppsInstallStatusChanged(currentInstallStatus
                              .copyWith(isRunInBackground: true)));
                      context.read<ManageAppsHomeBloc>().add(
                          ManageAppsIndicatorStatusChanged(
                              ManageAppsProgressIndicatorStatus(
                                  visible: true)));
                    });
              }

              if (state.installStatus.status ==
                  ManageAppsInstallStatus.uploading) {
                bool isRunInBackground = context
                    .read<ManageAppsHomeBloc>()
                    .state
                    .installStatus
                    .isRunInBackground;

                int current = state.installStatus.current;
                int total = state.installStatus.total;

                logger.d(
                    "Install status uploading, isRunInBackground: $isRunInBackground, current: $current, total: $total");

                if (isRunInBackground) {
                  context.read<ManageAppsHomeBloc>().add(
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
                    .read<ManageAppsHomeBloc>()
                    .state
                    .installStatus
                    .isRunInBackground;

                if (isRunInBackground) {
                  context.read<ManageAppsHomeBloc>().add(
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
                    .read<ManageAppsHomeBloc>()
                    .state
                    .installStatus
                    .isRunInBackground;

                if (isRunInBackground) {
                  context.read<ManageAppsHomeBloc>().add(
                      ManageAppsIndicatorStatusChanged(
                          ManageAppsProgressIndicatorStatus(visible: false)));
                } else {
                  _dismissProgressIndicator();
                }
                SmartDialog.showToast(
                    context.l10n.installationPackageUploadSuccess);

                SoundEffect.play(SoundType.done);
              }
            },
            listenWhen: (previous, current) =>
                previous.installStatus != current.installStatus &&
                current.installStatus.status != ManageAppsInstallStatus.initial,
          ),

          // Listen export status changed.
          BlocListener<ManageAppsHomeBloc, ManageAppsState>(
            listener: (context, state) {
              if ((isUserApps && state.tab == ManageAppsTab.preInstalled) ||
                  (!isUserApps && state.tab == ManageAppsTab.mine)) return;

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

                      final currentExportStatus = context
                          .read<ManageAppsHomeBloc>()
                          .state
                          .exportApksStatus;
                      context.read<ManageAppsHomeBloc>().add(
                          ManageAppsExportStatusChanged(currentExportStatus
                              .copyWith(isRunInBackground: true)));
                      context.read<ManageAppsHomeBloc>().add(
                          ManageAppsIndicatorStatusChanged(
                              ManageAppsProgressIndicatorStatus(
                                  visible: true)));
                    });
              }

              if (state.exportApksStatus.status ==
                  ManageAppsExportApksStatus.exporting) {
                bool isRunInBackground = context
                    .read<ManageAppsHomeBloc>()
                    .state
                    .exportApksStatus
                    .isRunInBackground;

                int current = state.exportApksStatus.current;
                int total = state.exportApksStatus.total;

                logger.d(
                    "Export status uploading, isRunInBackground: $isRunInBackground, current: $current, total: $total");

                if (isRunInBackground) {
                  context.read<ManageAppsHomeBloc>().add(
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
                    .read<ManageAppsHomeBloc>()
                    .state
                    .exportApksStatus
                    .isRunInBackground;

                if (isRunInBackground) {
                  context.read<ManageAppsHomeBloc>().add(
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
                    .read<ManageAppsHomeBloc>()
                    .state
                    .exportApksStatus
                    .isRunInBackground;

                if (isRunInBackground) {
                  context.read<ManageAppsHomeBloc>().add(
                      ManageAppsIndicatorStatusChanged(
                          ManageAppsProgressIndicatorStatus(visible: false)));
                } else {
                  _dismissProgressIndicator();
                }
                SoundEffect.play(SoundType.done);
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
                        iconPath: "assets/icons/ic_install.png",
                        iconSize: 17,
                        text: context.l10n.installApp,
                        space: 10,
                        margin: EdgeInsets.only(left: 20),
                        onTap: () {
                          _selectInstallationPackage(context, (path) async {
                            _install(context, path);
                          });
                        },
                      ),
                      UnifiedIconButtonWithText(
                        iconPath: "assets/icons/ic_export.png",
                        iconSize: 19,
                        text: context.l10n.export,
                        space: 10,
                        margin: EdgeInsets.only(left: 10),
                        enable: checkedApps.isNotEmpty,
                        onTap: () {
                          _exportApks(context);
                        },
                      ),
                      UnifiedIconButtonWithText(
                        iconPath: "assets/icons/ic_delete.png",
                        iconSize: 22,
                        text: context.l10n.uninstall,
                        space: 6,
                        margin: EdgeInsets.only(left: 10),
                        enable: checkedApps.isNotEmpty,
                        onTap: () {
                          List<AppInfo> apps = context
                              .read<ManageAppsHomeBloc>()
                              .state
                              .checkedUserApps;
                          _batchUninstall(context, apps);
                        },
                      ),
                      UnifiedIconButtonWithText(
                        iconPath: "assets/icons/ic_refresh.png",
                        iconSize: 25,
                        text: context.l10n.refresh,
                        space: 8,
                        margin: EdgeInsets.only(left: 10),
                        onTap: () {
                          context
                              .read<ManageAppsHomeBloc>()
                              .add(ManageAppsSubscriptionRequested());
                        },
                      ),
                    ],
                  ),
                  Spacer(),
                  Container(
                    child: Row(
                      children: [
                        Builder(builder: (context) {
                          return UnifiedIconButtonWithText(
                              iconPath: "assets/icons/ic_arrow_downward.png",
                              text: context.l10n.sortBy,
                              isIconAtLeft: false,
                              iconSize: 18,
                              space: 3,
                              onTap: () {
                                BotToast.showAttachedWidget(
                                    targetContext: context,
                                    verticalOffset: 5,
                                    attachedBuilder: (cancelFunc) {
                                      final rowHeight = 40.0;
                                      final width = 200.0;
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
                                                    ManageAppsSortColumn
                                                        .appName,
                                                isAscending: sortDirection ==
                                                    ManageAppsSortDirection
                                                        .ascending,
                                                onTap: () {
                                                  cancelFunc.call();

                                                  var sortColumn = context
                                                      .read<
                                                          ManageAppsHomeBloc>()
                                                      .state
                                                      .userAppsSortColumn;
                                                  var sortDirection = context
                                                      .read<
                                                          ManageAppsHomeBloc>()
                                                      .state
                                                      .userAppsSortDirection;

                                                  if (!isUserApps) {
                                                    sortColumn = context
                                                        .read<
                                                            ManageAppsHomeBloc>()
                                                        .state
                                                        .systemAppsSortColumn;
                                                    sortDirection = context
                                                        .read<
                                                            ManageAppsHomeBloc>()
                                                        .state
                                                        .systemAppsSortDirection;
                                                  }

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
                                                        .read<
                                                            ManageAppsHomeBloc>()
                                                        .add(ManageAppsSortChanged(
                                                            sortColumn:
                                                                ManageAppsSortColumn
                                                                    .appName,
                                                            sortDirection:
                                                                nextSortDirection));
                                                  } else {
                                                    context
                                                        .read<
                                                            ManageAppsHomeBloc>()
                                                        .add(ManageAppsSortChanged(
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
                                                      .read<
                                                          ManageAppsHomeBloc>()
                                                      .state
                                                      .userAppsSortColumn;
                                                  final sortDirection = context
                                                      .read<
                                                          ManageAppsHomeBloc>()
                                                      .state
                                                      .userAppsSortDirection;

                                                  if (sortColumn ==
                                                      ManageAppsSortColumn
                                                          .size) {
                                                    final nextSortDirection =
                                                        sortDirection ==
                                                                ManageAppsSortDirection
                                                                    .ascending
                                                            ? ManageAppsSortDirection
                                                                .descending
                                                            : ManageAppsSortDirection
                                                                .ascending;
                                                    context
                                                        .read<
                                                            ManageAppsHomeBloc>()
                                                        .add(ManageAppsSortChanged(
                                                            sortColumn:
                                                                ManageAppsSortColumn
                                                                    .size,
                                                            sortDirection:
                                                                nextSortDirection));
                                                  } else {
                                                    context
                                                        .read<
                                                            ManageAppsHomeBloc>()
                                                        .add(ManageAppsSortChanged(
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
                              });
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
                                  context.read<ManageAppsHomeBloc>().add(
                                      ManageAppsKeyWordChanged(value));
                                },
                              );
                            }),
                          ),
                          width: 200,
                          height: 30,
                          margin: EdgeInsets.only(left: 10, right: 10),
                        ),
                       

                        UnifiedIconButton(
                          width: 25, 
                          height: 25, 
                          iconPath: "assets/icons/ic_search.png",
                          padding: EdgeInsets.all(5),
                          onTap: () {
                              context.read<ManageAppsHomeBloc>().add(
                                  ManageAppsKeyWordChanged(
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
            Divider(color: dividerLineColor, height: 1.0, thickness: 1.0),
            Expanded(
                child: Stack(
              children: [
                Visibility(
                  child: Container(
                    color: Colors.white,
                    child: StatefulBuilder(builder: (context, setState) {
                      return SfDataGridTheme(
                          data: SfDataGridThemeData(),
                          child: SfDataGrid(
                            source: dataSource,
                            allowColumnsResizing: true,
                            headerGridLinesVisibility:
                                GridLinesVisibility.horizontal,
                            gridLinesVisibility: GridLinesVisibility.horizontal,
                            columnResizeMode: ColumnResizeMode.onResize,
                            showCheckboxColumn: true,
                            checkboxColumnSettings:
                                DataGridCheckboxColumnSettings(width: 70),
                            headerRowHeight: 40,
                            selectionMode: SelectionMode.multiple,
                            controller: controller,
                            onSelectionChanged: (addedRows, removedRows) {
                              final selectedRows = controller.selectedRows;
                              final selectedApps = selectedRows
                                  .map((row) => _parseAppInfo(row))
                                  .toList();

                              context.read<ManageAppsHomeBloc>().add(
                                  ManageAppsCheckChanged(
                                      checkedApps: selectedApps,
                                      isUserApps: isUserApps));
                            },
                            onColumnResizeUpdate: (details) {
                              setState(() {
                                AppInfoColumn column = AppInfoColumn.values
                                    .where((column) =>
                                        column.toString() ==
                                        details.column.columnName)
                                    .first;
                                columnWidths[column] = details.width;
                              });
                              return true;
                            },
                            columns: [
                              GridColumn(
                                  columnName:
                                      AppInfoColumn.iconAndName.toString(),
                                  columnWidthMode: ColumnWidthMode.fill,
                                  width:
                                      columnWidths[AppInfoColumn.iconAndName]!,
                                  label: Container(
                                    padding: EdgeInsets.only(left: 16),
                                    alignment: Alignment.centerLeft,
                                    child: Text(context.l10n.app,
                                        style: headerTextStyle),
                                  ),
                                  minimumWidth: 200,
                                  maximumWidth: 400),
                              GridColumn(
                                  columnName: AppInfoColumn.size.toString(),
                                  columnWidthMode: ColumnWidthMode.fill,
                                  width: columnWidths[AppInfoColumn.size]!,
                                  label: Container(
                                    padding: EdgeInsets.only(left: 16),
                                    alignment: Alignment.centerLeft,
                                    child: Text(context.l10n.size,
                                        style: headerTextStyle),
                                  ),
                                  minimumWidth: 100,
                                  maximumWidth: 200),
                              GridColumn(
                                  columnName: AppInfoColumn.version.toString(),
                                  columnWidthMode: ColumnWidthMode.fill,
                                  width: columnWidths[AppInfoColumn.version]!,
                                  label: Container(
                                    padding: EdgeInsets.only(left: 16),
                                    alignment: Alignment.centerLeft,
                                    child: Text(context.l10n.versionName,
                                        style: headerTextStyle),
                                  ),
                                  minimumWidth: 200,
                                  maximumWidth: 400),
                              GridColumn(
                                  columnName: AppInfoColumn.action.toString(),
                                  columnWidthMode: ColumnWidthMode.fill,
                                  width: columnWidths[AppInfoColumn.action]!,
                                  label: Container(
                                    padding: EdgeInsets.only(left: 16),
                                    alignment: Alignment.centerLeft,
                                    child: Text(context.l10n.operate,
                                        style: headerTextStyle),
                                  ),
                                  minimumWidth: 100)
                            ],
                          ));
                    }),
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

  void _initAppsSelected(DataGridController controller,
      AppInfoDataSource dataSource, List<AppInfo> checkedApps) {
    final rows = dataSource.dataGridRows;

    List<DataGridRow> checkedRows = [];

    for (final row in rows) {
      if (checkedApps.contains(_parseAppInfo(row))) {
        checkedRows.add(row);
      }
    }
    controller.selectedRows = checkedRows;
  }

  AppInfo _parseAppInfo(DataGridRow row) {
    return row
        .getCells()
        .where(
            (cell) => cell.columnName == AppInfoColumn.iconAndName.toString())
        .first
        .value as AppInfo;
  }
}

enum AppInfoColumn { iconAndName, size, version, action }

class AppInfoDataSource extends DataGridSource {
  final bool isUserApps;
  List<AppInfo> apps;
  final List<AppInfo> checkedApps;
  final BuildContext context;
  List<DataGridRow> dataGridRows = [];
  final _rootURL =
      "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}";

  AppInfoDataSource(
      {required this.isUserApps,
      required this.apps,
      required this.checkedApps,
      required this.context}) {
    dataGridRows = apps
        .map<DataGridRow>((app) => DataGridRow(cells: [
              DataGridCell(
                  columnName: AppInfoColumn.iconAndName.toString(), value: app),
              DataGridCell(
                  columnName: AppInfoColumn.size.toString(), value: app.size),
              DataGridCell(
                  columnName: AppInfoColumn.version.toString(),
                  value: app.versionName),
              DataGridCell(
                  columnName: AppInfoColumn.action.toString(), value: app),
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  void updataDataSource(List<AppInfo> apps) {
    this.apps = apps;
    dataGridRows = apps
        .map<DataGridRow>((app) => DataGridRow(cells: [
              DataGridCell(
                  columnName: AppInfoColumn.iconAndName.toString(), value: app),
              DataGridCell(
                  columnName: AppInfoColumn.size.toString(), value: app.size),
              DataGridCell(
                  columnName: AppInfoColumn.version.toString(),
                  value: app.versionName),
              DataGridCell(
                  columnName: AppInfoColumn.action.toString(), value: app),
            ]))
        .toList();
    notifyListeners();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((cell) {
      AppInfoColumn column = AppInfoColumn.values
          .where((column) => column.toString() == cell.columnName)
          .first;
      final TextStyle headerStyle =
          TextStyle(fontSize: 14, color: Colors.black);

      Color textColor = false ? Colors.white : Color(0xff313237);

      TextStyle textStyle = TextStyle(fontSize: 14, color: textColor);

      switch (column) {
        case AppInfoColumn.iconAndName:
          {
            final app = cell.value as AppInfo;
            return Container(
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
                  SizedBox(
                    child: Flexible(
                      child: Text(app.name, style: textStyle),
                    ),
                  )
                ],
              ),
              color: Colors.transparent,
            );
          }
        case AppInfoColumn.size:
          {
            final size = cell.value as int;
            return Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
              child: Text(CommonUtil.convertToReadableSize(size),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: textStyle),
              color: Colors.transparent,
            );
          }
        case AppInfoColumn.version:
          {
            final version = cell.value as String;
            return Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
              child: Text(
                  "${context.l10n.placeHolderVersionName.replaceAll("%s", version)}",
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle),
              color: Colors.transparent,
            );
          }
        default:
          {
            return Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
              child: OutlinedButton(
                child: Text(context.l10n.uninstall,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: textStyle),
                onPressed: () {
                  final app = cell.value as AppInfo;
                  _batchUninstall(context, [app]);
                },
              ),
              color: Colors.transparent,
            );
          }
      }
    }).toList());
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
}
