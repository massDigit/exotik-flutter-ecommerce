import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ecommerce/services/cart_service.dart';
import 'package:flutter_ecommerce/model/cart_model.dart';
import 'package:flutter_ecommerce/repository/cart_repository.dart';


CartProductModel makeItem({
  required int productId,
  required int quantity,
  required double priceAtTime,
  int cartId = 1,
  String title = 'Produit',
  String thumbnail = 'https://example.com/thumb.png',
}) {
  return CartProductModel(
    productId: productId,
    quantity: quantity,
    priceAtTime: priceAtTime,
    cartId: cartId,
    title: title,
    thumbnail: thumbnail,
  );
}

class _FakeCartService extends CartService {
  final Map<int, _P> _store = {};

  String? lastCall;
  int? lastCartId;
  int? lastProductId;
  int? lastQuantity;

  void seedProducts(List<CartProductModel> items) {
    _store
      ..clear()
      ..addEntries(items.map((p) => MapEntry(p.productId, _P(p.quantity, p.priceAtTime))));
  }

  List<CartProductModel> _snapshot() {
    return _store.entries
        .map((e) => makeItem(
      productId: e.key,
      quantity: e.value.q,
      priceAtTime: e.value.price,
    ))
        .toList();
  }


  @override
  Future<List<CartProductModel>> getCartProducts(int cartId) async {
    lastCall = 'getCartProducts';
    lastCartId = cartId;
    return _snapshot();
  }

  @override
  Future<List<CartProductModel>> addProductToCart(
      int cartId,
      CartProductCreateModel product,
      ) async {
    lastCall = 'addProductToCart';
    lastCartId = cartId;
    lastProductId = product.productId;
    lastQuantity = product.quantity;

    final cur = _store[product.productId];
    if (cur == null) {
      _store[product.productId] = _P(product.quantity, 2.5);
    } else {
      _store[product.productId] = _P(cur.q + product.quantity, cur.price);
    }
    return _snapshot();
  }

  @override
  Future<List<CartProductModel>> updateProductQuantity(
      int cartId,
      int productId,
      int newQuantity,
      ) async {
    lastCall = 'updateProductQuantity';
    lastCartId = cartId;
    lastProductId = productId;
    lastQuantity = newQuantity;

    final cur = _store[productId];
    if (cur == null) {
      return _snapshot();
    }
    if (newQuantity <= 0) {
      _store.remove(productId);
    } else {
      _store[productId] = _P(newQuantity, cur.price);
    }
    return _snapshot();
  }

  @override
  Future<List<CartProductModel>> removeProductFromCart(
      int cartId,
      int productId,
      ) async {
    lastCall = 'removeProductFromCart';
    lastCartId = cartId;
    lastProductId = productId;

    _store.remove(productId);
    return _snapshot();
  }

  @override
  Future<void> clearCart(int cartId) async {
    lastCall = 'clearCart';
    lastCartId = cartId;
    _store.clear();
  }
}

class _P {
  final int q;
  final double price;
  _P(this.q, this.price);
}

