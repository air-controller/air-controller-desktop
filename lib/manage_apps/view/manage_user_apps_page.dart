import 'dart:developer';
import 'dart:io';

import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/manage_apps/widget/app_sort_item.dart';
import 'package:air_controller/repository/common_repository.dart';
import 'package:air_controller/widget/unified_icon_button_with_text.dart';
import 'package:air_controller/widget/unified_text_field.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../constant.dart';
import '../../model/app_info.dart';
import '../../network/device_connection_manager.dart';
import '../../util/common_util.dart';
import '../bloc/manage_apps_bloc.dart';

class ManageUserAppsPage extends StatelessWidget {
  final _rootURL =
      "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}";

  void _selectInstallationPackage(
      BuildContext context, Function(String path) onSelected) {
    FilePicker.platform.pickFiles(
      dialogTitle: context.l10n.pleaseSelectInstallationPackage,
      allowedExtensions: ["apk", "aab"],
    ).then((result) {
      final path = result?.paths.single;
      if (null != path) {
        onSelected.call(path);
      }

      result?.files?.single?.bytes;
    });
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
    final searchEditingController = TextEditingController();

    return Scaffold(
      body: Column(
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
                        _selectInstallationPackage(context, (path) {
                          final repo = context.read<CommonRepository>();
                          repo.install(bundle: File(path));
                        });
                      },
                    ),
                    UnifiedIconButtonWithText(
                      iconData: FontAwesomeIcons.download,
                      text: context.l10n.export,
                      space: 3,
                      margin: EdgeInsets.only(left: 10),
                      onTap: () {
                        CommonUtil.openFilePicker(context.l10n.chooseDir,
                            (dir) {
                          final repo = context.read<CommonRepository>();
                          repo.exportApk(
                              packageName: "com.tencent.mm",
                              dir: dir,
                              fileName: "微信.apk",
                              onExportProgress: (current, total) {
                                print("Current: $current, total: $total");
                              },
                              onError: (error) {
                                print("Export apk failure.");
                              },
                              onSuccess: (dir, fileName) {
                                print("Export apk success");
                              });
                        }, (error) {});
                      },
                    ),
                    UnifiedIconButtonWithText(
                      iconData: FontAwesomeIcons.trashArrowUp,
                      text: context.l10n.uninstall,
                      space: 3,
                      margin: EdgeInsets.only(left: 10),
                    ),
                    UnifiedIconButtonWithText(
                      iconData: Icons.refresh,
                      text: context.l10n.refresh,
                      space: 3,
                      margin: EdgeInsets.only(left: 10),
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
                                preferDirection: PreferDirection.bottomCenter);
                          },
                        );
                      }),
                      Container(
                        child: UnifiedTextField(
                          style:
                              TextStyle(fontSize: 14, color: Color(0xff333333)),
                          hintText: context.l10n.search,
                          controller: searchEditingController,
                          borderRadius: 3,
                          cursorColor: Color(0xff999999),
                          cursorHeight: 15,
                        ),
                        width: 200,
                        height: 30,
                        margin: EdgeInsets.only(left: 10, right: 10),
                      ),
                      Icon(Icons.search)
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
                      Color textColor =
                          false ? Colors.white : Color(0xff313237);
                      TextStyle textStyle =
                          TextStyle(fontSize: 14, color: textColor);

                      AppInfo app = userApps[index];

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
                                    CommonUtil.convertToReadableSize(app.size),
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
                                  onPressed: () {},
                                ),
                                color: Colors.transparent,
                              ),
                              onPointerDown: (event) {},
                            )),
                          ],
                          selected: false,
                          onSelectChanged: (isSelected) {
                            debugPrint("onSelectChanged: $isSelected");
                          },
                          onTap: () {},
                          onDoubleTap: () {},
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
    );
  }
}
