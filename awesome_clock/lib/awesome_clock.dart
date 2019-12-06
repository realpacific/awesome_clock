// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:awesome_clock/clock_face.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';

import 'arc_clipper.dart';
import 'assets_weather_mapper.dart';
import 'hand_manager.dart';

enum _HourFormat { hours24, hours12 }

const OFFSET_LANDSCAPE = 4;
const WIDTH = 90.0;
const WEATHER_DISPLAY_WIDTH_LANDSCAPE = 300.0;

class AwesomeClock extends StatefulWidget {
  const AwesomeClock(this.model);

  final ClockModel model;

  @override
  _AwesomeClockState createState() => _AwesomeClockState();
}

class _AwesomeClockState extends State<AwesomeClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  var _temperature = '';
  var _temperatureRange = '';
  WeatherCondition _condition;
  var _location = '';
  ClockFace _clockFace;

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
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherCondition;
      _location = widget.model.location;
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
        (indexOfSeconds - OFFSET_LANDSCAPE) * WIDTH,
        curve: Curves.linear,
        duration: const Duration(milliseconds: 200),
      );
    }
    if (_hourManager.controller.hasClients) {
      _hourManager.controller.animateTo(
        (indexOfHours - OFFSET_LANDSCAPE) * WIDTH,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 900),
      );
    }
    if (_minuteManager.controller.hasClients) {
      _minuteManager.controller.animateTo(
        (indexOfMinutes - OFFSET_LANDSCAPE) * WIDTH,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 900),
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
    setState(() {
      _clockFace = Theme.of(context).brightness == Brightness.dark
          ? DarkClockFace()
          : LightClockFace();
    });
    return Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
            colors: [_clockFace.gradientStart, _clockFace.gradientEnd],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft),
      ),
      child: Stack(
        children: <Widget>[
          _buildTimeDisplayHolder(),
          _buildWeatherStatusHolder(),
        ],
      ),
    );
  }

  Stack _buildTimeDisplayHolder() {
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
              Expanded(child: buildHand(_hourManager)),
              Expanded(child: buildHand(_minuteManager)),
              Expanded(child: buildHand(_secondManger, fontSize: 40.0)),
            ],
          ),
        ),
        _buildMarker()
      ],
    );
  }

  Widget _buildWeatherStatusHolder() {
    return ClipPath(
      clipBehavior: Clip.antiAlias,
      clipper: ArcClipper(),
      child: SizedBox(
        width: WEATHER_DISPLAY_WIDTH_LANDSCAPE,
        child: Stack(
          children: <Widget>[
            _buildWallpaper(),
            _buildOverlay(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _temperature,
                    style: TextStyle(fontSize: 50.0, fontFamily: 'Varela'),
                  ),
                  Text(
                    _temperatureRange,
                    style: TextStyle(fontSize: 15.0, fontFamily: 'Varela'),
                  ),
                  _buildWidgetForWeatherStatus(),
                  Container(
                    margin: EdgeInsets.only(right: 150 / 2),
                    child: Text(
                      _location,
                      style: TextStyle(fontSize: 20.0, fontFamily: 'Varela'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Container _buildWallpaper() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        image: new DecorationImage(
          image: new AssetImage(_clockFace.backgroundImage),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Container _buildWidgetForWeatherStatus() {
    final fileName = AssetWeatherMapper.getAssetForWeather(_condition);
    if (fileName == null ||
        (!fileName.endsWith('png') && !fileName.endsWith('flr'))) {
      return Container(
          child: Text(_condition.toString().split(".")[1].toUpperCase()));
    }
    return Container(
      width: 60.0,
      height: 60.0,
      child: fileName.endsWith('flr')
          ? FlareActor('assets/$fileName', animation: 'animate')
          : Image.asset('assets/$fileName'),
    );
  }

  Container _buildOverlay() {
    return Container(
      color: _clockFace.overlay,
    );
  }

  Widget _buildMarker() {
    return Positioned(
      top: 10.0,
      bottom: 10.0,
      width: WIDTH,
      left: WIDTH * OFFSET_LANDSCAPE,
      child: Container(
        width: 96.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 3.0,
          ),
        ),
      ),
    );
  }
}
