import 'package:flutter/material.dart';

Scaffold showCircularLoading() {
  return const Scaffold(
    body: Center(child: CircularProgressIndicator.adaptive()),
  );
}
