import 'package:flutter/material.dart';
import 'package:flutter_shop/models/order_record.dart';
import 'package:flutter_shop/models/product.dart';
import 'package:flutter_shop/models/shipping_option.dart';
import 'package:flutter_shop/services/cart_service.dart';
import 'package:flutter_shop/services/order_service.dart';
import 'package:flutter_shop/views/cart_view.dart';
import 'package:flutter_shop/views/order_history_view.dart';

class ShopShellView extends StatefulWidget {
  const ShopShellView({super.key});

  @override
  State<ShopShellView> createState() => _ShopShellViewState();
}

class _ShopShellViewState extends State<ShopShellView> {
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();
  final Map<String, int> _cart = <String, int>{};
  final List<OrderRecord> _orderHistory = <OrderRecord>[];
  ShippingOption _selectedShipping = ShippingOption.standard;
  int _selectedTabIndex = 0;

  int get _cartItems => _cartService.itemCountByName(_cart);

  void _addToCart(Product product) {
    setState(() {
      _cartService.addToNamedCart(_cart, product);
    });
  }

  void _increaseQty(Product product) {
    setState(() {
      _cartService.increaseNamedQty(_cart, product);
    });
  }

  void _decreaseQty(Product product) {
    setState(() {
      _cartService.decreaseNamedQty(_cart, product);
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      _cartService.removeFromNamedCart(_cart, product);
    });
  }

  Map<Product, int> _cartAsProducts() {
    return _cartService.asProductCart(_cart, demoCatalog);
  }

  void _completePurchase(
    Map<Product, int> purchasedCart,
    ShippingOption shipping,
  ) {
    final order = _orderService.createOrder(
      purchasedCart: purchasedCart,
      shipping: shipping,
    );

    setState(() {
      _orderHistory.insert(0, order);
      _cart.clear();
      _selectedShipping = shipping;
    });
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return CartView(
            initialCart: _cartAsProducts(),
            initialShipping: _selectedShipping,
            onIncrease: _increaseQty,
            onDecrease: _decreaseQty,
            onRemove: _removeFromCart,
            onShippingChanged: (option) {
              setState(() {
                _selectedShipping = option;
              });
            },
            cartService: _cartService,
            onPurchase: _completePurchase,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Shop Play', 'Order History'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedTabIndex]),
        actions: [
          if (_selectedTabIndex == 0)
            IconButton(
              key: const Key('open-cart-button'),
              onPressed: _openCart,
              icon: const Icon(Icons.shopping_cart_outlined),
              tooltip: 'Open cart',
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Cart: $_cartItems',
                key: const Key('cart-count'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Catalog', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              for (final product in demoCatalog)
                Card(
                  child: ListTile(
                    leading: Icon(product.icon),
                    title: Text(product.name),
                    subtitle: Text(
                      '${product.description}\n\$${product.price.toStringAsFixed(2)}',
                    ),
                    isThreeLine: true,
                    trailing: FilledButton(
                      onPressed: () => _addToCart(product),
                      child: const Text('Add'),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              const Text(
                'Tap the cart icon to edit quantities, choose shipping, and complete a fake purchase.',
              ),
            ],
          ),
          OrderHistoryView(orders: _orderHistory),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront), label: 'Shop'),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'History',
          ),
        ],
        onDestinationSelected: (value) {
          setState(() {
            _selectedTabIndex = value;
          });
        },
      ),
    );
  }
}
