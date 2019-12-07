import 'dart:ui';

import 'package:flutter/material.dart';

/// Defines the visual properties of Clock's face
abstract class ClockFace {
  final Color gradientStart;
  final Color gradientEnd;
  final String backgroundImage;
  final Color overlay;
  final Color pointerColor;

  ClockFace({@required this.gradientStart,
    @required this.gradientEnd,
    @required this.backgroundImage,
    @required this.overlay,
    @required this.pointerColor})
      : assert(gradientStart != null),
        assert(gradientEnd != null),
        assert(backgroundImage != null),
        assert(overlay != null),
        assert(pointerColor != null);
}

class DarkClockFace extends ClockFace {
  static final DarkClockFace _instance = DarkClockFace._getInstance();

  factory DarkClockFace() {
    return _instance;
  }

  DarkClockFace._getInstance()
      : super(
    gradientEnd: Color(0xff1C0A4A),
    gradientStart: Color(0xff170B4B),
    backgroundImage: 'assets/stacked_rocks.jpg',
    overlay: Colors.black54,
    pointerColor: Colors.white,
  );
}

class LightClockFace extends ClockFace {
  static final LightClockFace _instance = LightClockFace._getInstance();

  factory LightClockFace() {
    return _instance;
  }

  LightClockFace._getInstance()
      : super(
    gradientEnd: Color(0xffAABED6),
    gradientStart: Color(0xffD7DFE9),
    backgroundImage: 'assets/boats.jpg',
    overlay: Colors.transparent,
    pointerColor: Colors.black,
  );
}
