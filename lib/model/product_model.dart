class ProductModel {
  final int id;
  final String title;
  final double price;
  final String thumbnail;
  final List<String> images;
  final String description;
  final String category;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.images,
    required this.description,
    required this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      thumbnail: json['thumbnail'],
      images: List<String>.from(json['images'] ?? []),
      description: json['description'],
      category: json['category'],
    );
  }
}

// 2. Modèle pour la réponse paginée
class PaginatedProductsResponse {
  final List<ProductModel> products;
  final int total;
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;

  PaginatedProductsResponse({
    required this.products,
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
  });

  factory PaginatedProductsResponse.fromJson(Map<String, dynamic> json, int page, int limit) {
    final products = (json['products'] as List)
        .map((product) => ProductModel.fromJson(product))
        .toList();

    final total = json['total'];
    final totalPages = (total / limit).ceil();

    return PaginatedProductsResponse(
      products: products,
      total: total,
      currentPage: page,
      totalPages: totalPages,
      itemsPerPage: limit,
    );
  }
}
