import 'package:air_controller/ext/scaffoldx.dart';
import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/manage_contacts/bloc/manage_contacts_bloc.dart';
import 'package:air_controller/manage_contacts/widget/account_groups_item.dart';
import 'package:air_controller/model/account.dart';
import 'package:air_controller/model/contact_account_info.dart';
import 'package:air_controller/model/contact_group.dart';
import 'package:air_controller/model/contact_basic_info.dart';
import 'package:air_controller/repository/contact_repository.dart';
import 'package:air_controller/widget/bottom_count_view.dart';
import 'package:air_controller/widget/unfied_back_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

import '../../constant.dart';
import '../../model/phone.dart';
import '../../network/device_connection_manager.dart';
import '../../widget/unified_icon_button.dart';
import '../../widget/unified_icon_button_with_text.dart';
import '../../widget/unified_text_field.dart';
import 'data_grid_holder.dart';

class ManageContactsPage extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const ManageContactsPage(this.navigatorKey);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ManageContactsBloc(
        contactRepository: context.read<ContactRepository>(),
      )..add(ManageContactsSubscriptionRequested()),
      child: _ManageContactsView(this.navigatorKey),
    );
  }
}

class _ManageContactsView extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  _ManageContactsView(this.navigatorKey);

  @override
  Widget build(BuildContext context) {
    final dividerLine = Color(0xffe0e0e0);

    final status =
        context.select((ManageContactsBloc bloc) => bloc.state.status);
    final contacts =
        context.select((ManageContactsBloc bloc) => bloc.state.contacts);
    final selectedContacts = context.select(
      (ManageContactsBloc bloc) => bloc.state.selectedContacts,
    );

    final dataGridWidth = 250.0;
    ContactsDataSource? dataSource = DataGridHolder.dataSource;
    DataGridController? dataGridController = DataGridHolder.controller;

    if (null == dataSource) {
      dataSource = ContactsDataSource(
          dataGridWidth: dataGridWidth, contacts: contacts, context: context);
      DataGridHolder.dataSource = dataSource;
    } else {
      dataSource.updataDataSource(contacts);
    }

    if (null == dataGridController) {
      final dataGridController = DataGridController();
      DataGridHolder.controller = dataGridController;
    }

    _initSelection(selectedContacts);

    return Scaffold(
      backgroundColor: Colors.white,
      body: MultiBlocListener(
        listeners: [
          BlocListener<ManageContactsBloc, ManageContactsState>(
            listener: (context, state) {
              if (state.status == ManageContactsStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBarText(
                  state.failureReason ?? context.l10n.unknownError,
                );
              }
            },
            listenWhen: (previous, current) =>
                previous.status != current.status &&
                current.status != ManageContactsStatus.initial,
          ),
        ],
        child: Column(
          children: [
            _TitleBar(
              onBackTap: () {
                navigatorKey.currentState?.pop();
              },
            ),
            Divider(color: dividerLine, height: 1.0, thickness: 1.0),
            _ContactActionBar(
              onCheckChanged: (isChecked) {},
              onNewContact: () {},
              onDeleteClick: () {},
              onRefresh: () {
                context.read<ManageContactsBloc>().add(
                      RefreshRequested(),
                    );
              },
              onKeywordChanged: (value) {},
              onSearchClick: () {},
            ),
            Divider(color: dividerLine, height: 1.0, thickness: 1.0),
            Expanded(
                child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _ContactGroupList(),
                VerticalDivider(
                    width: 1.0, thickness: 1.0, color: Color(0xffececec)),
                _ContactsGridView(
                  dataGridWidth: dataGridWidth,
                  isLoading: status == ManageContactsStatus.loading,
                  dataSource: dataSource,
                  controller: dataGridController!,
                ),
                VerticalDivider(
                    width: 1.0, thickness: 1.0, color: Color(0xffececec)),
                _ContactDetailView()
              ],
            )),
            BottomCountView(
                checkedCount: selectedContacts.length,
                totalCount: contacts.length),
          ],
        ),
      ),
    );
  }

  void _initSelection(List<ContactBasicInfo> selectedContacts) {
    final dataGridController = DataGridHolder.controller;
    final dataSource = DataGridHolder.dataSource;

    if (null == dataGridController || null == dataSource) {
      return;
    }

    dataGridController.selectedRows = dataSource.dataGridRows.where((row) {
      final contactInfo = row.getCells().first.value as ContactBasicInfo;
      return selectedContacts.contains(contactInfo);
    }).toList();
  }
}

class _ContactDetailView extends StatelessWidget {
  const _ContactDetailView();

