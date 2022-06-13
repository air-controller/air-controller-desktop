import 'dart:async';
import 'dart:io';

import 'package:air_controller/model/account.dart';
import 'package:air_controller/model/contact_data_type.dart';
import 'package:air_controller/model/update_contact_request_entity.dart';
import 'package:air_controller/repository/aircontroller_client.dart';
import 'package:air_controller/repository/contact_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../bootstrap.dart';
import '../../../model/contact_account_info.dart';
import '../../../model/contact_detail.dart';
import '../../../model/contact_field_value.dart';
import '../../../model/contact_group.dart';
import '../../../model/new_contact_request_entity.dart';

part 'edit_contact_event.dart';
part 'edit_contact_state.dart';

class EditContactBloc extends Bloc<EditContactEvent, EditContactState> {
  final ContactRepository _contactRepository;
  final bool isNew;
  List<ContactAccountInfo> accountInfoList;
  final ContactDetail? contactDetail;

  EditContactBloc._(
      {required ContactRepository contactRepository,
      required this.isNew,
      required this.accountInfoList,
      this.contactDetail})
      : _contactRepository = contactRepository,
        super(EditContactState()) {
    on<SubscriptionRequested>(_onSubscriptionRequest);
    on<SelectedAccountChanged>(_onSelectedAccountChanged);
    on<SelectedGroupChanged>(_onSelectedGroupChanged);
    on<ContactFieldItemColumnOperation>(_onFieldItemColumnOperate);
    on<ContactDataTypeChanged>(_onContactDataTypeChanged);
    on<AddCustomDataType>(_onAddCustomDataType);
    on<NameValueChanged>(_onNameValueChanged);
    on<ContactFieldValueChanged>(_onContactFieldValueChanged);
    on<UploadPhotoRequested>(_onUploadPhotoRequested);
    on<SubmitRequested>(_onSubmitRequested);
  }

  static EditContactBloc newForNewContact(
      {required ContactRepository contactRepository,
      required List<ContactAccountInfo> accountInfoList}) {
    return EditContactBloc._(
        contactRepository: contactRepository,
        isNew: true,
        accountInfoList: accountInfoList);
  }

  static EditContactBloc newForEditContact(
      {required ContactRepository contactRepository,
      required ContactDetail? contactDetail,
      required List<ContactAccountInfo> accountInfoList}) {
    return EditContactBloc._(
        contactRepository: contactRepository,
        isNew: false,
        contactDetail: contactDetail,
        accountInfoList: accountInfoList);
  }

