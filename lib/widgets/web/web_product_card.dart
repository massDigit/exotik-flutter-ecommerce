import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/model/product_model.dart';

class WebProductCard extends StatefulWidget {
  final ProductModel product;
  final bool isInCart;
  final int quantity;
  final void Function(ProductModel) onAddToCart;

  const WebProductCard({
    super.key,
    required this.product,
    required this.isInCart,
    required this.quantity,
    required this.onAddToCart,
  });

  @override
  State<WebProductCard> createState() => _WebProductCardState();
}

class _WebProductCardState extends State<WebProductCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _hover ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))] : [],
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              // Routes nommées : on passe le ProductModel
              Navigator.pushNamed(context, '/product-detail', arguments: p);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Image.network(
                    p.thumbnail,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, prog) =>
                    prog == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, color: Colors.grey[600]),
                          const SizedBox(height: 6),
                          Text('Image indisponible', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(p.category, style: TextStyle(color: Colors.blue[600], fontSize: 11, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${p.price.toStringAsFixed(2)} €', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 14)),
                          InkWell(
                            onTap: () => widget.onAddToCart(p),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: widget.isInCart ? Colors.green : Colors.blue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(widget.isInCart ? Icons.check : Icons.add_shopping_cart, size: 16, color: Colors.white),
                                if (widget.isInCart && widget.quantity > 0) ...[
                                  const SizedBox(width: 6),
                                  Text('${widget.quantity}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
