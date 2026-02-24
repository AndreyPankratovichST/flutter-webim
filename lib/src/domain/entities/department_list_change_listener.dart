import 'package:webim/src/domain/entities/department.dart';

/// Called when department list is received. See MessageStream.set(departmentListChangeListener:).
abstract class DepartmentListChangeListener {
  void received(List<Department> departmentList);
}