  void _onSubscriptionRequest(
      SubscriptionRequested event, Emitter<EditContactState> emit) async {
    emit(state.copyWith(
        requestType: RequestType.initial, status: EditContactStatus.loading));

    try {
      final contactDataTypes = await _contactRepository.getContactDataTypes();

      List<Account> accounts = [];
      List<ContactGroup> groups = [];
      Account? selectedAccount = null;
      ContactGroup? selectedGroup = null;

      if (isNew) {
        if (accountInfoList.isNotEmpty) {
          for (ContactAccountInfo accountInfo in accountInfoList) {
            accounts.add(accountInfo.account);
          }

          selectedAccount = accountInfoList.first.account;
          groups = accountInfoList.first.groups;
          selectedGroup = groups.isNotEmpty ? groups.first : null;
        }
      } else {
        if (contactDetail != null) {
          final currentAccounts = contactDetail?.accounts;
          if (null != currentAccounts && currentAccounts.isNotEmpty) {
            selectedAccount = currentAccounts.first;
          }

          final currentGroups = contactDetail?.groups;
          if (null != currentGroups && currentGroups.isNotEmpty) {
            selectedGroup = currentGroups.first;
          }
        }
      }

      List<ContactDataType> phoneTypes = contactDataTypes.phone;
      List<ContactFieldRow> currentPhoneItems = [];

      if (isNew) {
        currentPhoneItems.addAll(_createInitialFieldItem(phoneTypes));
      } else {
        contactDetail?.phones?.forEach((element) {
          currentPhoneItems.add(ContactFieldRow(
              types: phoneTypes,
              value: element.value,
              selectedType: element.type));
        });
        if (currentPhoneItems.isEmpty) {
          currentPhoneItems.addAll(_createInitialFieldItem(phoneTypes));
        }
      }

      List<ContactDataType> emailTypes = contactDataTypes.email;
      List<ContactFieldRow> currentEmailItems = [];

      if (isNew) {
        currentEmailItems.addAll(_createInitialFieldItem(emailTypes));
      } else {
        contactDetail?.emails?.forEach((element) {
          currentEmailItems.add(ContactFieldRow(
              types: emailTypes,
              value: element.value,
              selectedType: element.type));
        });

        if (currentEmailItems.isEmpty) {
          currentEmailItems.addAll(_createInitialFieldItem(emailTypes));
        }
      }

      List<ContactDataType> imTypes = contactDataTypes.im;
      List<ContactFieldRow> currentImItems = [];

      if (isNew) {
        currentImItems.addAll(_createInitialFieldItem(imTypes));
      } else {
        contactDetail?.ims?.forEach((element) {
          currentImItems.add(ContactFieldRow(
              types: imTypes,
              value: element.value,
              selectedType: element.type));
        });

        if (currentImItems.isEmpty) {
          currentImItems.addAll(_createInitialFieldItem(imTypes));
        }
      }

      List<ContactDataType> addressTypes = contactDataTypes.address;
      List<ContactFieldRow> currentAddressItems = [];

      if (isNew) {
        currentAddressItems.addAll(_createInitialFieldItem(addressTypes));
      } else {
        contactDetail?.addresses?.forEach((element) {
          currentAddressItems.add(ContactFieldRow(
              types: addressTypes,
              value: element.value,
              selectedType: element.type));
        });

        if (currentAddressItems.isEmpty) {
          currentAddressItems.addAll(_createInitialFieldItem(addressTypes));
        }
      }

      List<ContactDataType> relationTypes = contactDataTypes.relation;
      List<ContactFieldRow> currentRelationItems = [];

      if (isNew) {
        currentRelationItems.addAll(_createInitialFieldItem(relationTypes));
      } else {
        contactDetail?.relations?.forEach((element) {
          currentRelationItems.add(ContactFieldRow(
              types: relationTypes,
              value: element.value,
              selectedType: element.type));
        });

        if (currentRelationItems.isEmpty) {
          currentRelationItems.addAll(_createInitialFieldItem(relationTypes));
        }
      }

      String? note = null;

      if (!isNew) {
        note = contactDetail?.note?.note;
      }

      String? name = contactDetail?.displayNamePrimary;

      emit(state.copyWith(
          rawContactId: contactDetail?.id,
          name: name,
          status: EditContactStatus.success,
          accounts: accounts,
          groups: groups,
          selectedAccount: selectedAccount,
          selectedGroup: selectedGroup,
          currentPhoneItems: currentPhoneItems,
          currentEmailItems: currentEmailItems,
          currentImItems: currentImItems,
          currentAddressItems: currentAddressItems,
          currentRelationItems: currentRelationItems,
          note: note,
          editMode: isNew ? EditMode.createNewContact : EditMode.updateContact,
          isInitDone: true));
    } on BusinessError catch (e) {
      emit(state.copyWith(
          status: EditContactStatus.failure, failureReason: e.message));
    }
  }

  List<ContactFieldRow> _createInitialFieldItem(List<ContactDataType> types) {
    List<ContactFieldRow> fieldItems = [];

    if (types.isNotEmpty) {
      fieldItems.add(ContactFieldRow(types: types, selectedType: types.first));
    }

    return fieldItems;
  }

  void _onSelectedAccountChanged(
      SelectedAccountChanged event, Emitter<EditContactState> emit) {
    final selectedAccount = state.selectedAccount;

    if (event == selectedAccount) {
      return;
    }

    List<ContactGroup> groups = [];
    ContactGroup? selectedGroup = null;

    if (accountInfoList.isNotEmpty) {
      for (ContactAccountInfo accountInfo in accountInfoList) {
        if (accountInfo.account == event.account) {
          groups = accountInfo.groups;
          selectedGroup = groups.isNotEmpty ? groups.first : null;
          break;
        }
      }
    }

    emit(state.copyWith(
        selectedAccount: event.account,
        groups: groups,
        selectedGroup: selectedGroup));
  }

  void _onSelectedGroupChanged(
      SelectedGroupChanged event, Emitter<EditContactState> emit) {
    emit(state.copyWith(selectedGroup: event.group));
  }

