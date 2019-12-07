import 'dart:async';

import 'package:awesome_clock/clock_face.dart';
import 'package:awesome_clock/weather_status_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';

import 'constants.dart';
import 'hand_manager.dart';

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
  num _markerOffset = MARKER_OFFSET_LANDSCAPE;

  static final ScrollController _hoursController =
      ScrollController(initialScrollOffset: 0.0);
  static final ScrollController _minutesController =
      ScrollController(initialScrollOffset: 0.0);
  static final ScrollController _secondController =
      ScrollController(initialScrollOffset: 0.0);

  HandManager _hourManager;
  HandManager _minuteManager = MinuteHandManager(_minutesController);
  HandManager _secondManger = SecondHandManager(_secondController);
  var _currentHourFormat = _HourFormat.hours12;

  @override
  void initState() {
    super.initState();
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
      if (_weatherStatus == null) _weatherStatus = WeatherStatus();
      _weatherStatus.temperature = widget.model.temperature;
      _weatherStatus.temperatureUnit = widget.model.unitString;
      _weatherStatus.temperatureRange =
      '(${widget.model.low} - ${widget.model.highString})';
      _weatherStatus.condition = widget.model.weatherCondition;
      _weatherStatus.location = widget.model.location;

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
    var indexOfMinutes = _minuteManager.calculateIndex(_dateTime);
    var indexOfSeconds = _secondManger.calculateIndex(_dateTime);
    var indexOfHours = _hourManager.calculateIndex(_dateTime);
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
        // Put marker at the middle
        _markerOffset = ((constraints.maxWidth / 2) / HAND_WIDTH).ceil();
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [_clockFace.gradientStart, _clockFace.gradientEnd],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight),
          ),
          child: Stack(
            children: <Widget>[
              _buildTimeDisplayHolder(),
              WeatherStatusView(
                width: weatherDisplayWidth,
                height: weatherDisplayHeight,
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

  Widget _buildHand(HandManager handManager, {fontSize: 48.0}) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        controller: handManager.controller,
        itemCount: handManager.values.length * handManager.duplicationCount,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          int currentTime =
          handManager.values[index % handManager.values.length];
          return Container(
            width: HAND_WIDTH,
            child: Center(
              child: Text(
                '${(currentTime <= 9) ? '0$currentTime' : currentTime}',
                style: TextStyle(
                    fontSize: fontSize, fontFamily: FONT_SEGMENT_7_STANDARD),
              ),
            ),
          );
        });
  }

  Widget _buildMarker() {
    return Positioned(
      top: 5.0,
      bottom: 5.0,
      width: HAND_WIDTH,
      left: HAND_WIDTH * _markerOffset,
      child: Container(
        width: HAND_WIDTH + 6.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: _clockFace.pointerColor,
            width: 2.5,
          ),
        ),
      ),
    );
  }
}
