extension AssetUtils on String {
  /// Returns `true` if the the receiver ends with either png or flr.
  bool isValidFileFormat() =>
      this != null &&
      (endsWith('.png') || endsWith('.flr') || endsWith('.jpg'));

  /// Returns `true` if the receiver ends with flr.
  bool isFlareFile() => this != null && endsWith('.flr');

  /// Returns after prefixing *assets/* to the receiver if calling [isValidFileFormat]
  /// on it outputs `true` or else returns `null`
  String toAsset() => (isValidFileFormat() ? 'assets/$this' : null);
}