  void _onFieldItemColumnOperate(
      ContactFieldItemColumnOperation event, Emitter<EditContactState> emit) {
    final fieldItemColumn = event.column;
    final isAdd = event.isAdd;
    final index = event.index;

    if (fieldItemColumn == ContactFieldItemColumn.phone) {
      final phoneFieldItems = [...state.currentPhoneItems];

      if (phoneFieldItems.isNotEmpty == true) {
        if (isAdd) {
          final firstPhoneFieldItem = phoneFieldItems.first;

          final types = [...firstPhoneFieldItem.types];
          ContactDataType? selctedType = firstPhoneFieldItem.selectedType;

          if (types.isNotEmpty) {
            final firstType = types.first;
            if (firstType.isUserCustomType) {
              types.removeAt(0);
            }

            selctedType = types.first;
          }
          phoneFieldItems.add(firstPhoneFieldItem.copyWith(
              types: types, selectedType: selctedType));

          emit(state.copyWith(currentPhoneItems: phoneFieldItems));
        } else {
          if (phoneFieldItems.length > index) {
            phoneFieldItems.removeAt(index);
            emit(state.copyWith(currentPhoneItems: phoneFieldItems));
          }
        }
      }
    } else if (fieldItemColumn == ContactFieldItemColumn.email) {
      final emailFieldItems = [...state.currentEmailItems];

      if (emailFieldItems.isNotEmpty == true) {
        if (isAdd) {
          final firstEmailFieldItem = emailFieldItems.first;

          final types = [...firstEmailFieldItem.types];
          ContactDataType? selctedType = firstEmailFieldItem.selectedType;

          if (types.isNotEmpty) {
            final firstType = types.first;
            if (firstType.isUserCustomType) {
              types.removeAt(0);
            }

            selctedType = types.first;
          }
          emailFieldItems.add(firstEmailFieldItem.copyWith(
              types: types, selectedType: selctedType));
          emit(state.copyWith(currentEmailItems: emailFieldItems));
        } else {
          if (emailFieldItems.length > index) {
            emailFieldItems.removeAt(index);
            emit(state.copyWith(currentEmailItems: emailFieldItems));
          }
        }
      }
    } else if (fieldItemColumn == ContactFieldItemColumn.im) {
      final imFieldItems = [...state.currentImItems];

      if (imFieldItems.isNotEmpty == true) {
        if (isAdd) {
          final firstImFieldItem = imFieldItems.first;

          final types = [...firstImFieldItem.types];
          ContactDataType? selctedType = firstImFieldItem.selectedType;

          if (types.isNotEmpty) {
            final firstType = types.first;
            if (firstType.isUserCustomType) {
              types.removeAt(0);
            }

            selctedType = types.first;
          }
          imFieldItems.add(firstImFieldItem.copyWith(
              types: types, selectedType: selctedType));
          emit(state.copyWith(currentImItems: imFieldItems));
        } else {
          if (imFieldItems.length > index) {
            imFieldItems.removeAt(index);
            emit(state.copyWith(currentImItems: imFieldItems));
          }
        }
      }
    } else if (fieldItemColumn == ContactFieldItemColumn.relation) {
      final relationFieldItems = [...state.currentRelationItems];

      if (relationFieldItems.isNotEmpty) {
        if (isAdd) {
          final firstRelationFieldItem = relationFieldItems.first;

          final types = [...firstRelationFieldItem.types];
          ContactDataType? selctedType = firstRelationFieldItem.selectedType;

          if (types.isNotEmpty) {
            final firstType = types.first;
            if (firstType.isUserCustomType) {
              types.removeAt(0);
            }

            selctedType = types.first;
          }
          relationFieldItems.add(firstRelationFieldItem.copyWith(
              types: types, selectedType: selctedType));
          emit(state.copyWith(currentRelationItems: relationFieldItems));
        } else {
          if (relationFieldItems.length > index) {
            relationFieldItems.removeAt(index);
            emit(state.copyWith(currentRelationItems: relationFieldItems));
          }
        }
      }
    }
  }

