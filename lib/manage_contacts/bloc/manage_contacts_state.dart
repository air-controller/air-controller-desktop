part of 'manage_contacts_bloc.dart';

class ManageContactsContextMenuInfo extends Equatable {
  final Offset position;
  final ContactBasicInfo contact;

  ManageContactsContextMenuInfo({
    required this.position,
    required this.contact,
  });

  @override
  List<Object?> get props => [position, contact];
}

class ManageContactsState extends Equatable {
  final int total;
  final List<ContactAccountInfo> accounts;
  final String? failureReason;
  final List<ContactAccountInfo> expandedAccounts;
  final dynamic checkedItem;
  final bool isAllContactsExpanded;
  final bool isAllContactsChecked;
  final List<ContactBasicInfo> contacts;
  final List<ContactBasicInfo> selectedContacts;
  final ContactDetail? contactDetail;
  final bool isInitDone;
  final String keyword;
  final ManageContactsContextMenuInfo? contextMenuInfo;
  final bool showLoading;
  final bool showError;
  final bool openEditDialog;

  const ManageContactsState(
      {this.total = 0,
      this.accounts = const [],
      this.failureReason,
      this.expandedAccounts = const [],
      this.checkedItem,
      this.isAllContactsExpanded = false,
      this.isAllContactsChecked = false,
      this.contacts = const [],
      this.selectedContacts = const [],
      this.contactDetail,
      this.isInitDone = false,
      this.keyword = '',
      this.contextMenuInfo,
      this.showLoading = false,
      this.showError = false,
      this.openEditDialog = false});

  @override
  List<Object?> get props => [
        total,
        accounts,
        failureReason,
        expandedAccounts,
        checkedItem,
        isAllContactsExpanded,
        isAllContactsChecked,
        contacts,
        selectedContacts,
        contactDetail,
        isInitDone,
        keyword,
        contextMenuInfo,
        showLoading,
        showError,
        openEditDialog
      ];

  ManageContactsState copyWith({
    int? total,
    List<ContactAccountInfo>? accounts,
    String? failureReason,
    List<ContactAccountInfo>? expandedAccounts,
    dynamic checkedItem,
    bool? isAllContactsExpanded,
    bool? isAllContactsChecked,
    List<ContactBasicInfo>? contacts,
    List<ContactBasicInfo>? selectedContacts,
    ContactDetail? contactDetail,
    bool? isInitDone,
    String? keyword,
    ManageContactsContextMenuInfo? contextMenuInfo,
    bool? showLoading,
    bool? showError,
    bool? openEditDialog,
  }) {
    return ManageContactsState(
        total: total ?? this.total,
        accounts: accounts ?? this.accounts,
        failureReason: failureReason ?? this.failureReason,
        expandedAccounts: expandedAccounts ?? this.expandedAccounts,
        checkedItem: checkedItem ?? this.checkedItem,
        isAllContactsExpanded:
            isAllContactsExpanded ?? this.isAllContactsExpanded,
        isAllContactsChecked: isAllContactsChecked ?? this.isAllContactsChecked,
        contacts: contacts ?? this.contacts,
        selectedContacts: selectedContacts ?? this.selectedContacts,
        contactDetail: contactDetail ?? this.contactDetail,
        isInitDone: isInitDone ?? this.isInitDone,
        keyword: keyword ?? this.keyword,
        contextMenuInfo: contextMenuInfo ?? this.contextMenuInfo,
        showLoading: showLoading ?? this.showLoading,
        showError: showError ?? this.showError,
        openEditDialog: openEditDialog ?? this.openEditDialog);
  }
}
