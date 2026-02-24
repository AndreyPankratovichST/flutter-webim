/// LocationSettings received from server.
/// See MessageStream.getLocationSettings(), MessageStream.swift LocationSettings.
abstract class LocationSettings {
  /// True if app should show hint questions to visitor.
  bool get areHintsEnabled;
}

/// Default implementation.
class LocationSettingsImpl implements LocationSettings {
  @override
  final bool areHintsEnabled;

  const LocationSettingsImpl({this.areHintsEnabled = false});
}
