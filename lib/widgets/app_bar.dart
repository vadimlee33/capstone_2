import 'package:flutter/material.dart';

class AppBarCustom extends AppBar {
  AppBarCustom({super.key})
      : super(
          title: const Text(
            "Mood Wave",
            style: TextStyle(fontSize: 32, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        );
}
