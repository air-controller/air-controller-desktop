import 'dart:io';

import '../model/contact_basic_info.dart';
import '../model/contact_data_type_map.dart';
import '../model/contact_detail.dart';
import '../model/accounts_and_groups.dart';
import '../model/delete_contacts_request_entity.dart';
import '../model/new_contact_request_entity.dart';
import '../model/update_contact_request_entity.dart';
import 'aircontroller_client.dart';

class ContactRepository {
  final AirControllerClient client;

  ContactRepository({required AirControllerClient client})
      : this.client = client;

  Future<AccountsAndGroups> getContactAccounts() =>
      this.client.getContactAccounts();

  Future<List<ContactBasicInfo>> getAllContacts() =>
      this.client.getAllContacts();

  Future<List<ContactBasicInfo>> getContactsByAccount(
          String name, String type) =>
      this.client.getContactsByAccount(name, type);

  Future<List<ContactBasicInfo>> getContactsByGroupId(int id) =>
      this.client.getContactsByGroupId(id);

  Future<ContactDetail> getContactDetail(int id) =>
      this.client.getContactDetail(id);

  Future<ContactDataTypeMap> getContactDataTypes() =>
      this.client.getContactDataTypes();

  Future<ContactDetail> createNewContact(
          NewContactRequestEntity requestEntity) =>
      this.client.createNewContact(requestEntity);

  Future<ContactDetail> uploadPhotoAndNewContact(File photo) =>
      this.client.uploadPhotoAndNewContact(photo);

  Future<ContactDetail> updatePhotoForContact(
          {required File photo, required int contactId}) =>
      this.client.updatePhotoForContact(photo: photo, id: contactId);

  Future<void> updateNewContact(UpdateContactRequestEntity requestEntity) =>
      this.client.updateNewContact(requestEntity);

  Future<void> deleteRawContacts(DeleteContactsRequestEntity requestEntity) =>
      this.client.deleteRawContacts(requestEntity);
}
