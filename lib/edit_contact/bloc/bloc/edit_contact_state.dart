part of 'edit_contact_bloc.dart';

enum EditContactStatus { initial, loading, success, failure }

enum ContactFieldItemColumn { phone, email, im, address, relation }

enum RequestType { initial, createNewContact, updateContact, uploadPhoto }

enum EditMode { none, createNewContact, updateContact, photoUploadedWhenCreate }

class ContactFieldRow extends Equatable {
  final List<ContactDataType> types;
  final ContactDataType? selectedType;
  final int id;
  final String? value;

  ContactFieldRow(
      {required this.types, required this.id, this.selectedType, this.value});

  @override
  List<Object?> get props => [types, selectedType, value];

  ContactFieldRow copyWith({
    List<ContactDataType>? types,
    int? id,
    ContactDataType? selectedType,
    String? value,
  }) {
    return ContactFieldRow(
      types: types ?? this.types,
      id: id ?? this.id,
      selectedType: selectedType ?? this.selectedType,
      value: value ?? this.value,
    );
  }
}

class EditContactState extends Equatable {
  final String? failureReason;
  final EditContactStatus status;
  final List<Account> accounts;
  final List<ContactGroup> groups;
  final Account? selectedAccount;
  final ContactGroup? selectedGroup;
  final List<ContactFieldRow> currentPhoneItems;
  final List<ContactFieldRow> currentEmailItems;
  final List<ContactFieldRow> currentImItems;
  final List<ContactFieldRow> currentAddressItems;
  final List<ContactFieldRow> currentRelationItems;
  final String? name;
  final RequestType requestType;
  final String? note;
  final EditMode editMode;
  final int? rawContactId;
  final bool isInitDone;
  final bool isDone;
  final ContactBasicInfo? currentContact;
  final bool isImageUploadDone;

  const EditContactState(
      {this.failureReason,
      this.status = EditContactStatus.initial,
      this.accounts = const [],
      this.groups = const [],
      this.selectedAccount,
      this.selectedGroup,
      this.currentPhoneItems = const [],
      this.currentEmailItems = const [],
      this.currentImItems = const [],
      this.currentAddressItems = const [],
      this.currentRelationItems = const [],
      this.name,
      this.requestType = RequestType.initial,
      this.note,
      this.editMode = EditMode.none,
      this.rawContactId,
      this.isInitDone = false,
      this.isDone = false,
      this.currentContact,
      this.isImageUploadDone = false});

  @override
  List<Object?> get props => [
        failureReason,
        status,
        accounts,
        groups,
        selectedAccount,
        selectedGroup,
        currentPhoneItems,
        currentEmailItems,
        currentImItems,
        currentAddressItems,
        currentRelationItems,
        name,
        requestType,
        note,
        editMode,
        rawContactId,
        isInitDone,
        isDone,
        currentContact,
        isImageUploadDone,
      ];

  EditContactState copyWith(
      {String? failureReason,
      EditContactStatus? status,
      List<Account>? accounts,
      List<ContactGroup>? groups,
      Account? selectedAccount,
      ContactGroup? selectedGroup,
      List<ContactFieldRow>? currentPhoneItems,
      List<ContactFieldRow>? currentEmailItems,
      List<ContactFieldRow>? currentImItems,
      List<ContactFieldRow>? currentAddressItems,
      List<ContactFieldRow>? currentRelationItems,
      String? name,
      RequestType? requestType,
      String? note,
      EditMode? editMode,
      int? rawContactId,
      bool? isInitDone,
      bool? isDone,
      ContactBasicInfo? currentContact,
      bool? isImageUploadDone}) {
    return EditContactState(
      failureReason: failureReason ?? this.failureReason,
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      groups: groups ?? this.groups,
      selectedAccount: selectedAccount ?? this.selectedAccount,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      currentPhoneItems: currentPhoneItems ?? this.currentPhoneItems,
      currentEmailItems: currentEmailItems ?? this.currentEmailItems,
      currentImItems: currentImItems ?? this.currentImItems,
      currentAddressItems: currentAddressItems ?? this.currentAddressItems,
      currentRelationItems: currentRelationItems ?? this.currentRelationItems,
      name: name ?? this.name,
      requestType: requestType ?? this.requestType,
      note: note ?? this.note,
      editMode: editMode ?? this.editMode,
      rawContactId: rawContactId ?? this.rawContactId,
      isInitDone: isInitDone ?? this.isInitDone,
      isDone: isDone ?? this.isDone,
      currentContact: currentContact ?? this.currentContact,
      isImageUploadDone: isImageUploadDone ?? this.isImageUploadDone,
    );
  }
}
