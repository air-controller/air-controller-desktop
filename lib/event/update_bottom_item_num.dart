
import 'package:mobile_assistant_client/model/UIModule.dart';

class UpdateBottomItemNum {
  UIModule module;
  int totalNum;
  int selectedNum;

  UpdateBottomItemNum(this.totalNum, this.selectedNum, {this.module = UIModule.Image});
}