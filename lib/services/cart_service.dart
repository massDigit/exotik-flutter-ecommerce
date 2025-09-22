import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_ecommerce/model/cart_model.dart';

class CartService {
  static const String baseUrl = 'https://api-ecom-flutter.jboureux.fr';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<CartModel> createCart(String userId) async {
    try {
      log('🛒 Création d\'un nouveau panier pour l\'utilisateur: $userId');

      final cartData = {
        'user_id': userId,
        'status': 'active',
        'total_price': 0.0,
      };

      final response = await http.get(
        Uri.parse('$baseUrl/carts/user/$userId/active'),
        headers: _headers,
      );

      log('📊 Status création panier: ${response.statusCode}');
      log('📦 Response création panier: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return CartModel.fromJson(jsonData);
      } else {
        throw Exception('Erreur lors de la création du panier: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Erreur création panier: $e');
      throw Exception('Erreur de connexion lors de la création du panier: $e');
    }
  }

  // Récupérer un panier par ID
  Future<CartModel> getCartById(int cartId) async {
    try {
      log('🔍 Récupération du panier ID: $cartId');

      final response = await http.get(
        Uri.parse('$baseUrl/carts/$cartId'),
        headers: _headers,
      );

      log('📊 Status récupération panier: ${response.statusCode}');
      log('📦 Response récupération panier: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return CartModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Panier non trouvé');
      } else {
        throw Exception('Erreur lors de la récupération du panier: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Erreur récupération panier: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer les produits d'un panier
  Future<List<CartProductModel>> getCartProducts(int cartId) async {
    try {
      log('🛍️ Récupération des produits du panier ID: $cartId');

      final response = await http.get(
        Uri.parse('$baseUrl/carts/$cartId/products'),
        headers: _headers,
      );

      log('📊 Status récupération produits: ${response.statusCode}');
      log('📦 Response récupération produits: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        // Vérifier si la réponse est une liste ou un objet
        if (jsonData is List) {
          return jsonData
              .map((product) => CartProductModel.fromJson(product))
              .toList();
        } else if (jsonData is Map<String, dynamic>) {
          // Si c'est un objet, peut-être avec une propriété products
          if (jsonData.containsKey('products') && jsonData['products'] is List) {
            return (jsonData['products'] as List)
                .map((product) => CartProductModel.fromJson(product))
                .toList();
          } else {
            // Retourner une liste vide si pas de produits
            return [];
          }
        } else {
          throw Exception('Format de réponse inattendu: ${jsonData.runtimeType}');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Panier non trouvé');
      } else {
        throw Exception('Erreur lors de la récupération des produits: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Erreur récupération produits panier: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Ajouter un produit au panier
  Future<List<CartProductModel>> addProductToCart(
      int cartId,
      CartProductCreateModel product,
      ) async {
    try {
      log('➕ Ajout produit au panier $cartId: ${product.productId} (qty: ${product.quantity})');

      final response = await http.post(
        Uri.parse('$baseUrl/carts/$cartId/products'),
        headers: _headers,
        body: json.encode(product.toJson()),
      );

      log('📊 Status ajout produit: ${response.statusCode}');
      log('📦 Response ajout produit: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseProductsResponse(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Panier ou produit non trouvé');
      } else {
        throw Exception('Erreur lors de l\'ajout du produit: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Erreur ajout produit: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Mettre à jour la quantité d'un produit dans le panier
  Future<List<CartProductModel>> updateProductQuantity(
      int cartId,
      int productId,
      int newQuantity,
      ) async {
    try {
      log('🔄 Mise à jour quantité produit $productId dans panier $cartId: $newQuantity');

      final updateData = {
        'quantity': newQuantity,
      };

      final response = await http.patch(
        Uri.parse('$baseUrl/carts/$cartId/products/$productId'),
        headers: _headers,
        body: json.encode(updateData),
      );


      log('test update data: ${updateData.toString()}');

      log('📊 Status mise à jour: ${response.statusCode}');
      log('📦 Response mise à jour: ${response.body}');

      if (response.statusCode == 200) {
        return _parseProductsResponse(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Panier ou produit non trouvé');
      } else {
        throw Exception('Erreur lors de la mise à jour: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Erreur mise à jour quantité: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Supprimer un produit du panier
  Future<List<CartProductModel>> removeProductFromCart(
      int cartId,
      int productId,
      ) async {
    try {
      log('🗑️ Suppression produit $productId du panier $cartId');

      final response = await http.delete(
        Uri.parse('$baseUrl/carts/$cartId/products/$productId'),
        headers: _headers,
      );

      log('📊 Status suppression: ${response.statusCode}');
      log('📦 Response suppression: ${response.body}');
      log('📝 Response type: ${response.body.runtimeType}');

      if (response.statusCode == 200) {
        return _parseProductsResponse(response.body);
      } else if (response.statusCode == 204) {
        // Pas de contenu, retourner une liste vide
        log('✅ Produit supprimé avec succès (no content)');
        return [];
      } else if (response.statusCode == 404) {
        throw Exception('Panier ou produit non trouvé');
      } else {
        throw Exception('Erreur lors de la suppression: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Erreur suppression produit: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Vider complètement le panier - Utilise DELETE sur /clear
  Future<void> clearCart(int cartId) async {
    try {
      log('🧹 Vidage du panier $cartId via endpoint /clear');

      final response = await http.delete(
        Uri.parse('$baseUrl/carts/$cartId/clear'),
        headers: _headers,
      );

      log('📊 Status vidage panier: ${response.statusCode}');
      log('📦 Response vidage panier: ${response.body}');

      if (response.statusCode == 200) {
        log('✅ Panier vidé avec succès');
        return;
      } else if (response.statusCode == 422) {
        throw Exception('Erreur de validation: panier non trouvé ou invalide');
      } else if (response.statusCode == 404) {
        throw Exception('Panier non trouvé');
      } else {
        throw Exception('Erreur lors du vidage du panier: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Erreur vidage panier: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer le panier complet avec ses produits (méthode utilitaire)
  Future<CartWithProductsModel> getCartWithProducts(int cartId) async {
    try {
      log('🔄 Récupération panier complet ID: $cartId');

      // Récupérer les infos du panier et ses produits en parallèle
      final results = await Future.wait([
        getCartById(cartId),
        getCartProducts(cartId),
      ]);

      final cart = results[0] as CartModel;
      final products = results[1] as List<CartProductModel>;

      return CartWithProductsModel(
        cart: cart,
        products: products,
      );
    } catch (e) {
      log('❌ Erreur récupération panier complet: $e');
      rethrow;
    }
  }

  // Méthode utilitaire pour parser les réponses de produits
  List<CartProductModel> _parseProductsResponse(String responseBody) {
    try {
      final dynamic jsonData = json.decode(responseBody);

      log('🔍 Parsing response type: ${jsonData.runtimeType}');
      log('🔍 Parsing response data: $jsonData');

      if (jsonData is List) {
        // La réponse est directement une liste
        return jsonData
            .map((product) => CartProductModel.fromJson(product))
            .toList();
      } else if (jsonData is Map<String, dynamic>) {
        // La réponse est un objet
        if (jsonData.containsKey('products') && jsonData['products'] is List) {
          // L'objet contient une propriété products qui est une liste
          return (jsonData['products'] as List)
              .map((product) => CartProductModel.fromJson(product))
              .toList();
        } else if (jsonData.containsKey('data') && jsonData['data'] is List) {
          // L'objet contient une propriété data qui est une liste
          return (jsonData['data'] as List)
              .map((product) => CartProductModel.fromJson(product))
              .toList();
        } else {
          // L'objet ne contient pas de liste de produits, retourner liste vide
          log('⚠️ Objet sans liste de produits, retour liste vide');
          return [];
        }
      } else {
        // Type inattendu
        log('⚠️ Type de réponse inattendu: ${jsonData.runtimeType}');
        return [];
      }
    } catch (e) {
      log('❌ Erreur parsing response: $e');
      log('📦 Response body was: $responseBody');
      return [];
    }
  }
}