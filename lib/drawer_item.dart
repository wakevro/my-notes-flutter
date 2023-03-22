import 'package:flutter/material.dart';
import 'package:mynotes/constants/text_styling.dart';


String tag = "Drawer Item";

class DrawerItem extends StatelessWidget {
  final IconData iconData;
  final String iconName;
  final String route;

  const DrawerItem({
    super.key,
    required this.iconData,
    required this.iconName,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Icon(
                    iconData,
                    size: 25,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    iconName,
                    style: TStyle.bodyExtraSmall,
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
        onTap: () {
          Navigator.of(context).pushNamed(route);
        },
      ),
    );
  }
}
