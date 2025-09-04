import 'package:flutter_ecommerce/model/product_model.dart';
import 'package:flutter_ecommerce/services/product_service.dart';

class ProductRepository {
  final ProductService _service;

  ProductRepository(this._service);

  void test() {
    _service.test();
  }

  // Récupérer les produits avec pagination
  Future<PaginatedProductsResponse> getProducts({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
  }) async {
    return await _service.getProducts(
      page: page,
      limit: limit,
      category: category,
      search: search,
    );
  }

  // Récupérer un produit par ID
  Future<ProductModel> getProductById(int id) async {
    return await _service.getProductById(id);
  }

  // Récupérer les catégories
  Future<List<String>> getCategories() async {
    return await _service.getCategories();
  }
}