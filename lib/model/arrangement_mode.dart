enum ArrangementMode {
  grid, groupByDay, groupByMonth
}

extension ArrangementModeX on ArrangementMode {
  static ArrangementMode convertToTab(int value) {
    try {
      return ArrangementMode.values.firstWhere((tab) => tab.index == value);
    } catch (e) {
      return ArrangementMode.grid;
    }
  }
}