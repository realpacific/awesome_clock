import 'package:awesome_clock/constants.dart';
import 'package:awesome_clock/models/temperature.dart';
import 'package:flutter/material.dart';

class TemperatureView extends StatelessWidget {
  final Temperature temperature;

  TemperatureView(this.temperature);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          alignment: WrapAlignment.start,
          children: <Widget>[
            Text(temperature.value.round().toString(),
                maxLines: 1,
                style: TextStyle(
                    fontSize: constraints.maxWidth / 3.9,
                    fontFamily: FONT_VARELA,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800)),
            Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 2.0),
              child: Text(
                temperature.unit,
                style: TextStyle(
                    fontSize: constraints.maxWidth / 6.0,
                    fontFamily: FONT_VARELA,
                    fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }
}
