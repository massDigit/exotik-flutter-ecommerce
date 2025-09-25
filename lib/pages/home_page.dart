// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ecommerce/controllers/product_controller.dart';
import 'package:flutter_ecommerce/controllers/pagination_controller.dart';
import 'package:flutter_ecommerce/controllers/filter_controller.dart';
import 'package:flutter_ecommerce/controllers/cart_controller.dart';
import 'package:flutter_ecommerce/pages/product_detail_page.dart';
import 'package:flutter_ecommerce/pages/cart_page.dart';
import 'package:flutter_ecommerce/widgets/drawer.dart';
import 'package:flutter_ecommerce/widgets/custom_search_bar.dart';
import 'package:flutter_ecommerce/model/product_model.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final ProductController _productController;
  late final PaginationController _paginationController;
  late final FilterController _filterController;
  late final CartController _cartController; // Ajout du CartController

  final List<String> myAppSuggestions = [
    'iPhone 15 Pro',
    'MacBook Pro',
    'AirPods Max',
    'Apple Watch Ultra',
    'Samsung Galaxy S24',
    'Xiaomi Redmi',
    'Casque Gaming',
    'Souris Bluetooth',
    'Clavier Mécanique',
    'Écran 4K',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
    _initializeCart();
  }

  @override
  void dispose() {
    _productController.dispose();
    _paginationController.dispose();
    _filterController.dispose();
    _cartController.dispose(); // Dispose du CartController
    super.dispose();
  }

  void _initializeControllers() {
    _productController = ProductController();
    _paginationController = PaginationController();
    _filterController = FilterController();
    _cartController = CartController(); // Initialisation du CartController

    _productController.onStateChanged = () {
      if (mounted) {
        setState(() {
          _paginationController.updateItems(_productController.filteredProducts);
        });
      }
    };

    _paginationController.onPageChanged = () {
      if (mounted) {
        setState(() {});
      }
    };

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

    // Écouter les changements du panier
    _cartController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _loadInitialData() {
    _productController.loadAllProducts();
    _productController.loadCategories();
  }

  void _initializeCart() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Créer un panier si l'utilisateur n'en a pas
        if (!_cartController.hasCart) {
          _cartController.createCart(user.uid);
        }
      });
    }
  }

  void _onSearchSelected(String searchTerm) {
    _filterController.applySearch(searchTerm);
  }

  void _onFilterPressed() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filtrer par catégorie'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text('Tous les produits'),
                onTap: () {
                  Navigator.pop(context);
                  _filterController.clearFilters();
                },
              ),
              ..._productController.categories.map((category) => ListTile(
                title: Text(category),
                onTap: () {
                  Navigator.pop(context);
                  _filterController.applyCategory(category);
                },
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _onRefresh() {
    _loadInitialData();
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(cartController: _cartController), // Passer le controller
      ),
    );
  }

  // Nouvelle méthode pour ajouter un produit au panier
  // Remplace la version existante
  Future<void> _addToCart(ProductModel product) async {
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

      if (!mounted) return; // <-- important après await
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (error) {
      if (!mounted) return; // <-- important après await échoué
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-Commerce App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Icône du panier avec badge
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: _navigateToCart,
                tooltip: 'Mon Panier',
              ),
              if (_cartController.totalItems > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_cartController.totalItems}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _onRefresh,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          CustomSearchBar(
            hintText: 'Rechercher des produits...',
            suggestions: myAppSuggestions,
            onSearchSelected: _onSearchSelected,
            onFilterPressed: _onFilterPressed,
          ),

          if (_filterController.hasActiveFilters)
            _buildActiveFilterBar(),

          Expanded(
            child: _buildMainContent(),
          ),

          if (!_productController.isLoading &&
              _productController.errorMessage == null &&
              _productController.filteredProducts.isNotEmpty)
            _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildActiveFilterBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.withValues(alpha:0.1),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.blue, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _filterController.getActiveFilterDisplay(_productController.filteredProducts.length),
              style: TextStyle(color: Colors.blue[800], fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () => _filterController.clearFilters(),
            child: Icon(Icons.close, color: Colors.blue, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_productController.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text('Chargement des produits...'),
          ],
        ),
      );
    }

    if (_productController.errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                _productController.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700]),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _onRefresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Réessayer'),
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
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucun résultat pour "${_filterController.selectedSearchDisplay}"'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _filterController.clearFilters(),
              child: Text('Voir tous les produits'),
            ),
          ],
        ),
      );
    }

    if (_productController.allProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucun produit disponible'),
          ],
        ),
      );
    }

    return _buildProductGrid();
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _paginationController.displayedItems.length,
      itemBuilder: (context, index) {
        final product = _paginationController.displayedItems[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Informations de pagination
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _paginationController.getPaginationInfo(),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              DropdownButton<int>(
                value: _paginationController.itemsPerPage,
                items: [5, 10, 20, 50].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value par page'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    _paginationController.changeItemsPerPage(newValue);
                  }
                },
                underline: Container(),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Contrôles de navigation
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _paginationController.canGoToPreviousPage()
                      ? _paginationController.goToFirstPage
                      : null,
                  icon: Icon(Icons.first_page),
                  tooltip: 'Première page',
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: _paginationController.canGoToPreviousPage()
                      ? _paginationController.goToPreviousPage
                      : null,
                  icon: Icon(Icons.chevron_left),
                  tooltip: 'Page précédente',
                  iconSize: 20,
                ),
                ..._buildPageNumberButtons(),
                IconButton(
                  onPressed: _paginationController.canGoToNextPage()
                      ? _paginationController.goToNextPage
                      : null,
                  icon: Icon(Icons.chevron_right),
                  tooltip: 'Page suivante',
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: _paginationController.canGoToNextPage()
                      ? _paginationController.goToLastPage
                      : null,
                  icon: Icon(Icons.last_page),
                  tooltip: 'Dernière page',
                  iconSize: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumberButtons() {
    final visiblePages = _paginationController.getVisiblePageNumbers();

    return visiblePages.map((pageNumber) {
      final isCurrentPage = pageNumber == _paginationController.currentPage;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 1),
        child: Material(
          color: isCurrentPage ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _paginationController.changePage(pageNumber),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: Text(
                pageNumber.toString(),
                style: TextStyle(
                  color: isCurrentPage ? Colors.white : Colors.grey[700],
                  fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  product.thumbnail,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        color: Colors.blue,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, color: Colors.grey[600]),
                          Text(
                            'Image non disponible',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Informations du produit
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.category,
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(2)} €',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        // Bouton d'ajout au panier modifié
                        GestureDetector(
                          onTap: () => _addToCart(product),
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _cartController.isProductInCart(product.id) ? Colors.green : Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _cartController.isProductInCart(product.id) ? Icons.check : Icons.add_shopping_cart,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                if (_cartController.isProductInCart(product.id) && _cartController.getProductQuantity(product.id) > 0) ...[
                                  SizedBox(width: 4),
                                  Text(
                                    '${_cartController.getProductQuantity(product.id)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}