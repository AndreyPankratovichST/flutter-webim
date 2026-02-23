import 'package:webim/src/data/datasources/api_client.dart';
import 'package:webim/src/domain/entities/faq_category.dart';
import 'package:webim/src/domain/entities/faq_item.dart';
import 'package:webim/src/domain/repositories/faq_repository.dart';

class FAQRepositoryImpl implements FAQRepository {
  final ApiClient _client;

  FAQRepositoryImpl(this._client);

  @override
  Future<List<FAQCategory>> fetchAll() async {
    final json = await _client.get('/faq/list');
    final categories = (json['categories'] as List<dynamic>)
        .map((e) => FAQCategory.fromJson(e as Map<String, dynamic>))
        .toList();
    return categories;
  }

  @override
  Future<FAQCategory> fetchById(String id) async {
    final json = await _client.get('/faq/category', query: {'id': id});
    return FAQCategory.fromJson(json);
  }

  @override
  Future<FAQItem> fetchItemById(String id) async {
    final json = await _client.get('/faq/item', query: {'id': id});
    return FAQItem.fromJson(json);
  }
}
