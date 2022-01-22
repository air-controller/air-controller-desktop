
import 'package:mobile_assistant_client/model/UIModule.dart';

class BackBtnVisibility {
  bool visible;
  UIModule module;

  BackBtnVisibility(this.visible, {this.module = UIModule.Image});
}