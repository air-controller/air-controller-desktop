
enum VideoOrderType { createTime, duration }

extension VideoOrderTypeX on VideoOrderType {
  static VideoOrderType convertToOderType(int index) {
    try {
      return VideoOrderType.values.firstWhere((orderType) => orderType.index == index);
    } catch (e) {
      return VideoOrderType.createTime;
    }
  }
}
