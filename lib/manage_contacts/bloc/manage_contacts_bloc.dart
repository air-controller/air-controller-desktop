import 'dart:async';

import 'package:air_controller/model/contact_account_info.dart';
import 'package:air_controller/model/contact_detail.dart';
import 'package:air_controller/model/contact_group.dart';
import 'package:air_controller/model/delete_contacts_request_entity.dart';
import 'package:air_controller/repository/aircontroller_client.dart';
import 'package:air_controller/repository/contact_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/contact_basic_info.dart';
import '../view/data_grid_holder.dart';

part 'manage_contacts_event.dart';
part 'manage_contacts_state.dart';

class ManageContactsBloc
    extends Bloc<ManageContactsEvent, ManageContactsState> {
  final ContactRepository _contactRepository;

  ManageContactsBloc({
    required ContactRepository contactRepository,
  })  : _contactRepository = contactRepository,
        super(ManageContactsState()) {
    on<ManageContactsSubscriptionRequested>(_onSubscriptionRequested);
    on<ManageContactsExpandedStatusChanged>(_onExpanedStatusChanged);
    on<ManageContactsCheckedChanged>(_onCheckedChanged);
    on<AllContactsExpandedStatusChanged>(_onAllContactsExpanded);
    on<AllContactsCheckedStatusChanged>(_onAllContactsCheckedStatusChanged);
    on<SelectedContactsChanged>(_onSelectedContactChanged);
    on<GetContactDetailRequested>(_onGetContactDetailRequested);
    on<RefreshRequested>(_onRefreshRequested);
    on<KeywordChanged>(_onKeywordChanged);
    on<DeleteContactsRequested>(_onDeleteContactsRequested);
    on<ManageContactsOpenContextMenu>(_onOpenContextMenu);
    on<ManageContactsEditDone>(_onEditDone);
  }

  void _onSubscriptionRequested(ManageContactsSubscriptionRequested event,
      Emitter<ManageContactsState> emit) async {
    try {
      final accounts = await _contactRepository.getContactAccounts();
      final allContacts = await _contactRepository.getAllContacts();

      emit(ManageContactsState(
          accounts: accounts.accounts,
          isAllContactsChecked: true,
          contacts: allContacts,
          isInitDone: true));
    } catch (e) {
      emit(ManageContactsState(
          failureReason: (e as BusinessError).message, showError: true));
      emit(state.copyWith(showError: false));
    }
  }

  void _onExpanedStatusChanged(ManageContactsExpandedStatusChanged event,
      Emitter<ManageContactsState> emit) {
    final newState = state.copyWith(
      expandedAccounts: event.isExpanded
          ? state.expandedAccounts + [event.account]
          : state.expandedAccounts
              .where((account) => account != event.account)
              .toList(),
    );
    emit(newState);
  }

  void _onCheckedChanged(ManageContactsCheckedChanged event,
      Emitter<ManageContactsState> emit) async {
    final checkedItem = event.checkedItem;

    emit(state.copyWith(
        checkedItem: event.checkedItem, isAllContactsChecked: false));

    if (checkedItem is ContactAccountInfo) {
      emit(state.copyWith(showSpinkit: true));

      try {
        final contacts = await _contactRepository.getContactsByAccount(
            checkedItem.account.name, checkedItem.account.type);

        emit(state.copyWith(contacts: contacts, showSpinkit: false));
      } catch (e) {
        emit(state.copyWith(
            failureReason: (e as BusinessError).message, showError: true));
        emit(state.copyWith(showError: false));
      }

      return;
    }

    if (checkedItem is ContactGroup) {
      emit(state.copyWith(showSpinkit: true));

      try {
        final contacts =
            await _contactRepository.getContactsByGroupId(checkedItem.id);

        emit(state.copyWith(contacts: contacts, showSpinkit: false));
      } catch (e) {
        emit(state.copyWith(
            failureReason: (e as BusinessError).message, showError: true));
        emit(state.copyWith(showError: false));
      }

      return;
    }
  }

  void _onAllContactsExpanded(AllContactsExpandedStatusChanged event,
      Emitter<ManageContactsState> emit) {
    final newState = state.copyWith(
      isAllContactsExpanded: !state.isAllContactsExpanded,
    );

    emit(newState);
  }

  void _onAllContactsCheckedStatusChanged(AllContactsCheckedStatusChanged event,
      Emitter<ManageContactsState> emit) async {
    final newState = state.copyWith(
      isAllContactsChecked: event.isAllContactsChecked,
    );

    emit(newState);

    if (event.isAllContactsChecked) {
      emit(state.copyWith(showSpinkit: true));

      try {
        final contacts = await _contactRepository.getAllContacts();
        emit(state.copyWith(contacts: contacts, showSpinkit: false));
      } catch (e) {
        emit(state.copyWith(
            failureReason: (e as BusinessError).message,
            showSpinkit: false,
            showError: true));
        emit(state.copyWith(showError: false));
      }
    }
  }

  void _onSelectedContactChanged(
      SelectedContactsChanged event, Emitter<ManageContactsState> emit) async {
    emit(state.copyWith(selectedContacts: event.selectedContacts));
  }

  void _onGetContactDetailRequested(GetContactDetailRequested event,
      Emitter<ManageContactsState> emit) async {
    emit(state.copyWith(showLoading: event.needLoading));
    try {
      final contactDetail = await _contactRepository.getContactDetail(event.id);
      emit(state.copyWith(
          showLoading: false,
          openEditDialog: event.isForEditting,
          contactDetail: contactDetail));
      emit(state.copyWith(openEditDialog: false));
    } on BusinessError catch (e) {
      emit(state.copyWith(
          showLoading: false, showError: true, failureReason: e.message));
      emit(state.copyWith(showError: false));
    }
  }

  void _onRefreshRequested(
      RefreshRequested event, Emitter<ManageContactsState> emit) async {
    emit(state.copyWith(showSpinkit: true));
    try {
      final isAllContactsChecked = state.isAllContactsChecked;
      List<ContactBasicInfo> contacts = [];

      if (isAllContactsChecked) {
        final allContacts = await _contactRepository.getAllContacts();
        contacts.addAll(allContacts);
      } else {
        final checkedItem = state.checkedItem;
        if (checkedItem is ContactAccountInfo) {
          final newContacts = await _contactRepository.getContactsByAccount(
              checkedItem.account.name, checkedItem.account.type);
          contacts.addAll(newContacts);
        } else if (checkedItem is ContactGroup) {
          final newContacts =
              await _contactRepository.getContactsByGroupId(checkedItem.id);
          contacts.addAll(newContacts);
        }
      }

      emit(state.copyWith(contacts: contacts, showSpinkit: false));
    } catch (e) {
      emit(state.copyWith(
          failureReason: (e as BusinessError).message,
          showSpinkit: false,
          showError: true));
      emit(state.copyWith(showError: false));
    }
  }

  void _onKeywordChanged(
      KeywordChanged event, Emitter<ManageContactsState> emit) {
    emit(state.copyWith(keyword: event.keyword));
  }

  void _onDeleteContactsRequested(
      DeleteContactsRequested event, Emitter<ManageContactsState> emit) async {
    emit(state.copyWith(showLoading: true));

    try {
      final selectedContacts = state.selectedContacts;
      final ids = selectedContacts.map((contact) => contact.id).toList();
      await _contactRepository
          .deleteRawContacts(DeleteContactsRequestEntity(ids));

      final contacts = [...state.contacts];
      contacts.removeWhere((contact) => selectedContacts.contains(contact));

      emit(state.copyWith(
          contacts: contacts, selectedContacts: [], showLoading: false));
    } on BusinessError catch (e) {
      emit(state.copyWith(
          showLoading: false, showError: true, failureReason: e.message));
      emit(state.copyWith(showError: false));
    }
  }

  @override
  Future<void> close() {
    DataGridHolder.dispose();
    return super.close();
  }

  void _onOpenContextMenu(ManageContactsOpenContextMenu event,
      Emitter<ManageContactsState> emit) async {
    final contact = event.contact;
    final selectedContacts = [...state.selectedContacts];
    final contactDetail = await _contactRepository.getContactDetail(contact.id);

    if (!selectedContacts.contains(contact)) {
      selectedContacts.add(contact);

      emit(state.copyWith(
          contextMenuInfo: ManageContactsContextMenuInfo(
            position: event.position,
            contact: event.contact,
          ),
          selectedContacts: selectedContacts,
          contactDetail: contactDetail));
    } else {
      emit(state.copyWith(
          contextMenuInfo: ManageContactsContextMenuInfo(
            position: event.position,
            contact: event.contact,
          ),
          contactDetail: contactDetail));
    }
  }

  void _onEditDone(
      ManageContactsEditDone event, Emitter<ManageContactsState> emit) async {
    final contacts = [...state.contacts];

    final contact = event.contact;
    if (contacts.contains(contact)) {
      int index = contacts.indexOf(contact);

      if (index != -1) {
        contacts[index] = event.contact;
      }
    } else {
      contacts.add(event.contact);
    }

    ContactDetail? contactDetail = state.contactDetail;

    if (null != contactDetail && contactDetail.id == contact.id) {
      try {
        contactDetail = await _contactRepository.getContactDetail(contact.id);
      } on BusinessError catch (e) {
        emit(state.copyWith(
            showLoading: false, showError: true, failureReason: e.message));
        emit(state.copyWith(showError: false));
      }
    }

    emit(state.copyWith(contacts: contacts, contactDetail: contactDetail));
  }
}
