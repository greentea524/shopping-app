import 'package:flutter/material.dart';
import 'package:flutter_shop/models/order_record.dart';
import 'package:flutter_shop/models/product.dart';
import 'package:flutter_shop/models/shipping_option.dart';
import 'package:flutter_shop/services/cart_service.dart';
import 'package:flutter_shop/services/storage_service.dart';
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
  final StorageService _storageService = StorageService();
  final Map<String, int> _cart = <String, int>{};
  final List<OrderRecord> _orderHistory = <OrderRecord>[];
  ShippingOption _selectedShipping = ShippingOption.standard;
  int _selectedTabIndex = 0;
  final Set<String> _loadingProducts = {};

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await _storageService.getAllOrders();
    setState(() {
      _orderHistory.addAll(orders);
    });
  }

  int get _cartItems => _cartService.itemCountByName(_cart);

  Future<void> _addToCart(Product product) async {
    setState(() => _loadingProducts.add(product.name));
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _cartService.addToNamedCart(_cart, product);
      _loadingProducts.remove(product.name);
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

  Future<void> _completePurchase(
    Map<Product, int> purchasedCart,
    ShippingOption shipping,
  ) async {
    final order = _orderService.createOrder(
      purchasedCart: purchasedCart,
      shipping: shipping,
    );

    await _storageService.saveOrder(order);

    setState(() {
      _orderHistory.insert(0, order);
      _cart.clear();
      _selectedShipping = shipping;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    await _storageService.updateOrderStatus(
      orderId,
      OrderStatus.cancelled,
    );
    setState(() {
      final order = _orderHistory.firstWhere((o) => o.id == orderId);
      order.status = OrderStatus.cancelled;
    });
  }

  Future<void> _archiveOrder(String orderId) async {
    await _storageService.updateOrderStatus(
      orderId,
      OrderStatus.archived,
    );
    setState(() {
      final order = _orderHistory.firstWhere((o) => o.id == orderId);
      order.status = OrderStatus.archived;
    });
  }

  Future<void> _updateTracking(String orderId) async {
    final order = _orderHistory.firstWhere((o) => o.id == orderId);
    final statuses = [
      TrackingStatus.processing,
      TrackingStatus.shipped,
      TrackingStatus.inTransit,
      TrackingStatus.outForDelivery,
      TrackingStatus.delivered,
    ];

    final currentIndex = statuses.indexOf(order.trackingStatus);
    if (currentIndex < statuses.length - 1) {
      final nextStatus = statuses[currentIndex + 1];
      await _storageService.updateTrackingStatus(orderId, nextStatus);
      setState(() {
        order.trackingStatus = nextStatus;
      });
    }
  }

  Future<void> _deleteOrder(String orderId) async {
    await _storageService.deleteOrder(orderId);
    setState(() {
      _orderHistory.removeWhere((o) => o.id == orderId);
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
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: FilledButton.icon(
                    key: const Key('open-cart-button'),
                    onPressed: _openCart,
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: Text(
                      'Cart: $_cartItems',
                      key: const Key('cart-count'),
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
                  for (final category in demoCatalog.map((p) => p.category).toSet().toList()) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 6),
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    for (final product in demoCatalog.where((p) => p.category == category))
                    Card(
                      child: ListTile(
                        leading: Icon(product.icon),
                        title: Text(product.name),
                        subtitle: Text(
                          '${product.description}\n\$${product.price.toStringAsFixed(2)}',
                        ),
                        isThreeLine: true,
                        trailing: FilledButton(
                          onPressed: _loadingProducts.contains(product.name)
                              ? null
                              : () => _addToCart(product),
                          child: _loadingProducts.contains(product.name)
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : _cart.containsKey(product.name)
                                  ? Text('In Cart (${_cart[product.name]})')
                                  : const Text('Add'),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                    'Tap the cart icon to edit quantities, choose shipping, and complete a fake purchase.',
                  ),
                ],
              ),
              OrderHistoryView(
                orders: _orderHistory,
                onCancelOrder: _cancelOrder,
                onArchiveOrder: _archiveOrder,
                onUpdateTracking: _updateTracking,
                onDeleteOrder: _deleteOrder,
              ),
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

