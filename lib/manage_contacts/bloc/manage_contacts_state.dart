part of 'manage_contacts_bloc.dart';

enum ManageContactsStatus { initial, loading, success, failure }

class ManageContactsState extends Equatable {
  final int total;
  final List<ContactAccountInfo> accounts;
  final String? failureReason;
  final ManageContactsStatus status;
  final List<ContactAccountInfo> expandedAccounts;
  final dynamic checkedItem;
  final bool isAllContactsExpanded;
  final bool isAllContactsChecked;
  final List<ContactBasicInfo> contacts;
  final List<ContactBasicInfo> selectedContacts;
  final ContactDetail? contactDetail;

  const ManageContactsState(
      {this.total = 0,
      this.accounts = const [],
      this.failureReason,
      this.status = ManageContactsStatus.initial,
      this.expandedAccounts = const [],
      this.checkedItem,
      this.isAllContactsExpanded = false,
      this.isAllContactsChecked = false,
      this.contacts = const [],
      this.selectedContacts = const [],
      this.contactDetail});

  @override
  List<Object?> get props => [
        total,
        accounts,
        failureReason,
        status,
        expandedAccounts,
        checkedItem,
        isAllContactsExpanded,
        isAllContactsChecked,
        contacts,
        selectedContacts,
        contactDetail
      ];

  ManageContactsState copyWith({
    int? total,
    List<ContactAccountInfo>? accounts,
    String? failureReason,
    ManageContactsStatus? status,
    List<ContactAccountInfo>? expandedAccounts,
    dynamic checkedItem,
    bool? isAllContactsExpanded,
    bool? isAllContactsChecked,
    List<ContactBasicInfo>? contacts,
    List<ContactBasicInfo>? selectedContacts,
    ContactDetail? contactDetail,
  }) {
    return ManageContactsState(
        total: total ?? this.total,
        accounts: accounts ?? this.accounts,
        failureReason: failureReason ?? this.failureReason,
        status: status ?? this.status,
        expandedAccounts: expandedAccounts ?? this.expandedAccounts,
        checkedItem: checkedItem ?? this.checkedItem,
        isAllContactsExpanded:
            isAllContactsExpanded ?? this.isAllContactsExpanded,
        isAllContactsChecked: isAllContactsChecked ?? this.isAllContactsChecked,
        contacts: contacts ?? this.contacts,
        selectedContacts: selectedContacts ?? this.selectedContacts,
        contactDetail: contactDetail ?? this.contactDetail);
  }
}
