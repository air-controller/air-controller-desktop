import 'package:air_controller/edit_contact/view/edit_contact_view.dart';
import 'package:air_controller/ext/scaffoldx.dart';
import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/manage_contacts/bloc/manage_contacts_bloc.dart';
import 'package:air_controller/manage_contacts/view/view.dart';
import 'package:air_controller/manage_contacts/widget/account_groups_item.dart';
import 'package:air_controller/model/account.dart';
import 'package:air_controller/model/contact_account_info.dart';
import 'package:air_controller/model/contact_detail.dart';
import 'package:air_controller/model/contact_field_value.dart';
import 'package:air_controller/model/contact_group.dart';
import 'package:air_controller/model/contact_basic_info.dart';
import 'package:air_controller/repository/contact_repository.dart';
import 'package:air_controller/widget/bottom_count_view.dart';
import 'package:air_controller/widget/unfied_back_button.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

import '../../constant.dart';
import '../../edit_contact/bloc/bloc/edit_contact_bloc.dart';
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
    final requestType =
        context.select((ManageContactsBloc bloc) => bloc.state.requestType);

    final contacts =
        context.select((ManageContactsBloc bloc) => bloc.state.contacts);
    final selectedContacts = context.select(
      (ManageContactsBloc bloc) => bloc.state.selectedContacts,
    );
    final keyword = context.select(
      (ManageContactsBloc bloc) => bloc.state.keyword,
    );

    final dataGridWidth = 250.0;
    ContactsDataSource? dataSource = DataGridHolder.dataSource;
    DataGridController? dataGridController = DataGridHolder.controller;

    List<ContactBasicInfo> filteredContacts =
        contacts.where((contact) => _filterContact(contact, keyword)).toList();
    ;

    if (null == dataSource) {
      dataSource = ContactsDataSource(
          dataGridWidth: dataGridWidth,
          contacts: filteredContacts,
          context: context);
      DataGridHolder.dataSource = dataSource;
    } else {
      dataSource.updataDataSource(filteredContacts);
    }

    if (null == dataGridController) {
      final dataGridController = DataGridController();
      DataGridHolder.controller = dataGridController;
    }

    _initSelection(selectedContacts);

    bool needLoading = false;

    if (requestType == ManageContactsRequestType.initial &&
        status == ManageContactsStatus.loading) {
      needLoading = true;
    }

    final isInitDone =
        context.select((ManageContactsBloc bloc) => bloc.state.isInitDone);

    needLoading = !isInitDone;

    return Scaffold(
      backgroundColor: Colors.white,
      body: MultiBlocListener(
        listeners: [
          BlocListener<ManageContactsBloc, ManageContactsState>(
            listener: (context, state) {
              if (state.status == ManageContactsStatus.failure) {
                BotToast.closeAllLoading();

                ScaffoldMessenger.of(context).showSnackBarText(
                  state.failureReason ?? context.l10n.unknownError,
                );
              }

              final requestType = state.requestType;
              if (requestType != ManageContactsRequestType.initial) {
                if (state.status == ManageContactsStatus.loading) {
                  BotToast.showLoading();
                }

                if (state.status == ManageContactsStatus.success) {
                  BotToast.closeAllLoading();
                }
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
              onNewContact: () {
                _showEditContactDialog(pageContext: context, isNew: true);
              },
              onDeleteClick: () {
                context.read<ManageContactsBloc>().add(
                      DeleteContactsRequested(),
                    );
              },
              onRefresh: () {
                context.read<ManageContactsBloc>().add(
                      RefreshRequested(),
                    );
              },
              onKeywordChanged: (value) {
                context.read<ManageContactsBloc>().add(
                      KeywordChanged(value),
                    );
              },
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
                  isLoading: needLoading,
                  dataSource: dataSource,
                  controller: dataGridController!,
                ),
                VerticalDivider(
                    width: 1.0, thickness: 1.0, color: Color(0xffececec)),
                _ContactDetailView(onEdit: (value) {
                  _showEditContactDialog(pageContext: context, isNew: false);
                })
              ],
            )),
            BottomCountView(
                checkedCount: selectedContacts.length,
                totalCount: filteredContacts.length),
          ],
        ),
      ),
    );
  }

  bool _filterContact(ContactBasicInfo contact, String keyword) {
    if (keyword.isEmpty) {
      return true;
    }

    if (contact.displayNamePrimary == null) return false;

    if ((contact.displayNamePrimary!
        .toLowerCase()
        .contains(keyword.toLowerCase()))) return true;

    if (contact.phoneNumber.contains(keyword)) return true;

    return false;
  }

  void _showEditContactDialog(
      {required BuildContext pageContext, required bool isNew}) {
    final accounts = pageContext.read<ManageContactsBloc>().state.accounts;

    showDialog(
      context: pageContext,
      builder: (context) => BlocProvider(
        create: (context) {
          if (isNew) {
            return EditContactBloc.newForNewContact(
                contactRepository: pageContext.read<ContactRepository>(),
                accountInfoList: accounts)
              ..add(SubscriptionRequested());
          } else {
            final contactDetail =
                pageContext.read<ManageContactsBloc>().state.contactDetail;

            return EditContactBloc.newForEditContact(
                contactRepository: pageContext.read<ContactRepository>(),
                contactDetail: contactDetail,
                accountInfoList: accounts)
              ..add(SubscriptionRequested());
          }
        },
        child: EditContactView(),
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
  final Function(ContactDetail) onEdit;

  const _ContactDetailView({required this.onEdit});

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

    return Expanded(
        child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildBasicInfo(
              context: context,
              displayName: contactDetail.displayNamePrimary,
              rawContactId: contactDetail.id,
              groups: contactDetail.groups,
              accounts: contactDetail.accounts,
              onEdit: () {
                onEdit(contactDetail);
              }),
          _buildOtherInfo(context, contactDetail.phones)
        ],
      ),
    ));
  }

  Widget _buildBasicInfo(
      {required BuildContext context,
      required String? displayName,
      required int rawContactId,
      required List<Account>? accounts,
      required List<ContactGroup>? groups,
      required VoidCallback onEdit}) {
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
            ContactAvatarView(
                rawContactId: rawContactId,
                width: 100,
                height: 100,
                iconSize: 50),
            Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildNameView(
                          displayName: displayName ?? "",
                          onTap: () {
                            onEdit();
                          }),
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

  Widget _buildOtherInfo(
      BuildContext context, List<ContactFieldValue>? phones) {
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
                      Text(phone.type?.typeLabel ?? "",
                          style: TextStyle(
                            color: labelColor,
                            fontSize: fontSize,
                          )),
                      Text(phone.value,
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
                context.l10n.allContacts,
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

      return Row(
        children: [
          Padding(
              padding: EdgeInsets.only(left: 10, right: 5),
              child: ContactAvatarView(
                  rawContactId: contactInfo.id,
                  width: 45,
                  height: 45,
                  iconSize: 25)),
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
                    contactInfo.phoneNumber,
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
    final isInitDone =
        context.select((ManageContactsBloc bloc) => bloc.state.isInitDone);

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
                enable: isInitDone,
                onTap: () {
                  onNewContact();
                },
              ),
              UnifiedIconButtonWithText(
                iconPath: "assets/icons/ic_delete.png",
                iconSize: 22,
                text: context.l10n.delete,
                space: 6,
                margin: EdgeInsets.only(left: 10),
                enable: selectedContacts.isNotEmpty,
                onTap: () {
                  onDeleteClick();
                },
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
                    borderRadius: 3,
                    cursorColor: Color(0xff999999),
                    cursorHeight: 15,
                    onChange: (value) {
                      onKeywordChanged(value);
                    },
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
                shrinkWrapRows: false,
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
