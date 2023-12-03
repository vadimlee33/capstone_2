import 'package:captsone_2/main.dart';
import 'package:captsone_2/pages/history_screen.dart';
import 'package:captsone_2/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return SalomonBottomBar(
      currentIndex: pageIndex,
      onTap: (i) => setState(() {
        pageIndex = i;
      }),
      items: [
        /// Home
        SalomonBottomBarItem(
          icon: Icon(Icons.home),
          title: Text("Home"),
          selectedColor: Colors.purple,
        ),

        /// Likes
        SalomonBottomBarItem(
          icon: Icon(Icons.favorite_border),
          title: Text("Profile"),
          selectedColor: Colors.pink,
        ),

        /// Search
        SalomonBottomBarItem(
          icon: Icon(Icons.search),
          title: Text("History"),
          selectedColor: Colors.orange,
        ),

        /// Profile
        SalomonBottomBarItem(
          icon: Icon(Icons.person),
          title: Text("Settings"),
          selectedColor: Colors.teal,
        ),
      ],
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomeScreen(); // Replace with your home page widget
      case 1:
        return Container(); // Replace with your profile page widget
      case 2:
        return HistoryScreen(); // Replace with your history page widget
      case 3:
        return Container(); // Replace with your settings page widget
      default:
        return Container(); // Handle the default case as needed
    }
  }
}
