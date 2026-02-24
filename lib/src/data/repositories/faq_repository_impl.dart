import 'package:webim/src/data/datasources/api_client.dart';
import 'package:webim/src/domain/entities/faq_category.dart';
import 'package:webim/src/domain/entities/faq_item.dart';
import 'package:webim/src/domain/entities/faq_item_source.dart';
import 'package:webim/src/domain/entities/faq_structure.dart';
import 'package:webim/src/domain/entities/faq_search_item.dart';
import 'package:webim/src/domain/repositories/faq_repository.dart';

/// FAQ paths aligned with Swift FAQActions.ServerPathSuffix.
/// Base URL must be root (e.g. https://demo.webim.ru), without /api/v1.
class _FaqPaths {
  static const categories = '/webim/api/v1/faq/category';
  static const category = '/services/faq/v1/category';
  static const item = '/services/faq/v1/item';
  static const structure = '/services/faq/v1/structure';
  static const search = '/services/faq/v1/search';
  static const like = '/services/faq/v1/like';
  static const dislike = '/services/faq/v1/dislike';
  static const track = '/services/faq/v1/track';
}

class FAQRepositoryImpl implements FAQRepository {
  FAQRepositoryImpl(this._client);

  static String get _deviceId {
    if (_deviceIdHolder.isEmpty) {
      const chars = 'abcdef0123456789';
      final r = DateTime.now().microsecondsSinceEpoch;
      _deviceIdHolder = List.generate(32, (i) => chars[(r + i) % chars.length]).join();
    }
    return _deviceIdHolder;
  }
  static String _deviceIdHolder = '';

  final ApiClient _client;

  @override
  Future<List<FAQCategory>> fetchAll() async {
    final query = <String, String>{
      'app': 'mobile',
      'platform': 'flutter',
      'lang': 'en',
    };
    final json = await _client.get(_FaqPaths.categories, query: query);
    final list = json['categories'] as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => FAQCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<FAQCategory>> getRootCategories({
    String? departmentId,
    String? categoryId,
  }) async {
    final query = <String, String>{
      'app': 'mobile',
      'platform': 'flutter',
      'lang': 'en',
    };
    if (departmentId != null) query['department-key'] = departmentId;
    if (categoryId != null) query['categoryid'] = categoryId;
    final json = await _client.get(_FaqPaths.categories, query: query);
    final list = json['categories'] as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => FAQCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<FAQCategory>> getCategoriesForApplication({
    String? application,
    String? language,
    String? departmentKey,
  }) async {
    final query = <String, String>{
      'app': application ?? 'mobile',
      'platform': 'flutter',
      'lang': language ?? 'en',
    };
    if (departmentKey != null) query['department-key'] = departmentKey;
    final json = await _client.get(_FaqPaths.categories, query: query);
    final list = json['categories'] as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => FAQCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FAQCategory> fetchById(String id) async {
    final query = <String, String>{
      'categoryid': id,
      'userid': _deviceId,
    };
    final json = await _client.get(_FaqPaths.category, query: query);
    return FAQCategory.fromJson(json);
  }

  @override
  Future<FAQItem> fetchItemById(String id) async {
    final query = <String, String>{
      'itemid': id,
      'userid': _deviceId,
    };
    final json = await _client.get(_FaqPaths.item, query: query);
    return FAQItem.fromJson(json);
  }

  @override
  Future<void> trackItem(String itemId, FAQItemSource openFrom) async {
    final source = openFrom == FAQItemSource.search ? 'search' : 'tree';
    await _client.post(
      _FaqPaths.track,
      body: {'itemid': itemId, 'open': source},
    );
  }

  @override
  Future<FAQStructure?> getStructure(String categoryId) async {
    try {
      final json = await _client.get(
        _FaqPaths.structure,
        query: {'categoryid': categoryId},
      );
      return FAQStructure.fromJson(Map<String, dynamic>.from(json));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<FAQItem?> like(String itemId) async {
    try {
      await _client.post(
        _FaqPaths.like,
        body: {'itemid': itemId, 'userid': _deviceId},
      );
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<FAQItem?> dislike(String itemId) async {
    try {
      await _client.post(
        _FaqPaths.dislike,
        body: {'itemid': itemId, 'userid': _deviceId},
      );
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<FAQSearchItem>> search(String query,
      {String? category, int limitOfItems = 0}) async {
    try {
      final queryParams = <String, String>{
        'query': query,
        'limit': limitOfItems.toString(),
      };
      if (category != null && category.isNotEmpty) {
        queryParams['categoryid'] = category;
      }
      final json = await _client.get(_FaqPaths.search, query: queryParams);
      final rawList = json['items'];
      final list = rawList is List ? rawList : <dynamic>[];
      return list
          .map((e) => FAQSearchItem.fromJson(
              e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
