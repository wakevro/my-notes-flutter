import 'package:flutter/material.dart';
import 'package:mynotes/constants/dimensions.dart';
import 'package:mynotes/constants/pallete.dart';
import 'package:mynotes/constants/text_styling.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';

class DrawerHead extends StatefulWidget {
  const DrawerHead({super.key});

  @override
  State<DrawerHead> createState() => _DrawerHeadState();
}

class _DrawerHeadState extends State<DrawerHead> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Pallete.darkMidColor,
      width: double.infinity,
      height: 200,
      padding: Dimension.bodyPadding.copyWith(),
      margin: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Image(
            image: AssetImage(
              "assets/images/note.png",
            ),
            height: 70,
          ),
          Text(
            context.loc.folders,
            style: TStyle.heading1.copyWith(color: Pallete.whiteColor),
          ),
        ],
      ),
    );
  }
}
