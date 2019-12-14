import 'package:awesome_clock/models/temperature.dart';
import 'package:flutter_clock_helper/model.dart';

class WeatherStatus {
  Temperature currentTemperature;
  Temperature lowTemperature;
  Temperature highTemperature;
  WeatherCondition condition;
  String location;

  /// Returns the file name for the [condition] or `null` if invalid.
  String assetForWeatherCondition() {
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

  /// Returns upper-cased `String` of [condition].
  String weatherConditionToString() {
    return enumToString(condition).toUpperCase();
  }

  /// Uses [model] to update the attributes.
  from(ClockModel model) {
    currentTemperature = Temperature(model.temperature, model.unitString);
    lowTemperature = Temperature(model.low, model.unitString);
    highTemperature = Temperature(model.high, model.unitString);
    condition = model.weatherCondition;
    location = model.location;
  }
}
