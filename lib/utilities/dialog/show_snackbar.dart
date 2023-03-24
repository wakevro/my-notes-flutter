import 'package:flutter/material.dart';
import 'package:mynotes/constants/pallete.dart';

showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Pallete.darkMidColor,
    ),
  );
}