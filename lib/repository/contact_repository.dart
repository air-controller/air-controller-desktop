import '../model/contact_basic_info.dart';
import '../model/contact_detail.dart';
import '../model/contact_summary_info.dart';
import 'aircontroller_client.dart';

class ContactRepository {
  final AirControllerClient client;

  ContactRepository({required AirControllerClient client})
      : this.client = client;

  Future<ContactSummaryInfo> getContactAccounts() =>
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
}
