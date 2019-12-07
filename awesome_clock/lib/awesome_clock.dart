import 'dart:async';

import 'package:awesome_clock/clock_face.dart';
import 'package:awesome_clock/temperature_view.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';

import 'arc_clipper.dart';
import 'assets_weather_mapper.dart';
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
  num _temperature;
  var _temperatureUnit = '';
  var _temperatureRange = '';
  WeatherCondition _condition;
  var _location = '';
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
      _temperature = widget.model.temperature;
      _temperatureUnit = widget.model.unitString;
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
    return LayoutBuilder(builder: (context, constraints) {
      final weatherDisplayWidth = constraints.maxWidth / 2.2;
      _markerOffset = (weatherDisplayWidth / HAND_WIDTH).ceil() + 1;
      return Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [_clockFace.gradientStart, _clockFace.gradientEnd],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight),
        ),
        child: Stack(
          children: <Widget>[
            _buildTimeDisplayHolder(),
            _buildWeatherStatusHolder(weatherDisplayWidth),
          ],
        ),
      );
    });
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
              Expanded(child: _buildHand(_hourManager, fontSize: 50.0)),
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
    return ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.black,
            thickness: 4.0,
          );
        },
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

  Widget _buildWeatherStatusHolder(num width) {
    return ClipPath(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      clipper: ArcClipper(),
      child: SizedBox(
        width: width,
        child: Stack(
          children: <Widget>[
            _buildWallpaper(),
            _buildOverlay(),
            Container(
              margin: EdgeInsets.only(right: width / 4),
              padding:
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _location,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20.0, fontFamily: FONT_VARELA),
                  ),
                  Container(
                    height: 10.0,
                  ),
                  TemperatureView(_temperature, _temperatureUnit),
                  _buildWidgetForWeatherStatus(),
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

  Widget _buildWidgetForWeatherStatus() {
    final fileName = AssetWeatherMapper.getAssetForWeather(_condition);
    if (fileName == null ||
        (!fileName.endsWith('png') && !fileName.endsWith('flr'))) {
      return Container(
          child: Text(_condition.toString().split(".")[1].toUpperCase()));
    }
    return Container(
      width: double.infinity,
      height: 80.0,
      child: fileName.endsWith('flr')
          ? FlareActor('assets/$fileName', animation: 'animate')
          : Image.asset('assets/$fileName'),
    );
  }

  Container _buildOverlay() {
    return Container(color: _clockFace.overlay);
  }

  Widget _buildMarker() {
    return Positioned(
      top: 10.0,
      bottom: 10.0,
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
