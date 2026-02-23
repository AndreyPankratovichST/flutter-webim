import 'package:webim/src/domain/entities/faq_category.dart';
import 'package:webim/src/domain/repositories/faq_repository.dart';

class FetchFAQ {
  final FAQRepository _repo;

  const FetchFAQ(this._repo);

  Future<List<FAQCategory>> call() => _repo.fetchAll();
}
