import 'package:webim/src/domain/entities/faq_category.dart';
import 'package:webim/src/domain/entities/faq_item.dart';

/// Repository for FAQ operations.
abstract class FAQRepository {
  /// Retrieves all FAQ categories (with items).
  Future<List<FAQCategory>> fetchAll();

  /// Retrieves a single category by id.
  Future<FAQCategory> fetchById(String id);

  /// Retrieves a single FAQ item by id.
  Future<FAQItem> fetchItemById(String id);
}
