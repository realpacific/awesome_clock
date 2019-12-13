import 'package:awesome_clock/constants.dart';
import 'package:awesome_clock/models/temperature.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///
/// Widget displays the temperature range in the format of `L[lowTemperature] [separator] H[highTemperature]`
///
/// example: L22°/H26°
class TemperatureRangeView extends StatelessWidget {
  final Temperature lowTemperature;
  final Temperature highTemperature;

  /// Separates [lowTemperature] and [highTemperature].
  final String separator;

  /// Factor by which to divide the maximum width of parent
  final double fontFactor;

  TemperatureRangeView(this.lowTemperature, this.highTemperature,
      {this.separator: '/', this.fontFactor});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize =
            (fontFactor != null) ? (constraints.maxWidth / fontFactor) : 20.0;
        return RichText(
          textAlign: TextAlign.start,
          text: TextSpan(
            style: Theme.of(context).textTheme.title,
            children: [
              ..._createSingleTemperatureRange('L', lowTemperature, fontSize),
              TextSpan(
                text: separator,
                style: TextStyle(fontSize: fontSize, letterSpacing: 4.5),
              ),
              ..._createSingleTemperatureRange('H', highTemperature, fontSize),
            ],
          ),
        );
      },
    );
  }

  List<TextSpan> _createSingleTemperatureRange(
      String prefix, Temperature temperature, double fontSize) {
    return [
      TextSpan(
        text: prefix,
        style: TextStyle(
            fontSize: fontSize - 5,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            letterSpacing: 5.0,
            fontFamily: FONT_VARELA),
      ),
      TextSpan(
          text:
              '${temperature.value.round()}${temperature.unit[0] == "°" ? "°" : ""}',
          style: TextStyle(fontSize: fontSize, fontFamily: FONT_VARELA))
    ];
  }
}
