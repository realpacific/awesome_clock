import 'package:awesome_clock/temperature_view.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';

import 'arc_clipper.dart';
import 'assets_weather_mapper.dart';
import 'clock_face.dart';
import 'constants.dart';

class WeatherStatus {
  double temperature;
  String temperatureUnit;
  String temperatureRange;
  WeatherCondition condition;
  String location;
}

class WeatherStatusView extends StatelessWidget {
  final double height;
  final double width;
  final WeatherStatus status;
  final ClockFace clockFace;

  WeatherStatusView({this.height, this.width, this.status, this.clockFace});

  @override
  Widget build(BuildContext context) {
    return _buildWeatherStatusHolder(width: width, height: height);
  }

  Widget _buildWeatherStatusHolder(
      {@required num width, @required num height}) {
    assert(width != null);
    assert(height != null);
    return ClipPath(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      clipper:
          ArcClipper(controlPointDistance: height / 3.5, arc: RightSidedArc()),
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
                  status.location != null
                      ? Text(
                          status.location,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: width / 14, fontFamily: FONT_VARELA),
                        )
                      : Container(),
                  Container(height: 10.0),
                  status.temperature != null
                      ? TemperatureView(
                          status.temperature, status.temperatureUnit)
                      : Container(),
                  _buildWidgetForWeatherStatus(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWallpaper() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        image: new DecorationImage(
          image: new AssetImage(clockFace.backgroundImage),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget _buildWidgetForWeatherStatus() {
    final fileName = AssetWeatherMapper.getAssetForWeather(status.condition);
    if (fileName == null ||
        (!fileName.endsWith('png') && !fileName.endsWith('flr'))) {
      return Container(
          child: Text(status.condition.toString().split(".")[1].toUpperCase()));
    }
    return Container(
      width: double.infinity,
      height: 80.0,
      child: fileName.endsWith('flr')
          ? FlareActor('assets/$fileName', animation: 'animate')
          : Image.asset('assets/$fileName'),
    );
  }

  Widget _buildOverlay() {
    return Container(color: clockFace.overlay);
  }
}
