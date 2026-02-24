/// Server error strings (Swift WebimInternalError.rawValue).
/// Used in init/delta responses: { "error": "reinit-required" } etc.
class WebimInternalError {
  WebimInternalError._();

  /// Delta/init: reset auth and re-run init (Swift: handleReinitializationRequiredError).
  static const String reinitializationRequired = 'reinit-required';

  /// Init: provided auth token not found; Swift may retry with backoff.
  static const String providedAuthenticationTokenNotFound =
      'provided-auth-token-not-found';
}