  void _onContactDataTypeChanged(
      ContactDataTypeChanged event, Emitter<EditContactState> emit) {
    final index = event.index;
    final fieldItemColumn = event.column;

    if (fieldItemColumn == ContactFieldItemColumn.phone) {
      final phoneFieldItems = [...state.currentPhoneItems];

      if (phoneFieldItems.length > index) {
        final phoneFieldItem = phoneFieldItems[index];
        final newPhoneFieldItem =
            phoneFieldItem.copyWith(selectedType: event.type);
        phoneFieldItems[index] = newPhoneFieldItem;

        emit(state.copyWith(currentPhoneItems: phoneFieldItems));
      }
    } else if (fieldItemColumn == ContactFieldItemColumn.email) {
      final emailFieldItems = [...state.currentEmailItems];

      if (emailFieldItems.length > index) {
        final emailFieldItem = emailFieldItems[index];
        final newEmailFieldItem =
            emailFieldItem.copyWith(selectedType: event.type);
        emailFieldItems[index] = newEmailFieldItem;

        emit(state.copyWith(currentEmailItems: emailFieldItems));
      }
    } else if (fieldItemColumn == ContactFieldItemColumn.im) {
      final imFieldItems = [...state.currentImItems];

      if (imFieldItems.length > index) {
        final imFieldItem = imFieldItems[index];
        final newImFieldItem = imFieldItem.copyWith(selectedType: event.type);
        imFieldItems[index] = newImFieldItem;

        emit(state.copyWith(currentImItems: imFieldItems));
      }
    } else if (fieldItemColumn == ContactFieldItemColumn.address) {
      final addressFieldItems = [...state.currentAddressItems];

      if (addressFieldItems.length > index) {
        final addressFieldItem = addressFieldItems[index];
        final newAddressFieldItem =
            addressFieldItem.copyWith(selectedType: event.type);
        addressFieldItems[index] = newAddressFieldItem;

        emit(state.copyWith(currentAddressItems: addressFieldItems));
      }
    } else if (fieldItemColumn == ContactFieldItemColumn.relation) {
      final relationFieldItems = [...state.currentRelationItems];

      if (relationFieldItems.length > index) {
        final relationFieldItem = relationFieldItems[index];
        final newRelationFieldItem =
            relationFieldItem.copyWith(selectedType: event.type);
        relationFieldItems[index] = newRelationFieldItem;

        emit(state.copyWith(currentRelationItems: relationFieldItems));
      }
    }
  }

  void _onAddCustomDataType(
      AddCustomDataType event, Emitter<EditContactState> emit) {
    final fieldItemColumn = event.column;

    if (fieldItemColumn == ContactFieldItemColumn.phone) {
      final customDataType = ContactDataType(-1, event.value, true, false);

      final phoneFieldItems = [...state.currentPhoneItems];

      final index = event.index;
      if (phoneFieldItems.length > index) {
        final phoneFieldItem = phoneFieldItems[index];

        final types = [...phoneFieldItem.types];

        final firstType = types.first;

        if (firstType.isUserCustomType) {
          types[0] = customDataType;
        } else {
          types.insert(0, customDataType);
        }

        final newPhoneFieldItem =
            phoneFieldItem.copyWith(selectedType: customDataType, types: types);
        phoneFieldItems[index] = newPhoneFieldItem;

        emit(state.copyWith(currentPhoneItems: phoneFieldItems));
      }
    } else if (fieldItemColumn == ContactFieldItemColumn.email) {
      final customDataType = ContactDataType(-1, event.value, true, false);

      final emailFieldItems = [...state.currentEmailItems];

      final index = event.index;
      if (emailFieldItems.length > index) {
        final emailFieldItem = emailFieldItems[index];

        final types = [...emailFieldItem.types];

        final firstType = types.first;

        if (firstType.isUserCustomType) {
          types[0] = customDataType;
        } else {
          types.insert(0, customDataType);
        }

        final newEmailFieldItem =
            emailFieldItem.copyWith(selectedType: customDataType, types: types);
        emailFieldItems[index] = newEmailFieldItem;

        emit(state.copyWith(currentEmailItems: emailFieldItems));
      }
    } else if (fieldItemColumn == ContactFieldItemColumn.im) {
      final customDataType = ContactDataType(-1, event.value, true, false);

      final imFieldItems = [...state.currentImItems];

      final index = event.index;
      if (imFieldItems.length > index) {
        final imFieldItem = imFieldItems[index];

        final types = [...imFieldItem.types];

        final firstType = types.first;

        if (firstType.isUserCustomType) {
          types[0] = customDataType;
        } else {
          types.insert(0, customDataType);
        }

        final newImFieldItem =
            imFieldItem.copyWith(selectedType: customDataType, types: types);
        imFieldItems[index] = newImFieldItem;

        emit(state.copyWith(currentImItems: imFieldItems));
      }
    } else if (fieldItemColumn == ContactFieldItemColumn.address) {
      final customDataType = ContactDataType(-1, event.value, true, false);

      final addressFieldItems = [...state.currentAddressItems];

      final index = event.index;
      if (addressFieldItems.length > index) {
        final addressFieldItem = addressFieldItems[index];

        final types = [...addressFieldItem.types];

        final firstType = types.first;

        if (firstType.isUserCustomType) {
          types[0] = customDataType;
        } else {
          types.insert(0, customDataType);
        }

        final newAddressFieldItem = addressFieldItem.copyWith(
            selectedType: customDataType, types: types);
        addressFieldItems[index] = newAddressFieldItem;

        emit(state.copyWith(currentAddressItems: addressFieldItems));
      }
    } else if (fieldItemColumn == ContactFieldItemColumn.relation) {
      final customDataType = ContactDataType(-1, event.value, true, false);

      final relationFieldItems = [...state.currentRelationItems];

      final index = event.index;
      if (relationFieldItems.length > index) {
        final relationFieldItem = relationFieldItems[index];

        final types = [...relationFieldItem.types];

        final firstType = types.first;

        if (firstType.isUserCustomType) {
          types[0] = customDataType;
        } else {
          types.insert(0, customDataType);
        }

        final newRelationFieldItem = relationFieldItem.copyWith(
            selectedType: customDataType, types: types);
        relationFieldItems[index] = newRelationFieldItem;

        emit(state.copyWith(currentRelationItems: relationFieldItems));
      }
    }
  }

