import 'package:flutter/material.dart';

import 'constants.dart';

class TemperatureView extends StatelessWidget {
  final num _value;
  final String _unit;

  TemperatureView(this._value, this._unit);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(_value.toStringAsFixed(1),
                style: TextStyle(
                    fontSize: constraints.maxWidth / 3.9,
                    fontFamily: FONT_VARELA,
                    letterSpacing: 1.2)),
            Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 2.0),
              child: Text(
                _unit,
                style: TextStyle(
                    fontSize: constraints.maxWidth / 6.5,
                    fontFamily: FONT_VARELA),
              ),
            ),
          ],
        );
      },
    );
  }
}