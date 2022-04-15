import '../model/mobile_info.dart';
import 'aircontroller_client.dart';

class CommonRepository {
  final AirControllerClient client;

  CommonRepository({required AirControllerClient client}): this.client = client;

  Future<MobileInfo> getMobileInfo() => this.client.getMobileInfo();

}