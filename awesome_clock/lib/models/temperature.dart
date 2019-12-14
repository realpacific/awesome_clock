class Temperature {
  final double value;
  final String unit;

  const Temperature(this.value, this.unit);

  /// Returns `true` if [unit] has degrees.
  hasDegrees() => unit.length >= 1 && unit[0] == "°";
}
