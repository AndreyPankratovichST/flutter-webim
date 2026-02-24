import 'dart:math';

/// Generates random IDs (e.g. for sending messages).
/// See ClientSideID.swift: 32 hex characters.
String generateClientSideID() {
  const chars = 'abcdef0123456789';
  final r = Random.secure();
  return List.generate(32, (_) => chars[r.nextInt(chars.length)]).join();
}