  Future<void> _onCreateNewContact(Emitter<EditContactState> emit) async {
    final editMode = state.editMode;

    try {
      final name = state.name;

      if (null == name || name.isEmpty) {
        logger.e("EditContactBloc: name is empty!");
        return;
      }

      List<ContactFieldValue> phones = [];
      state.currentPhoneItems.forEach((phoneItem) {
        final value = phoneItem.value;

        if (null != value) {
          final contactFieldValue =
              ContactFieldValue(type: phoneItem.selectedType, value: value);
          phones.add(contactFieldValue);
        }
      });

      List<ContactFieldValue> emails = [];
      state.currentEmailItems.forEach((emailItem) {
        final value = emailItem.value;

        if (null != value) {
          final contactFieldValue =
              ContactFieldValue(type: emailItem.selectedType, value: value);
          emails.add(contactFieldValue);
        }
      });

      List<ContactFieldValue> ims = [];
      state.currentImItems.forEach((imItem) {
        final value = imItem.value;

        if (null != value) {
          final contactFieldValue =
              ContactFieldValue(type: imItem.selectedType, value: value);
          ims.add(contactFieldValue);
        }
      });

      List<ContactFieldValue> addresses = [];
      state.currentAddressItems.forEach((addressItem) {
        final value = addressItem.value;

        if (null != value) {
          final contactFieldValue =
              ContactFieldValue(type: addressItem.selectedType, value: value);
          addresses.add(contactFieldValue);
        }
      });

      List<ContactFieldValue> relations = [];
      state.currentRelationItems.forEach((relationItem) {
        final value = relationItem.value;

        if (null != value) {
          final contactFieldValue =
              ContactFieldValue(type: relationItem.selectedType, value: value);
          relations.add(contactFieldValue);
        }
      });

      final note = state.note;

      final account = state.selectedAccount;
      final group = state.selectedGroup;

      emit(state.copyWith(
          status: EditContactStatus.loading,
          requestType: RequestType.createNewContact));

      if (editMode == EditMode.createNewContact) {
        final request = NewContactRequestEntity(
            name: name,
            phones: phones,
            emails: emails,
            ims: ims,
            addresses: addresses,
            relations: relations,
            account: account,
            group: group,
            note: note);
        await _contactRepository.createNewContact(request);
        emit(state.copyWith(
            status: EditContactStatus.success,
            requestType: RequestType.createNewContact));
      } else if (editMode == EditMode.photoUploadedWhenCreate) {
        final rawContactId = state.rawContactId;
        final request = UpdateContactRequestEntity(
            id: rawContactId!,
            name: name,
            phones: phones,
            emails: emails,
            ims: ims,
            addresses: addresses,
            relations: relations,
            account: account,
            group: group,
            note: note);
        await _contactRepository.updateNewContact(request);
        emit(state.copyWith(
            status: EditContactStatus.success,
            requestType: RequestType.updateContact));
      }
    } on BusinessError catch (e) {
      if (editMode == EditMode.createNewContact) {
        emit(state.copyWith(
            status: EditContactStatus.failure,
            requestType: RequestType.createNewContact,
            failureReason: e.message));
      } else if (editMode == EditMode.photoUploadedWhenCreate) {
        emit(state.copyWith(
            status: EditContactStatus.failure,
            requestType: RequestType.updateContact,
            failureReason: e.message));
      }
    }
  }

