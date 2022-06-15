part of 'manage_contacts_bloc.dart';

class ManageContactsEvent extends Equatable {
  const ManageContactsEvent();

  @override
  List<Object?> get props => [];
}

class ManageContactsSubscriptionRequested extends ManageContactsEvent {
  @override
  List<Object?> get props => [];
}

class ManageContactsExpandedStatusChanged extends ManageContactsEvent {
  final bool isExpanded;
  final ContactAccountInfo account;

  ManageContactsExpandedStatusChanged({
    required this.isExpanded,
    required this.account,
  });

  @override
  List<Object?> get props => [isExpanded, account];
}

class ManageContactsCheckedChanged extends ManageContactsEvent {
  final dynamic checkedItem;

  ManageContactsCheckedChanged(this.checkedItem);

  @override
  List<Object?> get props => [checkedItem];
}

class AllContactsExpandedStatusChanged extends ManageContactsEvent {
  final bool isAllContactsExpanded;

  AllContactsExpandedStatusChanged({
    required this.isAllContactsExpanded,
  });

  @override
  List<Object?> get props => [isAllContactsExpanded];
}

class AllContactsCheckedStatusChanged extends ManageContactsEvent {
  final bool isAllContactsChecked;

  AllContactsCheckedStatusChanged({
    required this.isAllContactsChecked,
  });

  @override
  List<Object?> get props => [isAllContactsChecked];
}

class SelectedContactsChanged extends ManageContactsEvent {
  final List<ContactBasicInfo> selectedContacts;

  SelectedContactsChanged(this.selectedContacts);

  @override
  List<Object?> get props => [selectedContacts];
}

class GetContactDetailRequested extends ManageContactsEvent {
  final int id;
  final bool isForEditting;
  final bool needLoading;

  GetContactDetailRequested(
      {required this.id,
      this.isForEditting = false,
      this.needLoading = true});

  @override
  List<Object?> get props => [id, isForEditting];
}

class RefreshRequested extends ManageContactsEvent {
  const RefreshRequested();
}

class KeywordChanged extends ManageContactsEvent {
  final String keyword;

  KeywordChanged(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class DeleteContactsRequested extends ManageContactsEvent {
  const DeleteContactsRequested();
}

class ManageContactsOpenContextMenu extends ManageContactsEvent {
  final Offset position;
  final ContactBasicInfo contact;

  ManageContactsOpenContextMenu({
    required this.position,
    required this.contact,
  });

  @override
  List<Object?> get props => [position, contact];
}