  @override
  Widget build(BuildContext context) {
    final _rootURL =
        "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}";

    final selectedContacts = context.select(
      (ManageContactsBloc bloc) => bloc.state.selectedContacts,
    );
    final contactDetail =
        context.select((ManageContactsBloc bloc) => bloc.state.contactDetail);

    if (selectedContacts.isEmpty || null == contactDetail) {
      return Expanded(
          child: Container(
        color: Colors.white,
        height: double.infinity,
      ));
    }

    String imageUrl = "$_rootURL/stream/photoUri?uri=${contactDetail.photoUri}";

    return Expanded(
        child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildBasicInfo(
              context: context,
              displayName: contactDetail.displayNamePrimary,
              imageUrl: imageUrl,
              groups: contactDetail.groups,
              accounts: contactDetail.accounts),
          _buildOtherInfo(context, contactDetail.phones)
        ],
      ),
    ));
  }

  Widget _buildBasicInfo(
      {required BuildContext context,
      required String? displayName,
      required String imageUrl,
      required List<Account>? accounts,
      required List<ContactGroup>? groups}) {
    final accountsText = accounts?.map((account) {
      return account.name.toString();
    }).join(', ');

    final groupsText = groups?.map((group) {
      return group.title.toString();
    }).join(', ');

    return Padding(
      child: SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhotoView(imageUrl),
            Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildNameView(
                          displayName: displayName ?? "", onTap: () {}),
                      _buildLabelView(
                          top: 5,
                          label: context.l10n.accountLabel,
                          text: accountsText ?? ""),
                      Spacer(),
                      _buildLabelView(
                          label: context.l10n.groupLabel,
                          text: groupsText ?? ""),
                    ])),
          ],
        ),
        height: 100,
      ),
      padding: EdgeInsets.only(left: 15, top: 15),
    );
  }

  Widget _buildPhotoView(String imageUrl) {
    final imageSize = 100.0;

    return CachedNetworkImage(
        imageUrl: imageUrl,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) {
          return Container(
            color: Color(0xff34a9ff),
            alignment: Alignment.center,
            width: imageSize,
            height: imageSize,
            child: Image.asset(
              "assets/icons/default_contact.png",
              width: 50,
              height: 50,
              color: Colors.white,
            ),
          );
        });
  }

  Widget _buildNameView(
      {required String displayName, required VoidCallback onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          displayName,
          style: TextStyle(fontSize: 25.0, color: Color(0xff474747)),
        ),
        Padding(
            padding: EdgeInsets.only(top: 5),
            child: IconButton(
              icon: Image.asset("assets/icons/edit_contact.png",
                  width: 25, height: 25, color: Color(0xffa8a8a8)),
              onPressed: () {
                onTap();
              },
            ))
      ],
    );
  }

  Widget _buildLabelView(
      {double top = 0, required String label, required String text}) {
    return Padding(
        padding: EdgeInsets.only(top: top),
        child: Text(
          "$label$text",
          style: TextStyle(fontSize: 14.0),
          overflow: TextOverflow.ellipsis,
        ));
  }

  Widget _buildOtherInfo(BuildContext context, List<Phone>? phones) {
    final labelColor = Color(0xff999999);
    final phoneColor = Color(0xff474747);
    final fontSize = 14.0;

    return FractionallySizedBox(
      widthFactor: 0.8,
      child: Padding(
          padding: EdgeInsets.only(top: 10),
          child: Wrap(
            direction: Axis.horizontal,
            children:
                List.generate(phones == null ? 0 : phones.length, (index) {
              final phone = phones![index];

              return Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(phone.label ?? "",
                          style: TextStyle(
                            color: labelColor,
                            fontSize: fontSize,
                          )),
                      Text(phone.normalizedNumber ?? "",
                          style: TextStyle(
                            color: phoneColor,
                            fontSize: fontSize,
                          )),
                    ],
                  ));
            }),
          )),
    );
  }
}

enum ContactsColumn { name }

