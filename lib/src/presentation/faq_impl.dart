import 'package:webim/src/data/datasources/api_client.dart';
import 'package:webim/src/data/repositories/faq_repository_impl.dart';
import 'package:webim/src/domain/entities/faq.dart';
import 'package:webim/src/domain/entities/faq_category.dart';
import 'package:webim/src/domain/entities/faq_item.dart';
import 'package:webim/src/domain/entities/faq_item_source.dart';
import 'package:webim/src/domain/entities/faq_structure.dart';
import 'package:webim/src/domain/entities/faq_search_item.dart';
import 'package:webim/src/domain/repositories/faq_repository.dart';

/// Implementation of FAQ. Created paused; call resume() before use.
class FAQImpl implements FAQ {
  FAQImpl({
    required this.baseUrl,
    this.application,
    this.departmentKey,
    this.language,
  })  : _repo = FAQRepositoryImpl(ApiClient(baseUrl: baseUrl));

  final String baseUrl;
  final String? application;
  final String? departmentKey;
  final String? language;

  final FAQRepository _repo;

  final Map<String, FAQCategory> _categoryCache = {};
  final Map<String, FAQItem> _itemCache = {};
  final Map<String, FAQStructure> _structureCache = {};

  bool _isPaused = true;
  bool _isDestroyed = false;

  void _checkNotDestroyed() {
    if (_isDestroyed) throw StateError('FAQ is destroyed');
  }

  @override
  bool get isPaused => _isPaused;

  @override
  bool get isDestroyed => _isDestroyed;

  @override
  void resume() {
    _checkNotDestroyed();
    _isPaused = false;
  }

  @override
  void pause() {
    _checkNotDestroyed();
    _isPaused = true;
  }

  @override
  void destroy() {
    _isDestroyed = true;
  }

  @override
  Future<FAQCategory?> getCategory(String id) async {
    _checkNotDestroyed();
    if (_isPaused) return null;
    try {
      final category = await _repo.fetchById(id);
      _categoryCache[id] = category;
      return category;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<FAQCategory>> getRootCategories({
    String? departmentId,
    String? categoryId,
  }) async {
    _checkNotDestroyed();
    if (_isPaused) return [];
    try {
      return await _repo.getRootCategories(
        departmentId: departmentId,
        categoryId: categoryId,
      );
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<String>> getCategoryIdsForApplication({
    String? application,
    String? language,
    String? departmentKey,
  }) async {
    if (_isDestroyed || _isPaused) return [];
    final list = await _repo.getCategoriesForApplication(
      application: application,
      language: language,
      departmentKey: departmentKey,
    );
    return list.map((c) => c.id).toList();
  }

  @override
  Future<List<FAQCategory>> getCategoriesForApplication({
    String? application,
    String? language,
    String? departmentKey,
  }) async {
    _checkNotDestroyed();
    if (_isPaused) return [];
    try {
      return await _repo.getCategoriesForApplication(
        application: application ?? this.application,
        language: language ?? this.language,
        departmentKey: departmentKey ?? this.departmentKey,
      );
    } catch (_) {
      return [];
    }
  }

  @override
  Future<FAQItem?> getItem(String id, {FAQItemSource? openFrom}) async {
    _checkNotDestroyed();
    if (_isPaused) return null;
    try {
      if (openFrom != null) {
        await _repo.trackItem(id, openFrom);
      }
      final item = await _repo.fetchItemById(id);
      _itemCache[id] = item;
      return item;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<FAQCategory?> getCachedCategory(String id) async {
    _checkNotDestroyed();
    if (_isPaused) return null;
    return _categoryCache[id];
  }

  @override
  Future<FAQItem?> getCachedItem(String id, {FAQItemSource? openFrom}) async {
    _checkNotDestroyed();
    if (_isPaused) return null;
    if (openFrom != null) {
      await _repo.trackItem(id, openFrom);
    }
    return _itemCache[id];
  }

  @override
  Future<FAQStructure?> getStructure(String id) async {
    _checkNotDestroyed();
    if (_isPaused) return null;
    try {
      final structure = await _repo.getStructure(id);
      if (structure != null) _structureCache[id] = structure;
      return structure;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<FAQStructure?> getCachedStructure(String id) async {
    _checkNotDestroyed();
    if (_isPaused) return null;
    return _structureCache[id];
  }

  @override
  Future<FAQItem?> like(FAQItem item) async {
    _checkNotDestroyed();
    if (_isPaused) return null;
    try {
      await _repo.like(item.id);
      return item;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<FAQItem?> dislike(FAQItem item) async {
    _checkNotDestroyed();
    if (_isPaused) return null;
    try {
      await _repo.dislike(item.id);
      return item;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<FAQSearchItem>> search(String query,
      {String? category, int limitOfItems = 0}) async {
    _checkNotDestroyed();
    if (_isPaused) return [];
    try {
      return await _repo.search(query,
          category: category, limitOfItems: limitOfItems);
    } catch (_) {
      return [];
    }
  }
}
