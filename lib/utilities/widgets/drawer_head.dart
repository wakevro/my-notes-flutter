import 'package:flutter/material.dart';
import 'package:mynotes/constants/dimensions.dart';
import 'package:mynotes/constants/pallete.dart';
import 'package:mynotes/constants/text_styling.dart';

class DrawerHead extends StatelessWidget {
  final String title;
  final String filePath;
  const DrawerHead({
    super.key,
    required this.title,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Pallete.darkMidColor,
      width: double.infinity,
      padding: Dimension.bodyPadding.copyWith(),
      margin: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Image(
            image: AssetImage(
              filePath,
            ),
            height: 70,
          ),
          Text(
            title,
            style: TStyle.heading1.copyWith(color: Pallete.whiteColor),
          ),
        ],
      ),
    );
  }
}
