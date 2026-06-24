import 'package:flutter/material.dart';
import 'package:flutter_shop/models/product.dart';
import 'package:flutter_shop/models/shipping_option.dart';
import 'package:flutter_shop/services/cart_service.dart';
import 'package:flutter_shop/views/widgets/summary_row.dart';

class CartView extends StatefulWidget {
  const CartView({
    super.key,
    required this.initialCart,
    required this.initialShipping,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    required this.onShippingChanged,
    required this.cartService,
    required this.onPurchase,
  });

  final Map<Product, int> initialCart;
  final ShippingOption initialShipping;
  final ValueChanged<Product> onIncrease;
  final ValueChanged<Product> onDecrease;
  final ValueChanged<Product> onRemove;
  final ValueChanged<ShippingOption> onShippingChanged;
  final CartService cartService;
  final void Function(Map<Product, int> cart, ShippingOption shipping)
  onPurchase;

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  late final Map<Product, int> _cart;
  late ShippingOption _shipping;
  bool _isPurchasing = false;

  int get _itemCount => widget.cartService.itemCount(_cart);

  double get _subtotal => widget.cartService.subtotal(_cart);

  double get _tax => widget.cartService.taxFromSubtotal(_subtotal);

  double get _total => widget.cartService.total(_cart, _shipping);

  @override
  void initState() {
    super.initState();
    _cart = {
      for (final entry in widget.initialCart.entries) entry.key: entry.value,
    };
    _shipping = widget.initialShipping;
  }

  void _increase(Product product) {
    setState(() {
      widget.cartService.increaseProductQty(_cart, product);
    });
    widget.onIncrease(product);
  }

  void _decrease(Product product) {
    setState(() {
      widget.cartService.decreaseProductQty(_cart, product);
    });
    widget.onDecrease(product);
  }

  void _remove(Product product) {
    setState(() {
      widget.cartService.removeFromProductCart(_cart, product);
    });
    widget.onRemove(product);
  }

  void _setShipping(ShippingOption option) {
    setState(() {
      _shipping = option;
    });
    widget.onShippingChanged(option);
  }

  Future<void> _purchase() async {
    if (_itemCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one item before purchasing.'),
        ),
      );
      return;
    }

    setState(() => _isPurchasing = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    widget.onPurchase(Map<Product, int>.from(_cart), _shipping);
    setState(() {
      _cart.clear();
      _isPurchasing = false;
    });

    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Purchase complete'),
          content: Text(
            'This was a fake checkout for practice. Shipping: ${_shipping.label}.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Back to catalog'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Cart ($_itemCount)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Cart items', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          if (_cart.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Your cart is empty. Add products from the catalog.',
                ),
              ),
            ),
          for (final entry in _cart.entries)
            Dismissible(
              key: Key('dismiss-${entry.key.name}'),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => _remove(entry.key),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              child: Card(
                child: ListTile(
                  leading: Icon(entry.key.icon),
                  title: Text(entry.key.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('\$${entry.key.price.toStringAsFixed(2)} each'),
                      Text(
                        'Item subtotal: \$${widget.cartService.itemSubtotal(entry.key, entry.value).toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: Key('decrease-${entry.key.name}'),
                        onPressed: () => _decrease(entry.key),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('${entry.value}', key: Key('qty-${entry.key.name}')),
                      IconButton(
                        key: Key('increase-${entry.key.name}'),
                        onPressed: () => _increase(entry.key),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text('Shipping', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          for (final option in ShippingOption.values)
            RadioListTile<ShippingOption>(
              title: Text(option.label),
              subtitle: Text(
                option.fee == 0 ? 'Free' : '\$${option.fee.toStringAsFixed(2)}',
              ),
              value: option,
              groupValue: _shipping,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                _setShipping(value);
              },
            ),
          const Divider(height: 28),
          Text(
            'Order summary',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          SummaryRow(label: 'Items', value: '$_itemCount'),
          SummaryRow(
            label: 'Subtotal',
            value: '\$${_subtotal.toStringAsFixed(2)}',
          ),
          SummaryRow(label: 'Tax (8%)', value: '\$${_tax.toStringAsFixed(2)}'),
          SummaryRow(
            label: 'Shipping',
            value: '\$${_shipping.fee.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 4),
          SummaryRow(
            label: 'Total',
            value: '\$${_total.toStringAsFixed(2)}',
            emphasize: true,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('purchase-button'),
            onPressed: _isPurchasing ? null : _purchase,
            icon: _isPurchasing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.shopping_bag_outlined),
            label: Text(_isPurchasing ? 'Processing...' : 'Purchase (Fake)'),
          ),
          const SizedBox(height: 12),
          const Text('Swipe left on a cart item to remove it instantly.'),
          const SizedBox(height: 4),
          const Text(
            'All interactions are local and for practice only. No real payment is processed.',
          ),
        ],
      ),
    );
  }
}
