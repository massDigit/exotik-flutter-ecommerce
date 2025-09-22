
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/model/cart_model.dart';
import 'package:flutter_ecommerce/repository/cart_repository.dart';

class CartController extends ChangeNotifier {
  final CartRepository _cartRepository;

  CartController({CartRepository? cartRepository})
      : _cartRepository = cartRepository ?? CartRepository();

  // États
  CartModel? _currentCart;
  List<CartProductModel> _cartProducts = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  CartModel? get currentCart => _currentCart;
  List<CartProductModel> get cartProducts => _cartProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCart => _currentCart != null;
  bool get isEmpty => _cartProducts.isEmpty;
  int get totalItems => _cartRepository.getTotalItemsCount(_cartProducts);
  double get totalPrice => _cartRepository.calculateCartTotal(_cartProducts);

  // Utilitaires pour vérifier les produits
  bool isProductInCart(int productId) {
    return _cartRepository.isProductInCart(_cartProducts, productId);
  }

  int getProductQuantity(int productId) {
    return _cartRepository.getProductQuantity(_cartProducts, productId);
  }

  // Créer un nouveau panier
  Future<void> createCart(String userId) async {
    try {
      _setLoading(true);
      _clearError();


      _currentCart = await _cartRepository.createCart(userId);
      await refreshCart();


      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la création du panier');
      _setLoading(false);
    }
  }

  // Charger un panier existant
  Future<void> loadCart(int cartId) async {
    try {
      _setLoading(true);
      _clearError();


      final cartWithProducts = await _cartRepository.getCartWithProducts(cartId);

      // _currentCart = cartWithProducts.cart;
      _cartProducts = cartWithProducts.products;


      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement du panier');
      _setLoading(false);
    }
  }

  // Actualiser les données du panier
  Future<void> refreshCart() async {
    if (_currentCart?.id != null) {
      await loadCart(_currentCart!.id!);
    }
  }

