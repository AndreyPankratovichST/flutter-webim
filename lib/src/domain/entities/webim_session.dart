import 'package:webim/src/domain/entities/message_stream.dart';

/// Session interface. See WebimSession.swift.
/// Session is created paused; call resume() to start.
abstract class WebimSession {
  void resume();
  void pause();
  void destroy();
  void destroyWithClearVisitorData();
  MessageStream getStream();
  void changeLocation(String location);
  void setDeviceToken(String deviceToken);
  void setRequestHeader(String key, String value);
}
