import 'package:webim/src/domain/entities/visit_session_state.dart';

/// Called when visit session state changes. See MessageStream.set(visitSessionStateListener:).
abstract class VisitSessionStateListener {
  void changed(VisitSessionState previous, VisitSessionState newState);
}
