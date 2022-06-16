import 'dart:io';

import 'package:air_controller/ext/scaffoldx.dart';
import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/manage_contacts/view/view.dart';
import 'package:air_controller/model/contact_basic_info.dart';
import 'package:air_controller/model/contact_group.dart';
import 'package:air_controller/widget/single_input_dialog.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../bootstrap.dart';
import '../../edit_contact/bloc/bloc/edit_contact_bloc.dart';
import '../../model/account.dart';
import '../../model/contact_data_type.dart';
import '../../network/device_connection_manager.dart';
import '../../widget/unified_text_field.dart';

class EditContactView extends StatelessWidget {
  final double inputBoxHeight = 30;
  final double fieldLabelWidth = 65;
  final double fieldLabelPaddingRight = 5;
  final Function(ContactBasicInfo) onDone;
  final Function(bool isNew, int rawContactId) onUploadPhotoDone;

  EditContactView(
      {Key? key, required this.onDone, required this.onUploadPhotoDone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isInitDone = context.select(
      (EditContactBloc bloc) => bloc.state.isInitDone,
    );

    final width = 500.0;
    final height = 600.0;

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: MultiBlocListener(
          listeners: [
            BlocListener<EditContactBloc, EditContactState>(
              listener: (context, state) {
                final status = state.status;
                final requestType = state.requestType;

                if (requestType != RequestType.initial &&
                    status == EditContactStatus.loading) {
                  BotToast.showLoading();
                }

                if (status == EditContactStatus.failure) {
                  BotToast.closeAllLoading();

                  final failureReason = state.failureReason;
                  ScaffoldMessenger.of(context).showSnackBarText(
                    failureReason ?? context.l10n.unknownError,
                  );
                }

                if (requestType != RequestType.initial &&
                    status == EditContactStatus.success) {
                  BotToast.closeAllLoading();
                }
              },
              listenWhen: (previous, current) {
                return previous.status != current.status &&
                    current.status != EditContactStatus.initial;
              },
            ),
            BlocListener<EditContactBloc, EditContactState>(
                listener: (context, state) {
                  final contact = state.currentContact;

                  Navigator.pop(context);

                  if (contact != null) {
                    onDone(contact);
                  }
                },
                listenWhen: (previous, current) =>
                    previous != current && current.isDone),
            BlocListener<EditContactBloc, EditContactState>(
                listener: (context, state) {
                  // Remove current contact avatar from cache
                  final rawContactId = state.rawContactId;
                  if (null != rawContactId) {
                    CachedNetworkImage.evictFromCache(
                        "${DeviceConnectionManager.instance.rootURL}/stream/rawContactPhoto?id=$rawContactId");
                    onUploadPhotoDone(
                        context.read<EditContactBloc>().isNew, rawContactId);
                  }
                },
                listenWhen: (previous, current) =>
                    previous != current && current.isImageUploadDone)
          ],
          child: Center(
            child: Container(
              child: !isInitDone
                  ? _buildSpinkitView()
                  : _buildContentView(context),
              width: width,
              height: height,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black38,
                        offset: Offset(1, 0),
                        blurRadius: 1,
                        spreadRadius: 0)
                  ]),
            ),
          ),
        ));
  }

  Widget _buildContentView(BuildContext context) {
    final phoneFieldItems =
        context.select((EditContactBloc bloc) => bloc.state.currentPhoneItems);

    final emailFieldItems =
        context.select((EditContactBloc bloc) => bloc.state.currentEmailItems);

    final addressFieldItems = context
        .select((EditContactBloc bloc) => bloc.state.currentAddressItems);

    final imFieldItems =
        context.select((EditContactBloc bloc) => bloc.state.currentImItems);

    final relationFieldItems = context
        .select((EditContactBloc bloc) => bloc.state.currentRelationItems);

    final isNew = context.select((EditContactBloc bloc) => bloc.isNew);
    final title = !isNew ? context.l10n.editContact : context.l10n.addContact;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 40,
          color: Color(0xfff4f4f4),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff616161)))),
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close, color: Color(0xff616161)))
          ]),
        ),
        Divider(
          color: Color(0xffe0e0e0),
          height: 1.0,
          thickness: 1.0,
        ),
        Expanded(
            child: SingleChildScrollView(
          child: Padding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicInfoView(context),
                _buildFieldItem(
                    top: 10,
                    label: context.l10n.phoneLabel,
                    fieldItems: phoneFieldItems,
                    onInputChange: (index, value) {
                      _contactFieldValueChanged(
                          context, value, index, ContactFieldItemColumn.phone);
                    },
                    onAdd: (index, isAdd) {
                      context.read<EditContactBloc>().add(
                          ContactFieldItemColumnOperation(
                              isAdd, ContactFieldItemColumn.phone, index));
                    },
                    onTypeChange: (index, type) {
                      _onSelectedTypeChanged(
                          fieldItemColumn: ContactFieldItemColumn.phone,
                          context: context,
                          index: index,
                          type: type!);
                    }),
                _buildFieldItem(
                    top: 10,
                    label: context.l10n.emailLabel,
                    fieldItems: emailFieldItems,
                    onInputChange: (index, value) {
                      _contactFieldValueChanged(
                          context, value, index, ContactFieldItemColumn.email);
                    },
                    onAdd: (index, isAdd) {
                      context.read<EditContactBloc>().add(
                          ContactFieldItemColumnOperation(
                              isAdd, ContactFieldItemColumn.email, index));
                    },
                    onTypeChange: (index, type) {
                      _onSelectedTypeChanged(
                          fieldItemColumn: ContactFieldItemColumn.email,
                          context: context,
                          index: index,
                          type: type!);
                    }),
                _buildFieldItem(
                    top: 10,
                    label: context.l10n.imLabel,
                    fieldItems: imFieldItems,
                    onInputChange: (index, value) {
                      _contactFieldValueChanged(
                          context, value, index, ContactFieldItemColumn.im);
                    },
                    onAdd: (index, isAdd) {
                      context.read<EditContactBloc>().add(
                          ContactFieldItemColumnOperation(
                              isAdd, ContactFieldItemColumn.im, index));
                    },
                    onTypeChange: (index, type) {
                      _onSelectedTypeChanged(
                          fieldItemColumn: ContactFieldItemColumn.im,
                          context: context,
                          index: index,
                          type: type!);
                    }),
                _buildFieldItem(
                    top: 10,
                    label: context.l10n.addressLabel,
                    fieldItems: addressFieldItems,
                    onInputChange: (index, value) {
                      _contactFieldValueChanged(
                          context, value, index, ContactFieldItemColumn.email);
                    },
                    onAdd: (index, isAdd) {
                      context.read<EditContactBloc>().add(
                          ContactFieldItemColumnOperation(
                              isAdd, ContactFieldItemColumn.address, index));
                    },
                    onTypeChange: (index, type) {
                      _onSelectedTypeChanged(
                          fieldItemColumn: ContactFieldItemColumn.address,
                          context: context,
                          index: index,
                          type: type!);
                    }),
                _buildFieldItem(
                    top: 10,
                    label: context.l10n.relationLabel,
                    fieldItems: relationFieldItems,
                    onInputChange: (index, value) {
                      _contactFieldValueChanged(
                          context, value, index, ContactFieldItemColumn.email);
                    },
                    onAdd: (index, isAdd) {
                      context.read<EditContactBloc>().add(
                          ContactFieldItemColumnOperation(
                              isAdd, ContactFieldItemColumn.relation, index));
                    },
                    onTypeChange: (index, type) {
                      _onSelectedTypeChanged(
                          fieldItemColumn: ContactFieldItemColumn.relation,
                          context: context,
                          index: index,
                          type: type!);
                    }),
                _buildNoteView(context),
                _buildConfirmButtons(context)
              ],
            ),
            padding: EdgeInsets.only(bottom: 50, left: 25),
          ),
        ))
      ],
    );
  }

  void _contactFieldValueChanged(BuildContext context, String value, int index,
      ContactFieldItemColumn column) {
    context
        .read<EditContactBloc>()
        .add(ContactFieldValueChanged(column, index, value));
  }

  void _onSelectedTypeChanged(
      {required BuildContext context,
      required int index,
      required ContactFieldItemColumn fieldItemColumn,
      required ContactDataType type}) {
    if (type.isSystemCustomType) {
      showSingleInputDialog(
          context: context,
          title: context.l10n.addCategory,
          onConfirm: (value) {
            context
                .read<EditContactBloc>()
                .add(AddCustomDataType(fieldItemColumn, index, value));
          });
    } else {
      context
          .read<EditContactBloc>()
          .add(ContactDataTypeChanged(fieldItemColumn, type, index));
    }
  }

  Widget _buildSpinkitView() {
    return SpinKitCircle(color: Color(0xff85a8d0), size: 60.0);
  }

  Widget _buildBasicInfoView(BuildContext context) {
    final name = context.select((EditContactBloc bloc) => bloc.state.name);

    final accounts =
        context.select((EditContactBloc bloc) => bloc.state.accounts);
    final selectedAccount =
        context.select((EditContactBloc bloc) => bloc.state.selectedAccount);

    final groups = context.select((EditContactBloc bloc) => bloc.state.groups);
    final selectedGroup =
        context.select((EditContactBloc bloc) => bloc.state.selectedGroup);

    final isNew = context.select((EditContactBloc bloc) => bloc.isNew);

    final double inputBoxWidth = 200;

    return SizedBox(
      child: Padding(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAvatarView(
                context: context,
                onTap: () {
                  _selectImageAndUpload(context);
                }),
            Padding(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildLabelView(context.l10n.nameLabel),
                        _buildInputBox(
                            width: inputBoxWidth,
                            height: inputBoxHeight,
                            initialValue: name,
                            onChange: (value) {
                              context
                                  .read<EditContactBloc>()
                                  .add(NameValueChanged(value));
                            })
                      ],
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Row(children: [
                          _buildLabelView(context.l10n.singleAccountLabel),
                          isNew
                              ? _buildDropDownButton<Account>(
                                  width: inputBoxWidth,
                                  items:
                                      List.generate(accounts.length, (index) {
                                    final account = accounts[index];

                                    return DropdownMenuItem(
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          account.name,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                          // overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          softWrap: true,
                                        ),
                                      ),
                                      value: account,
                                    );
                                  }),
                                  value: selectedAccount,
                                  onChanged: (value) {
                                    context
                                        .read<EditContactBloc>()
                                        .add(SelectedAccountChanged(value));
                                  })
                              : Text(selectedAccount?.name ?? "",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black)),
                        ])),
                    Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Row(children: [
                          _buildLabelView(context.l10n.singleGroupLabel),
                          _buildDropDownButton<ContactGroup>(
                              width: inputBoxWidth,
                              items: List.generate(groups.length, (index) {
                                final group = groups[index];
                                return DropdownMenuItem(
                                    child: Padding(
                                      child: Text(group.title,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black)),
                                      padding: EdgeInsets.only(left: 10),
                                    ),
                                    value: group);
                              }),
                              value: selectedGroup,
                              onChanged: (value) {
                                context
                                    .read<EditContactBloc>()
                                    .add(SelectedGroupChanged(value));
                              })
                        ]))
                  ],
                ))
          ],
        ),
        padding: EdgeInsets.only(top: 20, left: 25, bottom: 20),
      ),
    );
  }

  Widget _buildLabelView(String label) {
    return Container(
      alignment: Alignment.centerRight,
      width: fieldLabelWidth,
      child:
          Text(label, style: TextStyle(fontSize: 14, color: Color(0xff474747))),
      padding: EdgeInsets.only(right: fieldLabelPaddingRight),
    );
  }

  void _selectImageAndUpload(BuildContext context) async {
    final result = await FilePicker.platform
        .pickFiles(dialogTitle: context.l10n.selectImage, type: FileType.image);
    if (null == result) {
      logger.e("Select image failed");
      return;
    }

    final paths = result.paths;

    if (paths.isEmpty) {
      logger.e("Select image failed");
      return;
    }

    final path = paths.first;

    if (null == path) {
      logger.e("Select image failed");
      return;
    }

    final file = File(path);
    context.read<EditContactBloc>().add(UploadPhotoRequested(file));
  }

  Widget _buildAvatarView(
      {required BuildContext context, required VoidCallback onTap}) {
    final imageSize = 120.0;

    final contactId =
        context.select((EditContactBloc bloc) => bloc.state.rawContactId) ?? -1;

    return ContactAvatarView(
        rawContactId: contactId,
        addTimestamp: true,
        width: imageSize,
        height: imageSize,
        iconSize: 50,
        onTap: onTap);
  }

  Widget _buildInputBox(
      {required double width,
      required double height,
      String? initialValue,
      required Function(String) onChange}) {
    return SizedBox(
      child: UnifiedTextField(
        style: TextStyle(fontSize: 14, color: Color(0xff333333)),
        initialValue: initialValue,
        hintText: "",
        borderRadius: 3,
        cursorColor: Color(0xff999999),
        cursorHeight: 15,
        onChange: (value) {
          onChange(value);
        },
      ),
      width: width,
      height: height,
    );
  }

  Widget _buildDropDownButton<T>(
      {required double width,
      required List<DropdownMenuItem<T>> items,
      T? value,
      void Function(T?)? onChanged}) {
    return Container(
      child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
        isExpanded: true,
        items: items,
        value: value,
        onChanged: onChanged,
        icon: Icon(Icons.arrow_drop_down),
        iconSize: 30,
        iconEnabledColor: Color(0xff8e9295),
        style: TextStyle(
            fontSize: 14, color: Colors.black, overflow: TextOverflow.ellipsis),
      )),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Color(0xffe4e4e4), width: 1)),
      height: inputBoxHeight,
      width: width,
    );
  }

  Widget _buildActionButton(
      {required bool isAdd, required Function(bool) onTap}) {
    return Container(
      alignment: Alignment.center,
      child: IconButton(
          padding: EdgeInsets.zero,
          iconSize: 20,
          onPressed: () {
            onTap(isAdd);
          },
          icon: isAdd
              ? Icon(Icons.add, color: Color(0xff8e9295))
              : Icon(Icons.remove, color: Color(0xff8e9295))),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: Colors.white,
          border: Border.all(color: Color(0xffe4e4e4), width: 1)),
      width: 30,
      height: 30,
    );
  }

  Widget _buildFieldItem(
      {double top = 0,
      required String label,
      required List<ContactFieldRow> fieldItems,
      required Function(int, ContactDataType?) onTypeChange,
      required Function(int, String) onInputChange,
      required Function(int, bool) onAdd}) {
    return Padding(
        padding: EdgeInsets.only(top: top),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: fieldLabelWidth,
              alignment: Alignment.centerRight,
              child: Text(label,
                  style: TextStyle(fontSize: 14, color: Color(0xff333333))),
              padding: EdgeInsets.only(right: fieldLabelPaddingRight),
            ),
            Column(
              children: List.generate(fieldItems.length, (index) {
                final fieldItem = fieldItems[index];

                return _buildFieldInputBox(
                    top: index > 0 ? 10 : 0,
                    initialValue: fieldItem.value,
                    isAdd: index < 1,
                    fieldItem: fieldItem,
                    types: fieldItem.types,
                    onTypeChange: (type) {
                      onTypeChange(index, type);
                    },
                    onInputChange: (value) {
                      onInputChange(index, value);
                    },
                    onAdd: (isAdd) {
                      onAdd(index, isAdd);
                    });
              }),
            )
          ],
        ));
  }

  Widget _buildFieldInputBox(
      {double top = 0,
      bool isAdd = false,
      String? initialValue,
      required ContactFieldRow fieldItem,
      required List<ContactDataType> types,
      required Function(ContactDataType?) onTypeChange,
      required Function(String) onInputChange,
      required Function(bool) onAdd}) {
    return Padding(
        padding: EdgeInsets.only(top: top),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropDownButton<ContactDataType>(
                width: 120,
                items: List.generate(types.length, (index) {
                  final type = types[index];

                  return DropdownMenuItem(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(type.typeLabel,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff333333),
                            )),
                      ),
                      value: type);
                }),
                value: fieldItem.selectedType,
                onChanged: (value) {
                  onTypeChange(value);
                }),
            Container(
              child: UnifiedTextField(
                initialValue: initialValue,
                style: TextStyle(fontSize: 14, color: Color(0xff333333)),
                hintText: "",
                borderRadius: 3,
                cursorColor: Color(0xff999999),
                cursorHeight: 15,
                onChange: (value) {
                  onInputChange(value);
                },
              ),
              width: 220,
              height: 30,
              margin: EdgeInsets.only(left: 10, right: 10),
            ),
            _buildActionButton(
                isAdd: isAdd,
                onTap: (value) {
                  onAdd(value);
                })
          ],
        ));
  }

  Widget _buildConfirmButtons(BuildContext context) {
    final name = context.watch<EditContactBloc>().state.name;

    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(context.l10n.cancel,
                style: TextStyle(color: Color(0xff2f3b42), fontSize: 14)),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Color(0xaaffffff);
                  } else if (states.contains(MaterialState.hovered)) {
                    return Color(0xeeffffff);
                  } else {
                    return Color(0xffffffff);
                  }
                }),
                fixedSize: MaterialStateProperty.all(Size(100, 30))),
          ),
          Padding(
              padding: EdgeInsets.only(left: 20),
              child: ElevatedButton(
                onPressed: name == null || name.isEmpty
                    ? null
                    : () {
                        context.read<EditContactBloc>().add(SubmitRequested());
                      },
                child: Text(context.l10n.sure,
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Color(0xaa097eff);
                      } else if (states.contains(MaterialState.hovered)) {
                        return Color(0xee097eff);
                      } else if (states.contains(MaterialState.disabled)) {
                        return Color(0x66097eff);
                      } else {
                        return Color(0xff097eff);
                      }
                    }),
                    fixedSize: MaterialStateProperty.all(Size(100, 30))),
              )),
        ],
      )),
    );
  }

  Widget _buildNoteView(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: fieldLabelWidth,
              alignment: Alignment.centerRight,
              child: Text(context.l10n.noteLabel,
                  style: TextStyle(fontSize: 14, color: Color(0xff333333))),
              padding: EdgeInsets.only(right: fieldLabelPaddingRight),
            ),
            SizedBox(
              child: UnifiedTextField(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
                maxLines: 10,
                contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                borderRadius: 3,
              ),
              width: 390,
              height: 100,
            )
          ],
        ));
  }
}
