import 'package:webim/src/domain/entities/faq_category.dart';
import 'package:webim/src/domain/entities/faq_item.dart';
import 'package:webim/src/domain/entities/faq_item_source.dart';
import 'package:webim/src/domain/entities/faq_structure.dart';
import 'package:webim/src/domain/entities/faq_search_item.dart';

/// FAQ (knowledge base) with resume/pause/destroy lifecycle. See FAQ.swift.
abstract class FAQ {
  /// Resumes FAQ; allows network requests. FAQ is created paused.
  void resume();

  /// Pauses FAQ; stops new requests.
  void pause();

  /// Destroys FAQ; all methods will throw or no-op after this.
  void destroy();

  /// Category by id. Returns null if not found or FAQ paused/destroyed.
  Future<FAQCategory?> getCategory(String id);

  /// Root-level categories (optionally filtered by department/category).
  Future<List<FAQCategory>> getRootCategories({
    String? departmentId,
    String? categoryId,
  });

  /// Categories for application/language/department. Returns full categories.
  /// In Swift SDK the same name returns only category IDs; use [getCategoryIdsForApplication]
  /// for the ID list.
  Future<List<FAQCategory>> getCategoriesForApplication({
    String? application,
    String? language,
    String? departmentKey,
  });

  /// Category IDs for application/language/department. Matches Swift getCategoriesForApplication
  /// which returns Result<[String], ...>.
  Future<List<String>> getCategoryIdsForApplication({
    String? application,
    String? language,
    String? departmentKey,
  });

  /// Single FAQ item by id. [openFrom] is used for analytics (track) when provided.
  Future<FAQItem?> getItem(String id, {FAQItemSource? openFrom});

  /// Cached category by id. Returns null if not in cache or FAQ paused/destroyed.
  Future<FAQCategory?> getCachedCategory(String id);

  /// Cached item by id. [openFrom] triggers track when provided. Returns null if not in cache.
  Future<FAQItem?> getCachedItem(String id, {FAQItemSource? openFrom});

  /// Structure (tree) for category id. Fills cache on success.
  Future<FAQStructure?> getStructure(String id);

  /// Cached structure by id. Returns null if not in cache.
  Future<FAQStructure?> getCachedStructure(String id);

  /// Like item. Returns the same item on success, null on error or paused/destroyed.
  Future<FAQItem?> like(FAQItem item);

  /// Dislike item. Returns the same item on success, null on error or paused/destroyed.
  Future<FAQItem?> dislike(FAQItem item);

  /// Search. Returns empty list on error or when paused/destroyed.
  Future<List<FAQSearchItem>> search(String query, {String? category, int limitOfItems = 0});

  bool get isPaused;
  bool get isDestroyed;
}
