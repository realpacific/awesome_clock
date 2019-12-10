import 'dart:ui';

import 'package:flutter/material.dart';

abstract class OneSidedArc {
  Path provideClipPath(Size size, double controlPointDistance);
}

class RightSidedArc implements OneSidedArc {
  @override
  Path provideClipPath(Size size, double controlPointDistance) {
    Path path = Path()
      ..lineTo(size.width, 0)..lineTo(size.width, 0)
      ..quadraticBezierTo(size.width - controlPointDistance, size.height / 2,
          size.width, size.height)
      ..lineTo(0, size.height);

    path.close();
    return path;
  }
}

class ArcClipper extends CustomClipper<Path> {
  final num controlPointDistance;
  final OneSidedArc arc;

  const ArcClipper({@required this.controlPointDistance, @required this.arc})
      : assert(controlPointDistance != null),
        assert(arc != null);

  @override
  Path getClip(Size size) {
    return arc.provideClipPath(size, controlPointDistance);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
