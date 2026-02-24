/// Error types that can be thrown by SessionBuilder.build().
/// See Webim.swift SessionBuilder.SessionBuilderError.
enum SessionBuilderError implements Exception {
  /// Standard and custom visitor auth used simultaneously.
  invalidAuthentificatorParameters,

  /// Invalid remote notification configuration (e.g. device token without system set).
  invalidRemoteNotificationConfiguration,

  /// Account name was not set.
  nilAccountName,

  /// Location was not set.
  nilLocation,

  /// Invalid hex in prechat.
  invalidHex,

  unknown,
}
