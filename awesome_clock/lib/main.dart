import 'dart:io';

import 'package:awesome_clock/ui/awesome_clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:flutter_clock_helper/model.dart';

void main() {
  // A temporary measure until Platform supports web and TargetPlatform supports
  // macOS.
//  debugPaintSizeEnabled = true;
  if (!kIsWeb && Platform.isMacOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  runApp(ClockCustomizer((ClockModel model) => AwesomeClock(model)));
}