  void _onNameValueChanged(
      NameValueChanged event, Emitter<EditContactState> emit) {
    emit(state.copyWith(name: event.value));
  }

  void _onContactFieldValueChanged(
      ContactFieldValueChanged event, Emitter<EditContactState> emit) {
    final fieldItemColumn = event.column;

    if (fieldItemColumn == ContactFieldItemColumn.phone) {
      final phoneFieldItems = [...state.currentPhoneItems];

      final index = event.index;
      if (phoneFieldItems.length > index) {
        final phoneFieldItem = phoneFieldItems[index];

        final newPhoneFieldItem = phoneFieldItem.copyWith(value: event.value);
        phoneFieldItems[index] = newPhoneFieldItem;

        emit(state.copyWith(currentPhoneItems: phoneFieldItems));
      }
    } else if (fieldItemColumn == ContactFieldItemColumn.email) {
      final emailFieldItems = [...state.currentEmailItems];

      final index = event.index;
      if (emailFieldItems.length > index) {
        final emailFieldItem = emailFieldItems[index];

        final newEmailFieldItem = emailFieldItem.copyWith(value: event.value);
        emailFieldItems[index] = newEmailFieldItem;

        emit(state.copyWith(currentEmailItems: emailFieldItems));
      }
    } else if (fieldItemColumn == ContactFieldItemColumn.im) {
      final imFieldItems = [...state.currentImItems];

      final index = event.index;
      if (imFieldItems.length > index) {
        final imFieldItem = imFieldItems[index];

        final newImFieldItem = imFieldItem.copyWith(value: event.value);
        imFieldItems[index] = newImFieldItem;

        emit(state.copyWith(currentImItems: imFieldItems));
      }
    } else if (fieldItemColumn == ContactFieldItemColumn.address) {
      final addressFieldItems = [...state.currentAddressItems];

      final index = event.index;
      if (addressFieldItems.length > index) {
        final addressFieldItem = addressFieldItems[index];

        final newAddressFieldItem =
            addressFieldItem.copyWith(value: event.value);
        addressFieldItems[index] = newAddressFieldItem;

        emit(state.copyWith(currentAddressItems: addressFieldItems));
      }
    } else if (fieldItemColumn == ContactFieldItemColumn.relation) {
      final relationFieldItems = [...state.currentRelationItems];

      final index = event.index;
      if (relationFieldItems.length > index) {
        final relationFieldItem = relationFieldItems[index];

        final newRelationFieldItem =
            relationFieldItem.copyWith(value: event.value);
        relationFieldItems[index] = newRelationFieldItem;

        emit(state.copyWith(currentRelationItems: relationFieldItems));
      }
    }
  }

