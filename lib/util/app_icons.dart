import 'package:flutter/material.dart';

class AppIcons {
  AppIcons._internal();

  static final Map<String, Widget> emotionIcons = {
    'angry': Image.asset(
      "assets/images/angry.png",
      width: 42,
      height: 42,
    ),
    'disgust': Image.asset(
      "assets/images/disgust.png",
      width: 42,
      height: 42,
    ),
    'fear': Image.asset(
      "assets/images/fear.png",
      width: 42,
      height: 42,
    ),
    'happy': Image.asset(
      "assets/images/happy.png",
      width: 42,
      height: 42,
    ),
    'neutral': Image.asset(
      "assets/images/neutral.png",
      width: 42,
      height: 42,
    ),
    'sad': Image.asset(
      "assets/images/sad.png",
      width: 42,
      height: 42,
    ),
    'surprise': Image.asset(
      "assets/images/surprise.png",
      width: 42,
      height: 42,
    ),
  };

  static Widget getIcon(String emotion) {
    return emotionIcons[emotion] ??
        Container(); // Return an empty container if the emotion is not found
  }
}
