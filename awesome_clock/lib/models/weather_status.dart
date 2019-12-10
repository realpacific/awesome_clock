import 'package:awesome_clock/models/temperature.dart';
import 'package:flutter_clock_helper/model.dart';

class WeatherStatus {
  Temperature currentTemperature;
  Temperature lowTemperature;
  Temperature highTemperature;
  WeatherCondition condition;
  String location;
}
