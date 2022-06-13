import 'dart:async';

import 'package:air_controller/model/contact_account_info.dart';
import 'package:air_controller/model/contact_detail.dart';
import 'package:air_controller/model/contact_group.dart';
import 'package:air_controller/repository/aircontroller_client.dart';
import 'package:air_controller/repository/contact_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/contact_basic_info.dart';

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
    on<GetAllContactsRequested>(_onGetAllContactsRequested);
    on<SelectedContactsChanged>(_onSelectedContactChanged);
    on<GetContactDetailRequested>(_onGetContactDetailRequested);
    on<RefreshRequested>(_onRefreshRequested);
  }

  void _onSubscriptionRequested(ManageContactsSubscriptionRequested event,
      Emitter<ManageContactsState> emit) async {
    emit(state.copyWith(status: ManageContactsStatus.loading));
    try {
      final accounts = await _contactRepository.getContactAccounts();
      final allContacts = await _contactRepository.getAllContacts();

      emit(ManageContactsState(
          total: accounts.total,
          accounts: accounts.accounts,
          isAllContactsChecked: true,
          contacts: allContacts,
          isInitDone: true,
          status: ManageContactsStatus.success));
    } catch (e) {
      emit(ManageContactsState(
          failureReason: (e as BusinessError).message,
          status: ManageContactsStatus.failure));
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
      emit(state.copyWith(status: ManageContactsStatus.loading));

      try {
        final contacts = await _contactRepository.getContactsByAccount(
            checkedItem.account.name, checkedItem.account.type);

        emit(state.copyWith(
            contacts: contacts, status: ManageContactsStatus.success));
      } catch (e) {
        emit(state.copyWith(
            failureReason: (e as BusinessError).message,
            status: ManageContactsStatus.failure));
      }

      return;
    }

    if (checkedItem is ContactGroup) {
      emit(state.copyWith(status: ManageContactsStatus.loading));

      try {
        final contacts =
            await _contactRepository.getContactsByGroupId(checkedItem.id);

        emit(state.copyWith(
            contacts: contacts, status: ManageContactsStatus.success));
      } catch (e) {
        emit(state.copyWith(
            failureReason: (e as BusinessError).message,
            status: ManageContactsStatus.failure));
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
      emit(state.copyWith(status: ManageContactsStatus.loading));

      try {
        final contacts = await _contactRepository.getAllContacts();
        emit(state.copyWith(
            contacts: contacts, status: ManageContactsStatus.success));
      } catch (e) {
        emit(state.copyWith(
            failureReason: (e as BusinessError).message,
            status: ManageContactsStatus.failure));
      }
    }
  }

  void _onGetAllContactsRequested(
      GetAllContactsRequested event, Emitter<ManageContactsState> emit) {
    emit(state.copyWith(status: ManageContactsStatus.loading));
    _contactRepository.getAllContacts().then((contacts) {
      emit(ManageContactsState(
        contacts: contacts,
        status: ManageContactsStatus.success,
      ));
    }).catchError((e) {
      emit(ManageContactsState(
        failureReason: (e as BusinessError).message,
        status: ManageContactsStatus.failure,
      ));
    });
  }

  void _onSelectedContactChanged(
      SelectedContactsChanged event, Emitter<ManageContactsState> emit) async {
    emit(state.copyWith(selectedContacts: event.selectedContacts));
    if (event.selectedContacts.length == 1) {
      try {
        final contactDetail = await _contactRepository
            .getContactDetail(event.selectedContacts.single.id);
        emit(state.copyWith(contactDetail: contactDetail));
      } catch (e) {
        emit(state.copyWith(
            failureReason: (e as BusinessError).message,
            status: ManageContactsStatus.failure));
      }
    }
  }

  void _onGetContactDetailRequested(GetContactDetailRequested event,
      Emitter<ManageContactsState> emit) async {
    final contactDetail = await _contactRepository.getContactDetail(event.id);
    emit(state.copyWith(contactDetail: contactDetail));
  }

  void _onRefreshRequested(
      RefreshRequested event, Emitter<ManageContactsState> emit) async {
    emit(state.copyWith(status: ManageContactsStatus.loading));
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

      emit(state.copyWith(
          contacts: contacts, status: ManageContactsStatus.success));
    } catch (e) {
      emit(state.copyWith(
          failureReason: (e as BusinessError).message,
          status: ManageContactsStatus.failure));
    }
  }
}
