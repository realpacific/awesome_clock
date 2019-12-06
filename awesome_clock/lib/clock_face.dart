import 'dart:ui';

import 'package:flutter/material.dart';

abstract class ClockFace {
  Color gradientStart;
  Color gradientEnd;
  String backgroundImage;
  Color overlay;
}

class DarkClockFace extends ClockFace {
  @override
  Color gradientEnd = Color(0xff152F3B);

  @override
  Color gradientStart = Color(0xff437B95);

  @override
  String backgroundImage = 'assets/stacked_rocks.jpg';

  @override
  Color overlay = Colors.black54;
}

class LightClockFace implements ClockFace {
  @override
  Color gradientEnd = Color(0xff152F3B);

  @override
  Color gradientStart = Color(0xff437B95);

  @override
  String backgroundImage = 'assets/boats.jpg';

  @override
  Color overlay = Colors.transparent;
}
