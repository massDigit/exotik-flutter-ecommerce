import 'dart:convert';
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

      final response = await http.get(
        Uri.parse('$baseUrl/carts/user/$userId/active'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return CartModel.fromJson(jsonData);
      } else {
        throw Exception('Erreur lors de la création du panier: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion lors de la création du panier: $e');
    }
  }


  Future<CartModel> getCartById(int cartId) async {
    try {

      final response = await http.get(
        Uri.parse('$baseUrl/carts/$cartId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return CartModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Panier non trouvé');
      } else {
        throw Exception('Erreur lors de la récupération du panier: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<List<CartProductModel>> getCartProducts(int cartId) async {
    try {

      final response = await http.get(
        Uri.parse('$baseUrl/carts/$cartId/products'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        if (jsonData is List) {
          return jsonData
              .map((product) => CartProductModel.fromJson(product))
              .toList();
        } else if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('products') && jsonData['products'] is List) {
            return (jsonData['products'] as List)
                .map((product) => CartProductModel.fromJson(product))
                .toList();
          } else {
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
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<List<CartProductModel>> addProductToCart(
      int cartId,
      CartProductCreateModel product,
      ) async {
    try {

      final response = await http.post(
        Uri.parse('$baseUrl/carts/$cartId/products'),
        headers: _headers,
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseProductsResponse(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Panier ou produit non trouvé');
      } else {
        throw Exception('Erreur lors de l\'ajout du produit: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<List<CartProductModel>> updateProductQuantity(
      int cartId,
      int productId,
      int newQuantity,
      ) async {
    try {

      final updateData = {
        'quantity': newQuantity,
      };

      final response = await http.patch(
        Uri.parse('$baseUrl/carts/$cartId/products/$productId'),
        headers: _headers,
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        return _parseProductsResponse(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Panier ou produit non trouvé');
      } else {
        throw Exception('Erreur lors de la mise à jour: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<List<CartProductModel>> removeProductFromCart(
      int cartId,
      int productId,
      ) async {
    try {

      final response = await http.delete(
        Uri.parse('$baseUrl/carts/$cartId/products/$productId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return _parseProductsResponse(response.body);
      } else if (response.statusCode == 204) {
        return [];
      } else if (response.statusCode == 404) {
        throw Exception('Panier ou produit non trouvé');
      } else {
        throw Exception('Erreur lors de la suppression: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<void> clearCart(int cartId) async {
    try {

      final response = await http.delete(
        Uri.parse('$baseUrl/carts/$cartId/clear'),
        headers: _headers,
      );


      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 422) {
        throw Exception('Erreur de validation: panier non trouvé ou invalide');
      } else if (response.statusCode == 404) {
        throw Exception('Panier non trouvé');
      } else {
        throw Exception('Erreur lors du vidage du panier: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<CartWithProductsModel> getCartWithProducts(int cartId) async {
    try {

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
      rethrow;
    }
  }

  List<CartProductModel> _parseProductsResponse(String responseBody) {
    try {
      final dynamic jsonData = json.decode(responseBody);


      if (jsonData is List) {
        return jsonData
            .map((product) => CartProductModel.fromJson(product))
            .toList();
      } else if (jsonData is Map<String, dynamic>) {
        if (jsonData.containsKey('products') && jsonData['products'] is List) {
          return (jsonData['products'] as List)
              .map((product) => CartProductModel.fromJson(product))
              .toList();
        } else if (jsonData.containsKey('data') && jsonData['data'] is List) {
          return (jsonData['data'] as List)
              .map((product) => CartProductModel.fromJson(product))
              .toList();
        } else {

          return [];
        }
      } else {
        return [];
      }
    } catch (e) {

      return [];
    }
  }
}