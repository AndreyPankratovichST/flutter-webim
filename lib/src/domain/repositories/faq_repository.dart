import 'package:webim/src/domain/entities/faq_category.dart';
import 'package:webim/src/domain/entities/faq_item.dart';
import 'package:webim/src/domain/entities/faq_item_source.dart';
import 'package:webim/src/domain/entities/faq_structure.dart';
import 'package:webim/src/domain/entities/faq_search_item.dart';

/// Repository for FAQ operations.
abstract class FAQRepository {
  /// Retrieves all FAQ categories (with items).
  Future<List<FAQCategory>> fetchAll();

  /// Root categories. GET /webim/api/v1/faq/category (Swift FAQActions).
  Future<List<FAQCategory>> getRootCategories({
    String? departmentId,
    String? categoryId,
  });

  /// Categories for app/lang/department. GET /webim/api/v1/faq/category.
  Future<List<FAQCategory>> getCategoriesForApplication({
    String? application,
    String? language,
    String? departmentKey,
  });

  /// Retrieves a single category by id.
  Future<FAQCategory> fetchById(String id);

  /// Retrieves a single FAQ item by id.
  Future<FAQItem> fetchItemById(String id);

  /// Tracks FAQ item open for analytics (Swift: track(itemId:openFrom:)).
  Future<void> trackItem(String itemId, FAQItemSource openFrom);

  /// Structure (tree). GET /services/faq/v1/structure?categoryid=.
  Future<FAQStructure?> getStructure(String categoryId);

  /// Like item. POST /services/faq/v1/like. Returns null on error.
  Future<FAQItem?> like(String itemId);

  /// Dislike item. POST /services/faq/v1/dislike. Returns null on error.
  Future<FAQItem?> dislike(String itemId);

  /// Search. GET /services/faq/v1/search. Returns list (empty on error).
  Future<List<FAQSearchItem>> search(String query, {String? category, int limitOfItems = 0});
}