  void _onUploadPhotoRequested(
      UploadPhotoRequested event, Emitter<EditContactState> emit) async {
    try {
      if (isNew) {
        final editMode = state.editMode;

        if (editMode == EditMode.photoUploadedWhenCreate) {
          final contactId = state.rawContactId;

          if (null == contactId) {
            logger.e(
                "Wrong state, contactId is null on EditMode.photoUploadedWhenCreate");
            return;
          }

          emit(state.copyWith(
            status: EditContactStatus.loading,
            requestType: RequestType.uploadPhoto,
          ));
          final photo = event.photo;
          final newContactDetail =
              await _contactRepository.updatePhotoForContact(
            photo: photo,
            contactId: contactId,
          );
          emit(state.copyWith(
              rawContactId: newContactDetail.id,
              status: EditContactStatus.success,
              requestType: RequestType.uploadPhoto));
        } else {
          emit(state.copyWith(
            status: EditContactStatus.loading,
            requestType: RequestType.uploadPhoto,
          ));
          final photo = event.photo;
          final contactDetail =
              await _contactRepository.uploadPhotoAndNewContact(photo);

          emit(state.copyWith(
              status: EditContactStatus.success,
              requestType: RequestType.uploadPhoto,
              name: contactDetail.displayNamePrimary,
              rawContactId: contactDetail.id,
              editMode: EditMode.photoUploadedWhenCreate));
        }
      } else {
        final contactId = state.rawContactId;

        if (null == contactId) {
          logger.e("Wrong state, contactId is null when update photo");
          return;
        }

        emit(state.copyWith(
          status: EditContactStatus.loading,
          requestType: RequestType.uploadPhoto,
        ));

        final photo = event.photo;
        final newContactDetail = await _contactRepository.updatePhotoForContact(
            photo: photo, contactId: contactId);

        emit(state.copyWith(
            status: EditContactStatus.success,
            requestType: RequestType.uploadPhoto,
            rawContactId: newContactDetail.id));
      }
    } on BusinessError catch (e) {
      emit(state.copyWith(
          status: EditContactStatus.failure,
          requestType: RequestType.uploadPhoto,
          failureReason: e.message));
    }
  }

  Future<void> _onUpdateContactRequested(Emitter<EditContactState> emit) async {
    final contactId = state.rawContactId;

    if (null == contactId) {
      logger.e("Wrong state, contactId is null when update contact");
      return;
    }

    try {
      final name = state.name;

      if (null == name || name.isEmpty) {
        logger.e("EditContactBloc: name is empty!");
        return;
      }

      List<ContactFieldValue> phones = [];
      state.currentPhoneItems.forEach((phoneItem) {
        final value = phoneItem.value;

        if (null != value) {
          final contactFieldValue =
              ContactFieldValue(type: phoneItem.selectedType, value: value);
          phones.add(contactFieldValue);
        }
      });

      List<ContactFieldValue> emails = [];
      state.currentEmailItems.forEach((emailItem) {
        final value = emailItem.value;

        if (null != value) {
          final contactFieldValue =
              ContactFieldValue(type: emailItem.selectedType, value: value);
          emails.add(contactFieldValue);
        }
      });

      List<ContactFieldValue> ims = [];
      state.currentImItems.forEach((imItem) {
        final value = imItem.value;

        if (null != value) {
          final contactFieldValue =
              ContactFieldValue(type: imItem.selectedType, value: value);
          ims.add(contactFieldValue);
        }
      });

      List<ContactFieldValue> addresses = [];
      state.currentAddressItems.forEach((addressItem) {
        final value = addressItem.value;

        if (null != value) {
          final contactFieldValue =
              ContactFieldValue(type: addressItem.selectedType, value: value);
          addresses.add(contactFieldValue);
        }
      });

      List<ContactFieldValue> relations = [];
      state.currentRelationItems.forEach((relationItem) {
        final value = relationItem.value;

        if (null != value) {
          final contactFieldValue =
              ContactFieldValue(type: relationItem.selectedType, value: value);
          relations.add(contactFieldValue);
        }
      });

      final note = state.note;

      final account = state.selectedAccount;
      final group = state.selectedGroup;

      emit(state.copyWith(
          status: EditContactStatus.loading,
          requestType: RequestType.updateContact));

      final request = UpdateContactRequestEntity(
          id: state.rawContactId!,
          name: name,
          phones: phones,
          emails: emails,
          ims: ims,
          addresses: addresses,
          relations: relations,
          account: account,
          group: group,
          note: note);
      await _contactRepository.updateNewContact(request);
      emit(state.copyWith(
          status: EditContactStatus.success,
          requestType: RequestType.updateContact));
    } on BusinessError catch (e) {
      emit(state.copyWith(
          status: EditContactStatus.failure,
          requestType: RequestType.updateContact,
          failureReason: e.message));
    }
  }

  void _onSubmitRequested(
      SubmitRequested event, Emitter<EditContactState> emit) async {
    if (isNew) {
      await _onCreateNewContact(emit);
    } else {
      await _onUpdateContactRequested(emit);
    }
  }
}
