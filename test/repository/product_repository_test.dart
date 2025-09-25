// test/repositories/product_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/model/product_model.dart';
import 'package:flutter_ecommerce/repository/product_repository.dart';
import 'package:flutter_ecommerce/services/product_service.dart';

/// Fake ProductService pour isoler le ProductRepository (aucun réseau)
class _FakeProductService extends ProductService {
  String? lastCall;
  int? lastId;
  int? lastPage;
  int? lastLimit;
  String? lastCategory;
  String? lastSearch;

  dynamic returnValue;

  @override
  void test() {
    lastCall = 'test';
  }

  @override
  Future<PaginatedProductsResponse> getProducts({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
  }) async {
    lastCall = 'getProducts';
    lastPage = page;
    lastLimit = limit;
    lastCategory = category;
    lastSearch = search;
    return returnValue as PaginatedProductsResponse;
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    lastCall = 'getProductById';
    lastId = id;
    return returnValue as ProductModel;
  }

  @override
  Future<List<String>> getCategories() async {
    lastCall = 'getCategories';
    return returnValue as List<String>;
  }
}

void main() {
  group('ProductRepository', () {
    late _FakeProductService fake;
    late ProductRepository repo;

    setUp(() {
      fake = _FakeProductService();
      repo = ProductRepository(fake);
    });

    test('test() appelle service.test()', () {
      repo.test();
      expect(fake.lastCall, 'test');
    });

    test('getProducts() relaie paramètres et retourne la réponse', () async {
      final response = PaginatedProductsResponse(
        products: [
          ProductModel(
            id: 1,
            title: 'iPhone',
            price: 999.0,
            description: 'Apple smartphone',
            category: 'Electronics',
            thumbnail: 'thumb.png',
            images: const [],
          ),
        ],
        total: 1,
        // Pas de `page`/`limit` dans ce constructeur → on utilise :
        currentPage: 2,
        totalPages: 1,
        itemsPerPage: 5,
      );

      fake.returnValue = response;

      final res = await repo.getProducts(
        page: 2,
        limit: 5,
        category: 'Electronics',
        search: 'iPh',
      );

      // vérif pass-through des paramètres
      expect(fake.lastCall, 'getProducts');
      expect(fake.lastPage, 2);
      expect(fake.lastLimit, 5);
      expect(fake.lastCategory, 'Electronics');
      expect(fake.lastSearch, 'iPh');

      // vérif contenu réponse
      expect(res.total, 1);
      expect(res.products.single.title, 'iPhone');
      expect(res.currentPage, 2);
      expect(res.totalPages, 1);
      expect(res.itemsPerPage, 5);
    });

    test('getProductById() relaie id et retourne le produit', () async {
      final product = ProductModel(
        id: 42,
        title: 'Samsung Galaxy',
        price: 899.0,
        description: 'Samsung smartphone',
        category: 'Electronics',
        thumbnail: 'thumb.png',
        images: const [],
      );
      fake.returnValue = product;

      final res = await repo.getProductById(42);

      expect(fake.lastCall, 'getProductById');
      expect(fake.lastId, 42);
      expect(res.title, 'Samsung Galaxy');
    });

    test('getCategories() retourne les catégories', () async {
      fake.returnValue = ['Electronics', 'Clothing'];

      final res = await repo.getCategories();

      expect(fake.lastCall, 'getCategories');
      expect(res, ['Electronics', 'Clothing']);
    });
  });
}
