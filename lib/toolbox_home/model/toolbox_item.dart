enum ToolboxModule { manageApps, manageContacts }

class ToolboxItem {
  final ToolboxModule module;
  final String name;
  final String icon;

  const ToolboxItem(this.module, this.name, this.icon);
}
