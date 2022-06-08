import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'manage_contacts_page.dart';

class DataGridHolder {
  static ContactsDataSource? dataSource;

  static DataGridController? controller;

  static void dispose() {
    dataSource = null;
    controller = null;
  }
}
