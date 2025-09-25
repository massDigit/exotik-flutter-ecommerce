import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_ecommerce/model/product_model.dart';
import 'package:flutter/foundation.dart';


class ProductService {
  static const String baseUrl = 'https://api-ecom-flutter.jboureux.fr';

  void test() {
    debugPrint("ProductService");
  }

  // Récupérer tous les produits avec pagination
  Future<PaginatedProductsResponse> getProducts({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
  }) async {
    try {
      // Calculer l'offset basé sur la page
      int offset = (page - 1) * limit;

      // Construire l'URL avec les paramètres
      Map<String, String> queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
      };



      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return PaginatedProductsResponse.fromJson(jsonData, page, limit);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer un produit par ID
  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ProductModel.fromJson(jsonData);
      } else {
        throw Exception('Produit non trouvé: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer toutes les catégories (pour les filtres)
  Future<List<String>> getCategories() async {
    try {
      log('🔍 Début de getCategories()');
      final response = await http.get(
        Uri.parse('$baseUrl/categories'), // Récupérer beaucoup pour avoir toutes les catégories
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      log('Status code: ${response.statusCode}');
      log('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

       return jsonData.cast<String>();

      } else {
        throw Exception('Erreur lors du chargement des catégories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}