class _ContactGroupList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 5;

    return Container(
      child: Column(
        children: [
          _buildAllContacts(context: context),
          _buildAccountGroups(context, width)
        ],
      ),
      width: width,
      height: double.infinity,
      color: Colors.white,
    );
  }

  Widget _buildAccountGroups(BuildContext context, double width) {
    final expandedAccounts = context
        .select((ManageContactsBloc bloc) => bloc.state.expandedAccounts);
    final checkedItem =
        context.select((ManageContactsBloc bloc) => bloc.state.checkedItem);
    final isAllContactsExpanded = context
        .select((ManageContactsBloc bloc) => bloc.state.isAllContactsExpanded);
    final isAllContactsChecked = context
        .select((ManageContactsBloc bloc) => bloc.state.isAllContactsChecked);
    final accounts =
        context.select((ManageContactsBloc bloc) => bloc.state.accounts);

    return Visibility(
      child: Column(
          children: List.generate(accounts.length, (index) {
        final account = accounts[index];
        ContactAccountInfo? checkedAccount;
        ContactGroup? checkedGroup;

        if (checkedItem is ContactGroup) {
          checkedGroup = checkedItem;
        } else if (checkedItem is ContactAccountInfo) {
          checkedAccount = checkedItem;
        }

        return AccountGroupsItem(
            width: width,
            accountInfo: account,
            isExpanded: expandedAccounts.contains(account),
            isAccountChecked:
                account == checkedAccount && !isAllContactsChecked,
            checkedGroup: isAllContactsChecked ? null : checkedGroup,
            onExpandTap: (isExpand) {
              context.read<ManageContactsBloc>().add(
                    ManageContactsExpandedStatusChanged(
                      account: account,
                      isExpanded: isExpand,
                    ),
                  );
            },
            onAccountTap: (account) {
              context.read<ManageContactsBloc>().add(
                    ManageContactsCheckedChanged(
                      account,
                    ),
                  );
            },
            onGroupTap: (group) {
              context.read<ManageContactsBloc>().add(
                    ManageContactsCheckedChanged(
                      group,
                    ),
                  );
            });
      })),
      visible: isAllContactsExpanded,
    );
  }

  Widget _buildAllContacts({required BuildContext context}) {
    final total = context.select((ManageContactsBloc bloc) => bloc.state.total);
    final isExpanded = context
        .select((ManageContactsBloc bloc) => bloc.state.isAllContactsExpanded);

    final icon =
        !isExpanded ? Icons.expand_more_outlined : Icons.expand_less_outlined;
    final isAllContactsChecked = context
        .select((ManageContactsBloc bloc) => bloc.state.isAllContactsChecked);

    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
                context.read<ManageContactsBloc>().add(
                      AllContactsExpandedStatusChanged(
                          isAllContactsExpanded: !isExpanded),
                    );
              },
              icon: Icon(icon,
                  color:
                      isAllContactsChecked ? Colors.white : Color(0xff777777),
                  size: 16)),
          GestureDetector(
            child: SizedBox(
              child: Text(
                context.l10n.placeHolderAllContacts
                    .replaceFirst("%s", "$total"),
                style: TextStyle(
                  color:
                      isAllContactsChecked ? Colors.white : Color(0xff777777),
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
              width: 150,
            ),
            onTap: () {
              context.read<ManageContactsBloc>().add(
                  AllContactsCheckedStatusChanged(isAllContactsChecked: true));
            },
          ),
        ],
      ),
      height: 40,
      color: isAllContactsChecked ? Color(0xff0092fd) : Colors.white,
    );
  }
}

class ContactsDataSource extends DataGridSource {
  List<ContactBasicInfo> contacts;
  final BuildContext context;
  List<DataGridRow> dataGridRows = [];
  final double dataGridWidth;

  final _rootURL =
      "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}";

  ContactsDataSource(
      {required this.context,
      required this.dataGridWidth,
      required this.contacts}) {
    dataGridRows = contacts
        .map<DataGridRow>((contact) => DataGridRow(cells: [
              DataGridCell(
                  columnName: ContactsColumn.name.toString(), value: contact),
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  void updataDataSource(List<ContactBasicInfo> contacts) {
    this.contacts = contacts;
    dataGridRows = contacts
        .map<DataGridRow>((contact) => DataGridRow(cells: [
              DataGridCell(
                  columnName: ContactsColumn.name.toString(), value: contact),
            ]))
        .toList();
    notifyListeners();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((cell) {
      final contactInfo = cell.value as ContactBasicInfo;

      return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.fromLTRB(0, 6, 0, 6),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl:
                  "$_rootURL/stream/photoUri?uri=${contactInfo.photoThumbnailUri}",
              width: 60,
              height: 60,
              errorWidget: (context, url, error) {
                return Padding(
                    padding: EdgeInsets.only(left: 6, right: 6),
                    child: Container(
                      color: Color(0xff34a9ff),
                      alignment: Alignment.center,
                      width: 60,
                      height: 60,
                      child: Image.asset(
                        "assets/icons/default_contact.png",
                        width: 25,
                        height: 25,
                        color: Colors.white,
                      ),
                    ));
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(contactInfo.displayNamePrimary ?? "",
                    style: TextStyle(
                        color: Color(0xff474747),
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                SizedBox(
                  child: Padding(
                    padding: EdgeInsets.only(top: 3, right: 10),
                    child: Text(
                      contactInfo.phoneNumber ?? "",
                      style: TextStyle(
                          color: Color(0xff999999),
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis),
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                  width: dataGridWidth - 70,
                ),
              ],
            ),
          ],
        ),
        color: Colors.transparent,
      );
    }).toList());
  }
}

class _TitleBar extends StatelessWidget {
  final VoidCallback? onBackTap;

  const _TitleBar({required this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: UnifiedBackButton(
                        title: context.l10n.back,
                        width: 60,
                        height: 25,
                        margin: EdgeInsets.only(left: 15),
                        onTap: () {
                          onBackTap?.call();
                        },
                      )),
                ],
              )),
          Align(
              alignment: Alignment.center,
              child: Text(context.l10n.manageContacts,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xff616161), fontSize: 16.0))),
        ],
      ),
      height: Constant.HOME_NAVI_BAR_HEIGHT,
      color: Color(0xfff6f6f6),
    );
  }
}