  // Ajouter un produit au panier
  Future<void> addProduct({
    required int productId,
    int quantity = 1,
  }) async {
    if (_currentCart?.id == null) {
      _setError('Aucun panier actif');
      return;
    }

    try {
      _setLoading(true);
      _clearError();


      _cartProducts = await _cartRepository.addProductToCart(
        cartId: _currentCart!.id!,
        productId: productId,
        quantity: quantity,
      );


      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de l\'ajout du produit');
      _setLoading(false);
    }
  }

  // Mettre à jour la quantité d'un produit
  Future<void> updateProductQuantity({
    required int productId,
    required int newQuantity,
  }) async {
    if (_currentCart?.id == null) {
      _setError('Aucun panier actif');
      return;
    }

    try {
      _setLoading(true);
      _clearError();


      _cartProducts = await _cartRepository.updateProductQuantity(
        cartId: _currentCart!.id!,
        productId: productId,
        newQuantity: newQuantity,
      );


      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la mise à jour');
      _setLoading(false);
    }
  }

  // Incrémenter la quantité d'un produit
  Future<void> incrementProduct(int productId) async {
    if (_currentCart?.id == null) {
      _setError('Aucun panier actif');
      return;
    }

    try {
      _setLoading(true);
      _clearError();


      _cartProducts = await _cartRepository.incrementProductQuantity(
        cartId: _currentCart!.id!,
        productId: productId,
      );

      await refreshCart();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de l\'incrémentation');
      _setLoading(false);
    }
  }

  // Décrémenter la quantité d'un produit
  Future<void> decrementProduct(int productId) async {
    if (_currentCart?.id == null) {
      _setError('Aucun panier actif');
      return;
    }

    try {
      _setLoading(true);
      _clearError();


      _cartProducts = await _cartRepository.decrementProductQuantity(
        cartId: _currentCart!.id!,
        productId: productId,
      );

      await refreshCart();


      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la décrémentation');
      _setLoading(false);
    }
  }

  // Supprimer un produit du panier
  Future<void> removeProduct(int productId) async {
    if (_currentCart?.id == null) {
      _setError('Aucun panier actif');
      return;
    }

    try {
      _setLoading(true);
      _clearError();


      _cartProducts = await _cartRepository.removeProductFromCart(
        cartId: _currentCart!.id!,
        productId: productId,
      );



      await refreshCart();


      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la suppression');
      _setLoading(false);
    }
  }

  // Vider complètement le panier
  Future<void> clearCart() async {
    if (_currentCart?.id == null) {
      _setError('Aucun panier actif');
      return;
    }

    try {
      _setLoading(true);
      _clearError();


      await _cartRepository.clearCart(_currentCart!.id!);
      _cartProducts.clear();


      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du vidage du panier');
      _setLoading(false);
    }
  }

  // Méthodes pour gérer rapidement les quantités avec confirmation
  Future<void> setProductQuantity({
    required int productId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      await removeProduct(productId);
    } else {
      await updateProductQuantity(
        productId: productId,
        newQuantity: quantity,
      );
    }
  }

  // Ajouter ou incrémenter un produit (logique intelligente)
  Future<void> addOrIncrementProduct(int productId, {int quantity = 1}) async {
    if (isProductInCart(productId)) {
      // Si le produit est déjà dans le panier, incrémenter sa quantité
      for (int i = 0; i < quantity; i++) {
        await incrementProduct(productId);
      }
    } else {
      // Sinon, l'ajouter avec la quantité spécifiée
      await addProduct(productId: productId, quantity: quantity);
    }
  }

  // Obtenir un produit spécifique du panier
  CartProductModel? getCartProduct(int productId) {
    try {
      return _cartProducts.firstWhere(
            (product) => product.productId == productId,
      );
    } catch (e) {
      return null;
    }
  }

  // Calculer le sous-total pour un produit spécifique
  double getProductSubtotal(int productId) {
    final product = getCartProduct(productId);
    if (product != null) {
      return product.priceAtTime * product.quantity;
    }
    return 0.0;
  }

  // Réinitialiser l'état du controller
  void reset() {
    _currentCart = null;
    _cartProducts.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // Méthodes privées pour gérer l'état
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      notifyListeners(); // Notifier immédiatement quand on commence à charger
    }
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Validation des données
  bool _validateCartOperation() {
    if (_currentCart?.id == null) {
      _setError('Aucun panier actif');
      return false;
    }
    return true;
  }

  // Méthodes pour les statistiques du panier
  Map<String, dynamic> getCartStats() {
    return {
      'totalItems': totalItems,
      'totalPrice': totalPrice,
      'uniqueProducts': _cartProducts.length,
      'isEmpty': isEmpty,
      'cartId': _currentCart?.id,
      'userId': _currentCart?.userId,
      'status': _currentCart?.status,
    };
  }

  // Rechercher des produits dans le panier
  List<CartProductModel> searchInCart(String query) {
    if (query.isEmpty) return _cartProducts;

    // Cette méthode pourrait être étendue pour rechercher par nom de produit
    // si vous avez accès aux détails des produits
    return _cartProducts.where((product) {
      return product.productId.toString().contains(query);
    }).toList();
  }

  // Obtenir les produits triés par différents critères
  List<CartProductModel> getSortedProducts({
    String sortBy = 'productId', // 'productId', 'quantity', 'price', 'total'
    bool ascending = true,
  }) {
    final sortedProducts = List<CartProductModel>.from(_cartProducts);

    sortedProducts.sort((a, b) {
      int comparison = 0;

      switch (sortBy) {
        case 'quantity':
          comparison = a.quantity.compareTo(b.quantity);
          break;
        case 'price':
          comparison = a.priceAtTime.compareTo(b.priceAtTime);
          break;
        case 'total':
          final totalA = a.priceAtTime * a.quantity;
          final totalB = b.priceAtTime * b.quantity;
          comparison = totalA.compareTo(totalB);
          break;
        case 'productId':
        default:
          comparison = a.productId.compareTo(b.productId);
          break;
      }

      return ascending ? comparison : -comparison;
    });

    return sortedProducts;
  }

  @override
  void dispose() {
    // Nettoyer les ressources si nécessaire
    super.dispose();
  }
}