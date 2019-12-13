import 'package:flutter_clock_helper/model.dart';

class AssetWeatherMapper {
  /// @return the file name for the [condition] or `null` if [condition] is invalid
  static String getAssetForWeather(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return 'sunny_1.png';
      case WeatherCondition.cloudy:
        return 'cloudy_day.png';
      case WeatherCondition.foggy:
        return 'foggy.png';
      case WeatherCondition.rainy:
        return 'rainfall.flr';
      case WeatherCondition.snowy:
        return 'snowfall.flr';
      case WeatherCondition.thunderstorm:
        return 'thunder.flr';
      case WeatherCondition.windy:
        return 'windy.png';
      default:
        return null;
    }
  }
}
