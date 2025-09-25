// lib/pages/web_home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_ecommerce/controllers/product_controller.dart';
import 'package:flutter_ecommerce/controllers/pagination_controller.dart';
import 'package:flutter_ecommerce/controllers/filter_controller.dart';
import 'package:flutter_ecommerce/controllers/cart_controller.dart';

import 'package:flutter_ecommerce/model/product_model.dart';
import 'package:flutter_ecommerce/pages/cart_page.dart';
import 'package:flutter_ecommerce/widgets/custom_search_bar.dart';
import 'package:flutter_ecommerce/widgets/web/web_search_bar.dart';

import 'package:flutter_ecommerce/widgets/drawer.dart';

import 'package:flutter_ecommerce/widgets/web/web_active_filter_bar.dart';
import 'package:flutter_ecommerce/widgets/web/web_pagination_toolbar.dart';
import 'package:flutter_ecommerce/widgets/web/web_product_card.dart';

class WebHomePage extends StatefulWidget {
  const WebHomePage({super.key});

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  late final ProductController _productController;
  late final PaginationController _paginationController;
  late final FilterController _filterController;
  late final CartController _cartController;

  final List<String> suggestions = const [
    'iPhone 15 Pro','MacBook Pro','AirPods Max','Apple Watch Ultra',
    'Samsung Galaxy S24','Xiaomi Redmi','Casque Gaming','Souris Bluetooth',
    'Clavier Mécanique','Écran 4K',
  ];

  @override
  void initState() {
    super.initState();
    _productController = ProductController();
    _paginationController = PaginationController();
    _filterController = FilterController();
    _cartController = CartController();

    _paginationController.changeItemsPerPage(12);

    _productController.onStateChanged = () {
      if (mounted) {
        setState(() {
          _paginationController.updateItems(_productController.filteredProducts);
        });
      }
    };
    _paginationController.onPageChanged = () { if (mounted) setState(() {}); };
    _filterController.onFiltersChanged = () {
      if (mounted) {
        setState(() {
          _productController.applyFilters(
            searchQuery: _filterController.searchQuery,
            selectedCategory: _filterController.selectedCategory,
          );
          _paginationController.resetToFirstPage();
        });
      }
    };
    _cartController.addListener(() { if (mounted) setState(() {}); });

    _productController.loadAllProducts();
    _productController.loadCategories();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_cartController.hasCart) _cartController.createCart(user.uid);
      });
    }
  }

  @override
  void dispose() {
    _productController.dispose();
    _paginationController.dispose();
    _filterController.dispose();
    _cartController.dispose();
    super.dispose();
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CartPage(cartController: _cartController)),
    );
  }

  void _onSearchSelected(String term) => _filterController.applySearch(term);

  void _openFilterDialogMobile() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Filtrer par catégorie'),
        content: SizedBox(
          width: 360,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('Tous les produits'),
                onTap: () { Navigator.pop(context); _filterController.clearFilters(); },
              ),
              ..._productController.categories.map((c) => ListTile(
                title: Text(c),
                onTap: () { Navigator.pop(context); _filterController.applyCategory(c); },
              )),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }

  void _addToCart(ProductModel product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return; // sécurité avant d'utiliser context
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour ajouter au panier'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _cartController.addOrIncrementProduct(product.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('${product.title} ajouté au panier')),
              TextButton(
                onPressed: _navigateToCart,
                child: const Text('VOIR PANIER', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final maxW = c.maxWidth;
      final isWide = maxW >= 1100;
      final isUltraWide = maxW >= 1400;

      return Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          titleSpacing: 0,
          title: Row(
            children: [
              const SizedBox(width: 12),
              const Text('E-Commerce App', style: TextStyle(color: Colors.white)),
              const SizedBox(width: 24),
              if (isWide)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      height: 44,
                      child: WebSearchBar(
                        hintText: 'Rechercher des produits…',
                        suggestions: suggestions,
                        onSearchSelected: _onSearchSelected,
                        onFilterPressed: () {
                          if (!isWide) _openFilterDialogMobile();
                        },
                        height: 44, // ✨ aligne dans l’AppBar
                      ),
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: _navigateToCart,
                  tooltip: 'Mon Panier',
                ),
                if (_cartController.totalItems > 0)
                  Positioned(
                    right: 8, top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${_cartController.totalItems}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _productController.loadAllProducts();
                _productController.loadCategories();
              },
            ),
          ],
        ),

        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isWide)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: Material(
                  elevation: 1,
                  color: Colors.blue.withValues(alpha:0.04),
                  child: Column(
                    children: [
                      Container(
                        height: 56,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Text('Filtres', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          children: [
                            ListTile(
                              title: const Text('Tous les produits'),
                              leading: const Icon(Icons.grid_view),
                              onTap: _filterController.clearFilters,
                            ),
                            ..._productController.categories.map((c) => ListTile(
                              title: Text(c),
                              leading: const Icon(Icons.label_outline),
                              onTap: () => _filterController.applyCategory(c),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Expanded(
              child: Column(
                children: [
                  if (!isWide)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: CustomSearchBar(
                        hintText: 'Rechercher des produits…',
                        suggestions: suggestions,
                        onSearchSelected: _onSearchSelected,
                        onFilterPressed: _openFilterDialogMobile,
                      ),
                    ),

                  if (_filterController.hasActiveFilters)
                    WebActiveFilterBar(
                      label: _filterController.getActiveFilterDisplay(_productController.filteredProducts.length),
                      onClear: _filterController.clearFilters,
                    ),

                  Expanded(child: _buildMainContent(isUltraWide: isUltraWide)),

                  if (!_productController.isLoading &&
                      _productController.errorMessage == null &&
                      _productController.filteredProducts.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha:0.12), blurRadius: 6, offset: const Offset(0, -2))],
                      ),
                      child: WebPaginationToolbar(controller: _paginationController),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMainContent({required bool isUltraWide}) {
    if (_productController.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }
    if (_productController.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 12),
              const Text('Erreur de chargement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(_productController.errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red[700])),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () { _productController.loadAllProducts(); _productController.loadCategories(); },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }
    if (_productController.filteredProducts.isEmpty && _filterController.hasActiveFilters) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Aucun résultat pour "${_filterController.selectedSearchDisplay}"'),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _filterController.clearFilters, child: const Text('Voir tous les produits')),
          ],
        ),
      );
    }
    if (_productController.allProducts.isEmpty) {
      return const Center(child: Text('Aucun produit disponible'));
    }

    return LayoutBuilder(builder: (_, c) {
      final w = c.maxWidth;
      final cross = w >= 1600 ? 6 : w >= 1400 ? 5 : w >= 1100 ? 4 : w >= 900 ? 3 : 2;
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cross,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3 / 4,
        ),
        itemCount: _paginationController.displayedItems.length,
        itemBuilder: (_, i) {
          final prod = _paginationController.displayedItems[i];
          return WebProductCard(
            product: prod,
            isInCart: _cartController.isProductInCart(prod.id),
            quantity: _cartController.getProductQuantity(prod.id),
            onAddToCart: _addToCart,
          );
        },
      );
    });
  }
}
