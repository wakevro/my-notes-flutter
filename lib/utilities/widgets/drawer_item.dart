import 'package:flutter/material.dart';
import 'package:mynotes/constants/pallete.dart';
import 'package:mynotes/constants/text_styling.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';

String tag = "DrawerItem";

class DrawerItem extends StatefulWidget {
  final IconData iconData;
  final String iconName;
  const DrawerItem({
    super.key,
    required this.iconData,
    required this.iconName,
  });

  @override
  State<DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<DrawerItem> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Icon(
                  widget.iconData,
                  size: 25,
                  color: widget.iconName == context.loc.delete_account
                      ? Pallete.redColor
                      : Pallete.darkColor,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  widget.iconName,
                  style: TStyle.bodyExtraSmall.copyWith(
                    color: widget.iconName == context.loc.delete_account
                        ? Pallete.redColor
                        : Pallete.darkColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            thickness: 1,
            height: 0,
          ),
        ],
      ),
    );
  }
}
