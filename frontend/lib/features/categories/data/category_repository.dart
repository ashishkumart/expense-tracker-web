import '../../../core/network/api_client.dart';
import '../../../shared/models/category.dart';

class CategoryRepository {
  const CategoryRepository(this._api);
  final ApiClient _api;

  Future<List<Category>> getAll() async {
    final data = await _api.get('/categories') as List<dynamic>;
    return data
        .map((item) => Category.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Category> create({
    required String name,
    required TransactionType type,
    required String color,
  }) async {
    final data = await _api.post('/categories', {
      'name': name,
      'type': type.apiValue,
      'color': color,
    });
    return Category.fromJson(data as Map<String, dynamic>);
  }

  Future<Category> update(Category category) async {
    final data = await _api.put(
      '/categories/${category.id}',
      category.toRequest(),
    );
    return Category.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _api.delete('/categories/$id');
}
