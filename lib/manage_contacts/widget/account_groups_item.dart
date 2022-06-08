import 'package:air_controller/model/contact_account_info.dart';
import 'package:air_controller/model/contact_group.dart';
import 'package:flutter/material.dart';

class AccountGroupsItem extends StatelessWidget {
  final double width;
  final bool isAccountChecked;
  final ContactGroup? checkedGroup;
  final bool isExpanded;
  final ContactAccountInfo accountInfo;
  final Function(ContactAccountInfo)? onAccountTap;
  final Function(ContactGroup)? onGroupTap;
  final Function(bool)? onExpandTap;

  const AccountGroupsItem(
      {Key? key,
      this.width = double.infinity,
      this.isAccountChecked = false,
      this.checkedGroup,
      this.isExpanded = false,
      required this.accountInfo,
      this.onAccountTap,
      this.onGroupTap,
      this.onExpandTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final groups = accountInfo.groups;
    final icon =
        !isExpanded ? Icons.expand_more_outlined : Icons.expand_less_outlined;
    final textColor = isAccountChecked ? Colors.white : Color(0xff636363);

    return Column(
      children: [
        Container(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    onExpandTap?.call(!isExpanded);
                  },
                  icon: Icon(icon,
                      color: textColor,
                      size: 16)),
              GestureDetector(
                child: SizedBox(
                  child: Text(
                    "${accountInfo.account.name}(${accountInfo.count})",
                    style: TextStyle(
                      color:
                          textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                  width: width - 50,
                ),
                onTap: () {
                  onAccountTap?.call(accountInfo);
                },
              ),
            ],
          ),
          height: 40,
          color: isAccountChecked ? Color(0xff0092fd) : Colors.white,
          padding: EdgeInsets.only(left: 10),
        ),
        Visibility(
          child: Column(
            children: List.generate(groups.length, (index) {
              final group = groups[index];
              return GestureDetector(
                child: Material(
                  child: ListTile(
                    dense: true,
                    title: Padding(
                      child: Text("${group.title}(${group.count})"),
                      padding: EdgeInsets.only(left: 35),
                    ),
                    tileColor: Colors.white,
                    selectedTileColor: Color(0xff0092fd),
                    selected: group == checkedGroup,
                    textColor: Color(0xff636363),
                    iconColor: Color(0xff636363),
                    selectedColor: Colors.white,
                  ),
                ),
                onTap: () {
                  onGroupTap?.call(group);
                },
              );
            }),
          ),
          visible: isExpanded,
        )
      ],
    );
  }
}
