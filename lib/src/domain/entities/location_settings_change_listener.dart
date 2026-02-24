import 'package:webim/src/domain/entities/location_settings.dart';

/// Called when location settings change. See MessageStream.set(locationSettingsChangeListener:).
abstract class LocationSettingsChangeListener {
  void changed(LocationSettings previous, LocationSettings newSettings);
}
