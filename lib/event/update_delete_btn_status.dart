
import 'package:mobile_assistant_client/model/UIModule.dart';

class UpdateDeleteBtnStatus {
  bool isEnable;
  UIModule module;

  UpdateDeleteBtnStatus(this.isEnable, {this.module = UIModule.Image});
}