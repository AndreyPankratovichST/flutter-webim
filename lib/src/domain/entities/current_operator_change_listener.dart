import 'package:webim/src/domain/entities/operator.dart';

/// Called when current operator changes. See MessageStream.set(currentOperatorChangeListener:).
abstract class CurrentOperatorChangeListener {
  void changed(Operator? previousOperator, Operator? newOperator);
}