void main() {
  group('CartRepository - logique métier pure', () {
    late _FakeCartService fake;
    late CartRepository repo;

    setUp(() {
      fake = _FakeCartService();
      repo = CartRepository(cartService: fake);
    });

    group('Utilitaires de calcul', () {
      test('calculateCartTotal additionne quantité * prix', () {
        final items = [
          makeItem(productId: 1, quantity: 2, priceAtTime: 3.0),
          makeItem(productId: 2, quantity: 1, priceAtTime: 10.0),
          makeItem(productId: 3, quantity: 3, priceAtTime: 1.5),
        ];
        final total = repo.calculateCartTotal(items);
        expect(total, 20.5);
      });

      test('getTotalItemsCount additionne les quantités', () {
        final items = [
          makeItem(productId: 1, quantity: 2, priceAtTime: 3.0),
          makeItem(productId: 2, quantity: 1, priceAtTime: 10.0),
          makeItem(productId: 3, quantity: 3, priceAtTime: 1.5),
        ];
        expect(repo.getTotalItemsCount(items), 6);
      });

      test('isProductInCart détecte la présence d’un produit', () {
        final items = [
          makeItem(productId: 10, quantity: 1, priceAtTime: 2.0),
        ];
        expect(repo.isProductInCart(items, 10), isTrue);
        expect(repo.isProductInCart(items, 99), isFalse);
      });

      test('getProductQuantity retourne la quantité ou 0 si absent', () {
        final items = [
          makeItem(productId: 5, quantity: 7, priceAtTime: 1.0),
        ];
        expect(repo.getProductQuantity(items, 5), 7);
        expect(repo.getProductQuantity(items, 6), 0);
      });
    });

    group('add / update / remove (décisions métier Repository)', () {
      test('addProductToCart utilise service.addProductToCart (qty par défaut = 1)', () async {
        fake.seedProducts([
          makeItem(productId: 1, quantity: 2, priceAtTime: 3.0),
        ]);

        final res = await repo.addProductToCart(cartId: 100, productId: 2);
        expect(fake.lastCall, 'addProductToCart');
        expect(fake.lastCartId, 100);
        expect(fake.lastProductId, 2);
        expect(fake.lastQuantity, 1);

        expect(res.map((e) => e.productId), containsAll([1, 2]));
      });

      test('updateProductQuantity (>0) → service.updateProductQuantity', () async {
        fake.seedProducts([
          makeItem(productId: 10, quantity: 2, priceAtTime: 3.0),
        ]);

        final res = await repo.updateProductQuantity(
          cartId: 1,
          productId: 10,
          newQuantity: 5,
        );

        expect(fake.lastCall, 'updateProductQuantity');
        expect(fake.lastCartId, 1);
        expect(fake.lastProductId, 10);
        expect(fake.lastQuantity, 5);

        final updated = res.firstWhere((p) => p.productId == 10);
        expect(updated.quantity, 5);
      });

      test('updateProductQuantity (<=0) → removeProductFromCart', () async {
        fake.seedProducts([
          makeItem(productId: 10, quantity: 2, priceAtTime: 3.0),
          makeItem(productId: 11, quantity: 1, priceAtTime: 5.0),
        ]);

        final res = await repo.updateProductQuantity(
          cartId: 2,
          productId: 10,
          newQuantity: 0,
        );

        expect(fake.lastCall, 'removeProductFromCart');
        expect(fake.lastCartId, 2);
        expect(fake.lastProductId, 10);

        expect(res.any((p) => p.productId == 10), isFalse);
        expect(res.any((p) => p.productId == 11), isTrue);
      });

      test('removeProductFromCart supprime et retourne la liste à jour', () async {
        fake.seedProducts([
          makeItem(productId: 1, quantity: 1, priceAtTime: 2.0),
          makeItem(productId: 2, quantity: 3, priceAtTime: 1.0),
        ]);

        final res = await repo.removeProductFromCart(cartId: 9, productId: 2);
        expect(fake.lastCall, 'removeProductFromCart');
        expect(res.any((p) => p.productId == 2), isFalse);
        expect(res.single.productId, 1);
      });
    });

    group('increment / decrement (logique combinée Repository)', () {
      test('incrementProductQuantity: existe → updateQuantity', () async {
        fake.seedProducts([
          makeItem(productId: 50, quantity: 2, priceAtTime: 4.0),
        ]);

        final res = await repo.incrementProductQuantity(
          cartId: 123,
          productId: 50,
          incrementBy: 3,
        );

        expect(fake.lastCall, 'updateProductQuantity');
        expect(fake.lastCartId, 123);
        expect(fake.lastProductId, 50);
        expect(fake.lastQuantity, 5);

        final item = res.firstWhere((p) => p.productId == 50);
        expect(item.quantity, 5);
      });

      test('incrementProductQuantity: absent → addProductToCart', () async {
        fake.seedProducts([]);

        final res = await repo.incrementProductQuantity(
          cartId: 10,
          productId: 77,
          incrementBy: 2,
        );

        expect(fake.lastCall, 'addProductToCart');
        expect(fake.lastCartId, 10);
        expect(fake.lastProductId, 77);
        expect(fake.lastQuantity, 2);

        final item = res.firstWhere((p) => p.productId == 77);
        expect(item.quantity, 2);
      });

      test('decrementProductQuantity: reste > 0 → updateQuantity', () async {
        fake.seedProducts([
          makeItem(productId: 9, quantity: 5, priceAtTime: 1.0),
        ]);

        final res = await repo.decrementProductQuantity(
          cartId: 88,
          productId: 9,
          decrementBy: 3,
        );

        expect(fake.lastCall, 'updateProductQuantity');
        expect(fake.lastCartId, 88);
        expect(fake.lastProductId, 9);
        expect(fake.lastQuantity, 2);

        final item = res.firstWhere((p) => p.productId == 9);
        expect(item.quantity, 2);
      });

      test('decrementProductQuantity: tombe à 0/neg → removeProductFromCart', () async {
        fake.seedProducts([
          makeItem(productId: 9, quantity: 2, priceAtTime: 1.0),
          makeItem(productId: 1, quantity: 1, priceAtTime: 1.0),
        ]);

        final res = await repo.decrementProductQuantity(
          cartId: 88,
          productId: 9,
          decrementBy: 3,
        );

        expect(fake.lastCall, 'removeProductFromCart');

        expect(res.any((p) => p.productId == 9), isFalse);
        expect(res.any((p) => p.productId == 1), isTrue);
      });

      test('decrementProductQuantity: produit absent → liste inchangée', () async {
        fake.seedProducts([
          makeItem(productId: 1, quantity: 1, priceAtTime: 1.0),
        ]);

        final res = await repo.decrementProductQuantity(
          cartId: 33,
          productId: 99, // absent
          decrementBy: 1,
        );

        expect(fake.lastCall, 'getCartProducts');
        expect(res.map((e) => e.productId), [1]);
      });
    });
  });
}
