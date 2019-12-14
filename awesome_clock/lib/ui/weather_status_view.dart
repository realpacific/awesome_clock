import 'package:awesome_clock/arc_clipper.dart';
import 'package:awesome_clock/constants.dart';
import 'package:awesome_clock/models/clock_face.dart';
import 'package:awesome_clock/models/weather_status.dart';
import 'package:awesome_clock/ui/temperature_range_view.dart';
import 'package:awesome_clock/ui/temperature_view.dart';
import 'package:awesome_clock/utils.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Collectively displays [status] using [clockFace] for visual properties.
///
/// The font size in this Widget adapts to the total width of this Widget.
class WeatherStatusView extends StatelessWidget {
  final double height;

  /// The width of this Widget used to adapt font size.
  final double width;
  final WeatherStatus status;
  final ClockFace clockFace;

  const WeatherStatusView({@required this.height,
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
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 12.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  (status?.location?.isNotEmpty ?? false)
                      ? _buildLocationView(width)
                      : _buildEmptyLayout(),
                  _buildEmptyLayout(height: 10.0),
                  (status?.currentTemperature != null)
                      ? TemperatureView(status.currentTemperature)
                      : _buildEmptyLayout(),
                  (status?.lowTemperature != null &&
                      status?.highTemperature != null)
                      ? TemperatureRangeView(
                    status.lowTemperature,
                    status.highTemperature,
                    fontFactor: 10.6,
                  )
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
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(2.0),
            child: const Icon(Icons.location_on),
            margin: const EdgeInsets.only(right: 4.0),
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
        image: DecorationImage(
          image: AssetImage(clockFace.backgroundImage),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget _buildWidgetForWeatherStatus() {
    final fileName = status.assetForWeatherCondition();
    if (!fileName.isValidFileFormat()) {
      return Container(
        child: Text(
          status.weatherConditionToString(),
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
      child: fileName.isFlareFile()
          ? FlareActor(fileName.toAsset(), animation: 'animate')
          : Image.asset(fileName.toAsset()),
    );
  }

  Widget _buildOverlay() {
    return Container(color: clockFace.overlay);
  }
}
