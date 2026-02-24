/// Called when session/chat language changes. See MessageStream.set(sessionLanguageListener:).
abstract class SessionLanguageListener {
  void changed(String? newLanguage);
}
