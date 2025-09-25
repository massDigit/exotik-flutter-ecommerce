import 'package:flutter_ecommerce/repository/product_repository.dart';
import 'package:flutter_ecommerce/services/product_service.dart';
import 'package:flutter_ecommerce/model/product_model.dart';
import 'package:flutter/foundation.dart';

class ProductController {
  final ProductRepository _repository = ProductRepository(ProductService());

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get allProducts => List.unmodifiable(_allProducts);
  List<ProductModel> get filteredProducts => List.unmodifiable(_filteredProducts);
  List<String> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void Function()? onStateChanged;

  void _notifyStateChanged() {
    onStateChanged?.call();
  }

  Future<void> loadAllProducts() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _notifyStateChanged();

      final response = await _repository.getProducts(page: 1, limit: 100);

      _allProducts = response.products;
      _filteredProducts = response.products;
      _isLoading = false;

      _notifyStateChanged();

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _notifyStateChanged();
    }
  }

  Future<void> loadCategories() async {
    try {
      final loadedCategories = await _repository.getCategories();
      _categories = loadedCategories;
      _notifyStateChanged();
    } catch (e) {
      debugPrint('Erreur lors du chargement des catégories: $e');
    }
  }

  void applyFilters({String? searchQuery, String? selectedCategory}) {
    List<ProductModel> filtered = _allProducts;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            product.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
            product.description.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    if (selectedCategory != null && selectedCategory.isNotEmpty) {
      filtered = filtered.where((product) =>
      product.category == selectedCategory).toList();
    }

    _filteredProducts = filtered;
    _notifyStateChanged();
  }

  void clearFilters() {
    _filteredProducts = _allProducts;
    _notifyStateChanged();
  }

  void searchProducts(String query) {
    applyFilters(searchQuery: query);
  }

  void filterByCategory(String category) {
    applyFilters(selectedCategory: category);
  }

  // Récupérer un produit par ID non utilisé pour le moment
  Future<ProductModel?> getProductById(int id) async {
    try {
      return await _repository.getProductById(id);
    } catch (e) {
      debugPrint('Erreur lors de la récupération du produit $id: $e');
      return null;
    }
  }

  // Nettoyer les ressources
  void dispose() {
    onStateChanged = null;
  }
}
