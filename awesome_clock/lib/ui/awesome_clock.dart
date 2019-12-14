import 'dart:async';
import 'dart:ui';

import 'package:awesome_clock/constants.dart';
import 'package:awesome_clock/hand_manager.dart';
import 'package:awesome_clock/models/clock_face.dart';
import 'package:awesome_clock/models/weather_status.dart';
import 'package:awesome_clock/ui/weather_status_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';

enum _HourFormat { hours24, hours12 }

class AwesomeClock extends StatefulWidget {
  const AwesomeClock(this.model);

  final ClockModel model;

  @override
  _AwesomeClockState createState() => _AwesomeClockState();
}

class _AwesomeClockState extends State<AwesomeClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  WeatherStatus _weatherStatus;
  ClockFace _clockFace;

  /// The amount by which to offset the clock's marker or hand to the right.
  int _markerOffset = MARKER_OFFSET_LANDSCAPE;

  static final ScrollController _hoursController =
      ScrollController(initialScrollOffset: 0.0);
  static final ScrollController _minutesController =
      ScrollController(initialScrollOffset: 0.0);
  static final ScrollController _secondController =
      ScrollController(initialScrollOffset: 0.0);

  HandManager _hourManager;
  final _minuteManager = MinuteHandManager(_minutesController);
  final _secondManger = SecondHandManager(_secondController);
  var _currentHourFormat = _HourFormat.hours12;

  @override
  void initState() {
    super.initState();
    _weatherStatus ??= WeatherStatus();
    _hourManager = widget.model.is24HourFormat
        ? Hour24HandManager(_hoursController)
        : Hour12HandManager(_hoursController);
    _currentHourFormat =
        widget.model.is24HourFormat ? _HourFormat.hours24 : _HourFormat.hours12;
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AwesomeClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    _hourManager.controller.dispose();
    _minuteManager.controller.dispose();
    _secondManger.controller.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _weatherStatus.from(widget.model);

      /// Detect if hour format has changed and update accordingly.
      if (widget.model.is24HourFormat &&
          _currentHourFormat == _HourFormat.hours12) {
        _currentHourFormat = _HourFormat.hours24;
        _hourManager = Hour24HandManager(_hoursController);
      } else if (!widget.model.is24HourFormat &&
          _currentHourFormat == _HourFormat.hours24) {
        _currentHourFormat = _HourFormat.hours12;
        _hourManager = Hour12HandManager(_hoursController);
      }
    });
  }

  void _updateTime() {
    // Since the time has updated, scroll all the hands to the new values.
    final indexOfMinutes = _minuteManager.calculateIndex(_dateTime);
    final indexOfSeconds = _secondManger.calculateIndex(_dateTime);
    final indexOfHours = _hourManager.calculateIndex(_dateTime);
    if (_secondManger.controller.hasClients) {
      _secondManger.controller.animateTo(
        (indexOfSeconds - _markerOffset) * HAND_WIDTH,
        curve: Curves.linear,
        duration: const Duration(milliseconds: 200),
      );
    }
    if (_hourManager.controller.hasClients) {
      _hourManager.controller.animateTo(
        (indexOfHours - _markerOffset) * HAND_WIDTH,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    }
    if (_minuteManager.controller.hasClients) {
      _minuteManager.controller.animateTo(
        (indexOfMinutes - _markerOffset) * HAND_WIDTH,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    }
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _clockFace = Theme
        .of(context)
        .brightness == Brightness.dark
        ? DarkClockFace()
        : LightClockFace();
    return LayoutBuilder(
      builder: (context, constraints) {
        final weatherDisplayWidth = constraints.maxWidth / 2.5;
        final weatherDisplayHeight = constraints.maxHeight;
        // Put marker as close to the middle as possible.
        _markerOffset = ((constraints.maxWidth / 2) / HAND_WIDTH).ceil();
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_clockFace.gradientStart, _clockFace.gradientEnd],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Stack(
            children: <Widget>[
              _buildTimeDisplayHolder(),
              WeatherStatusView(
                height: weatherDisplayHeight,
                width: weatherDisplayWidth,
                clockFace: _clockFace,
                status: _weatherStatus,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeDisplayHolder() {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(child: _buildHand(_hourManager)),
              Expanded(child: _buildHand(_minuteManager)),
              Expanded(child: _buildHand(_secondManger, fontSize: 38.0)),
            ],
          ),
        ),
        _buildMarker()
      ],
    );
  }

  Widget _buildHand(HandManager handManager, {fontSize: 50.0}) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        controller: handManager.controller,
        itemCount: handManager.handValues.length * handManager.duplicationCount,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          int currentTime =
          handManager.handValues[index % handManager.handValues.length];
          return Container(
            width: HAND_WIDTH,
            child: Center(
              child: Text(
                '${(currentTime <= 9) ? '0$currentTime' : currentTime}',
                style: TextStyle(
                  fontSize: fontSize,
                  fontFamily: FONT_SEGMENT_7_STANDARD,
                ),
              ),
            ),
          );
        });
  }

  Widget _buildMarker() {
    return Positioned(
      top: 6.0,
      bottom: 6.0,
      width: HAND_WIDTH,
      left: HAND_WIDTH * _markerOffset,
      child: Container(
        width: HAND_WIDTH + 5.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: _clockFace.pointerColor,
            width: 2.6,
          ),
        ),
      ),
    );
  }
}
