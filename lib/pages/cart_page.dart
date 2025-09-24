import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ecommerce/controllers/cart_controller.dart';
import 'package:flutter_ecommerce/model/cart_model.dart';
import 'package:flutter_ecommerce/guard.dart';
import 'package:flutter_ecommerce/widgets/drawer.dart';

class CartPage extends StatefulWidget {
  final CartController cartController;

  const CartPage({super.key, required this.cartController});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    _initializeCart();
    // Écouter les changements du panier
    widget.cartController.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    widget.cartController.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _initializeCart() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {

        widget.cartController.createCart(user.uid);
        // if (!widget.cartController.hasCart) {
        //   widget.cartController.createCart(user.uid);
        // } else {
        //   widget.cartController.refreshCart();
        // }

        //test reffacto
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Guard();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Panier'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => widget.cartController.refreshCart(),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Builder(
        builder: (context) {
          final cartController = widget.cartController;

          if (cartController.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue),
                  SizedBox(height: 16),
                  Text('Chargement du panier...'),
                ],
              ),
            );
          }

          if (cartController.error != null) {
            return _buildErrorState(cartController);
          }

          if (!cartController.hasCart) {
            return _buildNoCartState(cartController, user.uid);
          }

          return Column(
            children: [
              _buildCartHeader(cartController),
              Expanded(
                child: cartController.isEmpty
                    ? _buildEmptyCart()
                    : _buildCartContent(cartController),
              ),
              if (!cartController.isEmpty)
                _buildCartFooter(cartController),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(CartController cartController) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Erreur',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              cartController.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: cartController.refreshCart,
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

  Widget _buildNoCartState(CartController cartController, String userId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Aucun panier trouvé',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Créons votre panier pour commencer',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => cartController.createCart(userId),
            icon: Icon(Icons.add_shopping_cart),
            label: Text('Créer un panier'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartHeader(CartController cartController) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.shopping_cart, color: Colors.blue, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panier #${cartController.currentCart?.id ?? "N/A"}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (cartController.currentCart?.status != null)
                  Text(
                    'Statut: ${cartController.currentCart!.status}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${cartController.totalItems} articles',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24),
          Text(
            'Votre panier est vide',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Découvrez nos produits et ajoutez-les à votre panier',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.shopping_bag),
            label: Text('Continuer mes achats'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(CartController cartController) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: cartController.cartProducts.length,
      itemBuilder: (context, index) {
        final product = cartController.cartProducts[index];
        return _buildCartItem(product, cartController);
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey[600],
        size: 30,
      ),
    );
  }

  Widget _buildCartItem(CartProductModel product, CartController cartController) {
    final subtotal = product.priceAtTime * product.quantity;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (product.imageUrls != null && product.imageUrls!.isNotEmpty)
                  ? Image.network(
                product.thumbnail,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildImagePlaceholder();
                },
                errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
              )
                  : _buildImagePlaceholder(),
            ),
            // Container(
            //   width: 60,
            //   height: 60,
            //   decoration: BoxDecoration(
            //     color: Colors.grey[300],
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Icon(
            //     Icons.image,
            //     color: Colors.grey[600],
            //     size: 30,
            //   ),
            // ),
            SizedBox(width: 16),

            // Informations du produit
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${product.title}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '€${product.priceAtTime.toStringAsFixed(2)} / unité',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sous-total: €${subtotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Contrôles de quantité
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        cartController.decrementProduct(product.productId);
                      },
                      icon: Icon(Icons.remove_circle_outline),
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.all(4),
                      iconSize: 20,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${product.quantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        cartController.incrementProduct(product.productId);
                      },
                      icon: Icon(Icons.add_circle_outline),
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.all(4),
                      iconSize: 20,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    _showRemoveProductDialog(context, product.productId, cartController);
                  },
                  child: Text(
                    'Supprimer',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartFooter(CartController cartController) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Résumé du panier
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total (${cartController.totalItems} articles)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '€${cartController.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showClearCartDialog(context, cartController);
                  },
                  icon: Icon(Icons.clear_all),
                  label: Text('Vider'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implémenter la commande
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fonctionnalité de commande à venir !'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: Icon(Icons.shopping_bag),
                  label: Text('Commander'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continuer mes achats'),
          ),
        ],
      ),
    );
  }

  void _showRemoveProductDialog(BuildContext context, int productId, CartController cartController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le produit'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce produit de votre panier ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              cartController.removeProduct(productId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartController cartController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vider le panier'),
        content: Text('Êtes-vous sûr de vouloir vider complètement votre panier ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              cartController.clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Vider'),
          ),
        ],
      ),
    );
  }
}