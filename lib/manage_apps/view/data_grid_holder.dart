import 'package:air_controller/manage_apps/view/manage_apps_page.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DataGridHolder {
  static AppInfoDataSource? userAppsDataSource;

  static AppInfoDataSource? systemAppsDataSource;

  static DataGridController? userDataGridController;

  static DataGridController? systemDataGridController;

  static Map<AppInfoColumn, double> userTableColumnWidths = {
    AppInfoColumn.iconAndName: double.nan,
    AppInfoColumn.size: double.nan,
    AppInfoColumn.version: double.nan,
    AppInfoColumn.action: double.nan
  };

  static Map<AppInfoColumn, double> systemTableColumnWidths = {
    AppInfoColumn.iconAndName: double.nan,
    AppInfoColumn.size: double.nan,
    AppInfoColumn.version: double.nan,
    AppInfoColumn.action: double.nan
  };

  static void dispose() {
    userAppsDataSource = null;
    systemAppsDataSource = null;
    userDataGridController = null;
    systemDataGridController = null;
    userTableColumnWidths = {
      AppInfoColumn.iconAndName: double.nan,
      AppInfoColumn.size: double.nan,
      AppInfoColumn.version: double.nan,
      AppInfoColumn.action: double.nan
    };
    systemTableColumnWidths = {
      AppInfoColumn.iconAndName: double.nan,
      AppInfoColumn.size: double.nan,
      AppInfoColumn.version: double.nan,
      AppInfoColumn.action: double.nan
    };
  }
}