class _ContactActionBar extends StatelessWidget {
  final Function(bool isChecked) onCheckChanged;
  final Function() onNewContact;
  final Function() onDeleteClick;
  final Function() onRefresh;
  final Function(String keyword) onKeywordChanged;
  final Function() onSearchClick;

  const _ContactActionBar(
      {required this.onCheckChanged,
      required this.onNewContact,
      required this.onDeleteClick,
      required this.onRefresh,
      required this.onKeywordChanged,
      required this.onSearchClick});

  @override
  Widget build(BuildContext context) {
    final selectedContacts = context
        .select((ManageContactsBloc bloc) => bloc.state.selectedContacts);

    return Container(
      child: Row(
        children: [
          Row(
            children: [
              UnifiedIconButtonWithText(
                iconPath: "assets/icons/ic_install.png",
                iconSize: 17,
                text: context.l10n.newContact,
                space: 10,
                margin: EdgeInsets.only(left: 20),
                onTap: () {},
              ),
              UnifiedIconButtonWithText(
                iconPath: "assets/icons/ic_delete.png",
                iconSize: 22,
                text: context.l10n.delete,
                space: 6,
                margin: EdgeInsets.only(left: 10),
                enable: selectedContacts.isNotEmpty,
                onTap: () {},
              ),
              UnifiedIconButtonWithText(
                iconPath: "assets/icons/ic_refresh.png",
                iconSize: 25,
                text: context.l10n.refresh,
                space: 8,
                margin: EdgeInsets.only(left: 10),
                onTap: () {
                  onRefresh();
                },
              ),
            ],
          ),
          Spacer(),
          Container(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: UnifiedTextField(
                    style: TextStyle(fontSize: 14, color: Color(0xff333333)),
                    hintText: context.l10n.search,
                    // controller: searchEditingController,
                    borderRadius: 3,
                    cursorColor: Color(0xff999999),
                    cursorHeight: 15,
                    onChange: (value) {},
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
                    onTap: () {})
              ],
            ),
            width: 350,
            margin: EdgeInsets.only(right: 15),
          )
        ],
      ),
      height: 50,
      color: Colors.white,
    );
  }
}

class _ContactsGridView extends StatelessWidget {
  final double dataGridWidth;
  final ContactsDataSource dataSource;
  final DataGridController controller;
  final bool isLoading;

  const _ContactsGridView(
      {required this.dataGridWidth,
      required this.dataSource,
      required this.controller,
      required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final checkboxWidth = 40.0;
    return Stack(
      children: [
        if (!isLoading)
          SfDataGridTheme(
              data: SfDataGridThemeData(),
              child: SfDataGrid(
                source: dataSource,
                headerGridLinesVisibility: GridLinesVisibility.both,
                gridLinesVisibility: GridLinesVisibility.both,
                showCheckboxColumn: true,
                checkboxColumnSettings:
                    DataGridCheckboxColumnSettings(width: checkboxWidth),
                headerRowHeight: 40,
                rowHeight: 60,
                selectionMode: SelectionMode.multiple,
                controller: controller,
                onSelectionChanged: (addedRows, removedRows) {
                  final selectedContacts = controller.selectedRows
                      .map((e) => e.getCells().first.value as ContactBasicInfo)
                      .toList();

                  context
                      .read<ManageContactsBloc>()
                      .add(SelectedContactsChanged(selectedContacts));
                },
                columns: [
                  GridColumn(
                      columnName: ContactsColumn.name.toString(),
                      columnWidthMode: ColumnWidthMode.fill,
                      label: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 10),
                        child: Text(context.l10n.name,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            )),
                      ),
                      width: dataGridWidth),
                ],
              )),
        if (isLoading)
          Container(
            child: SpinKitCircle(color: Color(0xff85a8d0), size: 60.0),
            color: Colors.white,
            width: dataGridWidth + checkboxWidth,
            height: double.infinity,
          )
      ],
    );
  }
}
