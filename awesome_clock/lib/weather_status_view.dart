import 'package:awesome_clock/arc_clipper.dart';
import 'package:awesome_clock/constants.dart';
import 'package:awesome_clock/models/clock_face.dart';
import 'package:awesome_clock/models/weather_status.dart';
import 'package:awesome_clock/temperature_view.dart';
import 'package:awesome_clock/utils/assets_weather_mapper.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WeatherStatusView extends StatelessWidget {
  final double height;
  final double width;
  final WeatherStatus status;
  final ClockFace clockFace;

  WeatherStatusView({@required this.height,
    @required this.width,
    @required this.status,
    @required this.clockFace})
      : assert(height != null &&
      width != null &&
      status != null &&
      clockFace != null);

  @override
  Widget build(BuildContext context) {
    return _buildWeatherStatusHolder(width, height);
  }

  Widget _buildWeatherStatusHolder(double width, double height) {
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
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  (status.location != null && status.location.length > 0)
                      ? _buildLocationView(width)
                      : _buildEmptyLayout(),
                  _buildEmptyLayout(height: 10.0),
                  status.currentTemperature != null
                      ? TemperatureView(status.currentTemperature)
                      : _buildEmptyLayout(),
                  _buildWidgetForWeatherStatus(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Container _buildEmptyLayout({double height, double width}) =>
      Container(
        width: width,
        height: height,
      );

  Widget _buildLocationView(double width) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(12),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(2.0),
            child: Icon(Icons.location_on),
            margin: EdgeInsets.only(right: 4.0),
          ),
          Expanded(
            child: Text(
              status.location,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: width / 14, fontFamily: FONT_VARELA),
            ),
          )
        ],
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
        child: Text(
          status.condition.toString().split(".")[1].toUpperCase(),
          style: TextStyle(
            fontSize: width / 14,
            fontFamily: FONT_VARELA,
          ),
        ),
      );
    }
    return Container(
      width: 80.0,
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
