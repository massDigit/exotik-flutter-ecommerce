
class CartModel {
  final int? id;
  final String userId;
  final String status;
  final double totalPrice;

  CartModel({
    this.id,
    required this.userId,
    this.status = 'active',
    this.totalPrice = 0.0,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'],
      userId: json['user_id'],
      status: json['status'] ?? 'active',
      totalPrice: (json['total_price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'status': status,
      'total_price': totalPrice,
    };
  }

  CartModel copyWith({
    int? id,
    String? userId,
    String? status,
    double? totalPrice,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  String toString() {
    return 'CartModel(id: $id, userId: $userId, status: $status, totalPrice: $totalPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartModel &&
        other.id == id &&
        other.userId == userId &&
        other.status == status &&
        other.totalPrice == totalPrice;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    userId.hashCode ^
    status.hashCode ^
    totalPrice.hashCode;
  }
}

class CartProductModel {
  final int cartId;
  final int productId;
  final int quantity;
  final String title;
  final List<String>? imageUrls;
  final String thumbnail ;
  final double priceAtTime;

  CartProductModel({
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.title,
    this.imageUrls,
    required this.thumbnail,
    required this.priceAtTime,
  });

  factory CartProductModel.fromJson(Map<String, dynamic> json) {
    return CartProductModel(
      cartId: json['cart_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      title: json['product_name'],
      imageUrls: json['product_images'] != null
          ? List<String>.from(json['product_images'])
          : null,
      thumbnail : json['product_thumbnail'],
      priceAtTime: (json['price_at_time']).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_id': cartId,
      'product_id': productId,
      'quantity': quantity,
      'product_name': title,
      'product_images': imageUrls,
      'product_thumbnail':thumbnail,
      'price_at_time': priceAtTime,
    };
  }

  CartProductModel copyWith({
    int? cartId,
    int? productId,
    int? quantity,
    List<String>? imageUrls,
    String ? thumbnail,
    String? title,

    double? priceAtTime,
  }) {
    return CartProductModel(
      cartId: cartId ?? this.cartId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      title: title ?? this.title,
      imageUrls: imageUrls ?? this.imageUrls,
      thumbnail: thumbnail ?? this.thumbnail,
      priceAtTime: priceAtTime ?? this.priceAtTime,
    );
  }

  @override
  String toString() {
    return 'CartProductModel(cartId: $cartId, productId: $productId, quantity: $quantity, priceAtTime: $priceAtTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartProductModel &&
        other.cartId == cartId &&
        other.productId == productId &&
        other.quantity == quantity &&
        other.title == title &&
        other.imageUrls == imageUrls &&
        other.thumbnail == thumbnail &&
        other.priceAtTime == priceAtTime;
  }

  @override
  int get hashCode {
    return cartId.hashCode ^
    productId.hashCode ^
    quantity.hashCode ^
    title.hashCode ^
    imageUrls.hashCode ^
    thumbnail.hashCode ^
    priceAtTime.hashCode;
  }
}

// Classe pour créer/mettre à jour un produit dans le panier
class CartProductCreateModel {
  final int productId;
  final int quantity;

  CartProductCreateModel({
    required this.productId,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
    };
  }

  factory CartProductCreateModel.fromJson(Map<String, dynamic> json) {
    return CartProductCreateModel(
      productId: json['product_id'],
      quantity: json['quantity'] ?? 1,
    );
  }

  @override
  String toString() {
    return 'CartProductCreateModel(productId: $productId, quantity: $quantity)';
  }
}

// Classe pour la réponse complète du panier avec les produits
class CartWithProductsModel {
  final CartModel cart;
  final List<CartProductModel> products;

  CartWithProductsModel({
    required this.cart,
    required this.products,
  });

  factory CartWithProductsModel.fromJson(Map<String, dynamic> json) {
    return CartWithProductsModel(
      cart: CartModel.fromJson(json),
      products: (json['products'] as List<dynamic>?)
          ?.map((product) => CartProductModel.fromJson(product))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...cart.toJson(),
      'products': products.map((product) => product.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'CartWithProductsModel(cart: $cart, products: $products)';
  }
}