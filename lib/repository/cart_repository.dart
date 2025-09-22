
import 'dart:developer';
import 'package:flutter_ecommerce/model/cart_model.dart';
import 'package:flutter_ecommerce/services/cart_service.dart';

class CartRepository {
  final CartService _cartService;

  CartRepository({CartService? cartService})
      : _cartService = cartService ?? CartService();

  // Créer un nouveau panier pour un utilisateur
  Future<CartModel> createCart(String userId) async {
    try {
      log(' Repository: Création panier pour $userId');
      return await _cartService.createCart(userId);
    } catch (e) {
      log(' Repository error - createCart: $e');
      rethrow;
    }
  }

  // Récupérer un panier par ID
  Future<CartModel> getCart(int cartId) async {
    try {
      log(' Repository: Récupération panier $cartId');
      return await _cartService.getCartById(cartId);
    } catch (e) {
      log(' Repository error - getCart: $e');
      rethrow;
    }
  }

  // Récupérer les produits d'un panier
  Future<List<CartProductModel>> getCartProducts(int cartId) async {
    try {
      log(' Repository: Récupération produits panier $cartId');
      return await _cartService.getCartProducts(cartId);
    } catch (e) {
      log(' Repository error - getCartProducts: $e');
      rethrow;
    }
  }

  // Récupérer le panier complet avec produits
  Future<CartWithProductsModel> getCartWithProducts(int cartId) async {
    try {
      log(' Repository: Récupération panier complet $cartId');
      return await _cartService.getCartWithProducts(cartId);
    } catch (e) {
      log(' Repository error - getCartWithProducts: $e');
      rethrow;
    }
  }

  // Ajouter un produit au panier
  Future<List<CartProductModel>> addProductToCart({
    required int cartId,
    required int productId,
    int quantity = 1,
  }) async {
    try {
      log(' Repository: Ajout produit $productId (qty: $quantity) au panier $cartId');

      final productToAdd = CartProductCreateModel(
        productId: productId,
        quantity: quantity,
      );

      return await _cartService.addProductToCart(cartId, productToAdd);
    } catch (e) {
      log(' Repository error - addProductToCart: $e');
      rethrow;
    }
  }

  // Mettre à jour la quantité d'un produit
  Future<List<CartProductModel>> updateProductQuantity({
    required int cartId,
    required int productId,
    required int newQuantity,
  }) async {
    try {
      log(' Repository: Mise à jour quantité produit $productId -> $newQuantity');

      if (newQuantity <= 0) {
        // Si la quantité est 0 ou négative, supprimer le produit
        return await removeProductFromCart(
          cartId: cartId,
          productId: productId,
        );
      }

      return await _cartService.updateProductQuantity(
        cartId,
        productId,
        newQuantity,
      );
    } catch (e) {
      log('Repository error - updateProductQuantity: $e');
      rethrow;
    }
  }

  // Supprimer un produit du panier
  Future<List<CartProductModel>> removeProductFromCart({
    required int cartId,
    required int productId,
  }) async {
    try {
      log(' Repository: Suppression produit $productId du panier $cartId');
      return await _cartService.removeProductFromCart(cartId, productId);
    } catch (e) {
      log(' Repository error - removeProductFromCart: $e');
      rethrow;
    }
  }

  // Vider complètement le panier
  Future<void> clearCart(int cartId) async {
    try {
      log(' Repository: Vidage panier $cartId');
      await _cartService.clearCart(cartId);
    } catch (e) {
      log(' Repository error - clearCart: $e');
      rethrow;
    }
  }

  // Méthodes utilitaires

  // Calculer le total du panier à partir des produits
  double calculateCartTotal(List<CartProductModel> products) {
    return products.fold(0.0, (total, product) {
      return total + (product.priceAtTime * product.quantity);
    });
  }

  // Obtenir le nombre total d'articles dans le panier
  int getTotalItemsCount(List<CartProductModel> products) {
    return products.fold(0, (total, product) {
      return total + product.quantity;
    });
  }

  // Vérifier si un produit est dans le panier
  bool isProductInCart(List<CartProductModel> products, int productId) {
    return products.any((product) => product.productId == productId);
  }

  // Obtenir la quantité d'un produit spécifique dans le panier
  int getProductQuantity(List<CartProductModel> products, int productId) {
    try {
      final product = products.firstWhere(
            (product) => product.productId == productId,
      );
      return product.quantity;
    } catch (e) {
      return 0; // Produit non trouvé
    }
  }

  // Incrémenter la quantité d'un produit (ou l'ajouter s'il n'existe pas)
  Future<List<CartProductModel>> incrementProductQuantity({
    required int cartId,
    required int productId,
    int incrementBy = 1,
  }) async {
    try {
      log(' Repository: Incrémentation produit $productId (+$incrementBy)');

      // Récupérer d'abord les produits actuels
      final currentProducts = await getCartProducts(cartId);
      final currentProduct = currentProducts.cast<CartProductModel?>().firstWhere(
            (product) => product?.productId == productId,
        orElse: () => null,
      );

      if (currentProduct != null) {
        // Le produit existe, mettre à jour sa quantité
        final newQuantity = currentProduct.quantity + incrementBy;
        return await updateProductQuantity(
          cartId: cartId,
          productId: productId,
          newQuantity: newQuantity,
        );
      } else {
        // Le produit n'existe pas, l'ajouter
        return await addProductToCart(
          cartId: cartId,
          productId: productId,
          quantity: incrementBy,
        );
      }
    } catch (e) {
      log('Repository error - incrementProductQuantity: $e');
      rethrow;
    }
  }

  // Décrémenter la quantité d'un produit
  Future<List<CartProductModel>> decrementProductQuantity({
    required int cartId,
    required int productId,
    int decrementBy = 1,
  }) async {
    try {
      log(' Repository: Décrémentation produit $productId (-$decrementBy)');

      // Récupérer d'abord les produits actuels
      final currentProducts = await getCartProducts(cartId);
      final currentProduct = currentProducts.cast<CartProductModel?>().firstWhere(
            (product) => product?.productId == productId,
        orElse: () => null,
      );

      if (currentProduct != null) {
        final newQuantity = currentProduct.quantity - decrementBy;
        return await updateProductQuantity(
          cartId: cartId,
          productId: productId,
          newQuantity: newQuantity,
        );
      } else {
        // Le produit n'existe pas, retourner la liste actuelle
        return currentProducts;
      }
    } catch (e) {
      log(' Repository error - decrementProductQuantity: $e');
      rethrow;
    }
  }
}