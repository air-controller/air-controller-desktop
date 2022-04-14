
enum DisplayType { icon, list }

extension DisplayTypeX on DisplayType {
  static DisplayType convertToOderType(int index) {
    try {
      return DisplayType.values.firstWhere((orderType) => orderType.index == index);
    } catch (e) {
      return DisplayType.icon;
    }
  }
}
